from contextlib import contextmanager
import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import socket
import time

import dns.exception
import dns.resolver
import dns.reversename
import psycopg2


DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
APP_VERSION = os.getenv("APP_VERSION", "dev")

DB_CONNECT_RETRIES = int(os.getenv("DB_CONNECT_RETRIES", "30"))
DB_CONNECT_DELAY = float(os.getenv("DB_CONNECT_DELAY", "2"))

REQUIRED_CONFIG = {
    "DB_HOST": DB_HOST,
    "DB_NAME": DB_NAME,
    "DB_USER": DB_USER,
    "DB_PASS": DB_PASS,
}

missing = [name for name, value in REQUIRED_CONFIG.items() if not value]

if missing:
    missing_names = ", ".join(missing)
    raise RuntimeError(
        f"Missing required environment variables: {missing_names}"
    )


@contextmanager
def database_connection():
    connection = psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        connect_timeout=3,
    )

    try:
        yield connection
        connection.commit()
    except Exception:
        if not connection.closed:
            connection.rollback()
        raise
    finally:
        connection.close()


def initialize_database():
    last_error = None

    for attempt in range(1, DB_CONNECT_RETRIES + 1):
        try:
            with database_connection() as connection:
                with connection.cursor() as cursor:
                    cursor.execute(
                        """
                        CREATE TABLE IF NOT EXISTS visits (
                            id SERIAL PRIMARY KEY,
                            total INTEGER NOT NULL DEFAULT 0
                        )
                        """
                    )
                    cursor.execute(
                        """
                        INSERT INTO visits (id, total)
                        VALUES (1, 0)
                        ON CONFLICT (id) DO NOTHING
                        """
                    )

            print("Database initialized successfully", flush=True)
            return

        except psycopg2.Error as error:
            last_error = error
            message = (
                "Database unavailable "
                f"(attempt {attempt}/{DB_CONNECT_RETRIES}): {error}"
            )
            print(message, flush=True)

            if attempt < DB_CONNECT_RETRIES:
                time.sleep(DB_CONNECT_DELAY)

    raise RuntimeError("Unable to initialize database") from last_error


def database_is_ready():
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            return cursor.fetchone()[0] == 1


def resolve_identity():
    hostname = socket.gethostname()

    try:
        ip_address = socket.gethostbyname(hostname)
    except socket.gaierror:
        return hostname, "unknown"

    try:
        reverse_name = dns.reversename.from_address(ip_address)
        answer = dns.resolver.resolve(reverse_name, "PTR")[0]
        hostname = str(answer).rstrip(".")
    except (dns.exception.DNSException, ValueError):
        pass

    return hostname, ip_address


HOSTNAME, IP_ADDRESS = resolve_identity()
START_TIME = time.time()
REQUEST_COUNT = 0
REQUESTS_BY_ENDPOINT = {}


class App(BaseHTTPRequestHandler):

    def send_json(self, status_code, data):
        payload = json.dumps(data).encode()

        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        global REQUEST_COUNT

        endpoint = self.path.split("?", 1)[0]
        REQUEST_COUNT += 1
        REQUESTS_BY_ENDPOINT[endpoint] = (
            REQUESTS_BY_ENDPOINT.get(endpoint, 0) + 1
        )

        try:
            if endpoint == "/visits":
                with database_connection() as connection:
                    with connection.cursor() as cursor:
                        cursor.execute(
                            """
                            UPDATE visits
                            SET total = total + 1
                            WHERE id = 1
                            RETURNING total
                            """
                        )
                        visits = cursor.fetchone()[0]

                self.send_json(200, {"visits": visits})

            elif endpoint == "/reset":
                with database_connection() as connection:
                    with connection.cursor() as cursor:
                        cursor.execute(
                            "UPDATE visits SET total = 0 WHERE id = 1"
                        )

                self.send_json(200, {"reset": "OK"})

            elif endpoint in ("/health", "/ready"):
                if database_is_ready():
                    self.send_json(200, {"database": "OK"})
                else:
                    self.send_json(503, {"database": "UNKNOWN"})

            elif endpoint == "/live":
                self.send_json(
                    200,
                    {"status": "alive", "version": APP_VERSION},
                )

            elif endpoint == "/version":
                self.send_json(200, {"version": APP_VERSION})

            elif endpoint == "/help":
                self.send_json(
                    200,
                    {
                        "help": "Endpoints",
                        "visits": "Increment and display visits",
                        "reset": "Reset visits to zero",
                        "health": "Check database connectivity",
                        "ready": "Readiness check",
                        "live": "Liveness check",
                        "version": "Display application version",
                        "whoami": "Display backend identity",
                        "metrics": "Display application metrics",
                    },
                )

            elif endpoint == "/whoami":
                self.send_json(
                    200,
                    {"hostname": HOSTNAME, "IP": IP_ADDRESS},
                )

            elif endpoint == "/metrics":
                uptime_seconds = int(time.time() - START_TIME)

                self.send_json(
                    200,
                    {
                        "hostname": HOSTNAME,
                        "ip": IP_ADDRESS,
                        "uptime_seconds": uptime_seconds,
                        "total_requests": REQUEST_COUNT,
                        "requests_by_endpoint": REQUESTS_BY_ENDPOINT,
                        "version": APP_VERSION,
                        "timestamp": datetime.datetime.now(
                            datetime.timezone.utc
                        ).isoformat(),
                    },
                )

            else:
                self.send_json(404, {"error": "not found"})

        except psycopg2.Error as error:
            self.send_json(
                503,
                {
                    "database": "OFFLINE",
                    "error": error.__class__.__name__,
                },
            )

        except Exception as error:
            print(f"Unhandled request error: {error}", flush=True)
            self.send_json(
                500,
                {
                    "error": "internal server error",
                    "type": error.__class__.__name__,
                },
            )


if __name__ == "__main__":
    initialize_database()

    server = HTTPServer(("0.0.0.0", 8080), App)
    print(
        f"devops-api-stack {APP_VERSION} listening on port 8080",
        flush=True,
    )
    server.serve_forever()
