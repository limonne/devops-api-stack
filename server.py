from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import socket
import psycopg2
import dns.resolver
import dns.reversename

DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")

conn = psycopg2.connect(
    host=DB_HOST,
    database=DB_NAME,
    user=DB_USER,
    password=DB_PASS,
)

cur = conn.cursor()

cur.execute("""
CREATE TABLE IF NOT EXISTS visits (
    id SERIAL PRIMARY KEY,
    total INTEGER
)
""")

conn.commit()

cur.execute("SELECT COUNT(*) FROM visits")
count = cur.fetchone()[0]

if count == 0:
    cur.execute("INSERT INTO visits (total) VALUES (0)")
    conn.commit()

p_ip = socket.gethostbyname(socket.gethostname())
hostnm = dns.resolver.query(dns.reversename.from_address(p_ip),"PTR")[0]

class App(BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path == "/visits":
            cur.execute("SELECT total FROM visits WHERE id=1")
            visits = cur.fetchone()[0]

            visits += 1

            cur.execute(
                "UPDATE visits SET total=%s WHERE id=1",
                (visits,),
            )

            conn.commit()

            data = {"visits": visits}
            self.send_response(200)

        elif self.path == "/reset":
            cur.execute("UPDATE visits SET total=0")
            conn.commit()

            data = {"reset": "OK"}
            self.send_response(200)

        elif self.path == "/health":
            try:
                cur.execute("SELECT 1")
                result = cur.fetchone()[0]

                if result == 1:
                    data = {"database": "OK"}
                else:
                    data = {"database": "UNKNOWN"}

                self.send_response(200)

            except Exception as error:
                data = {"database": "OFFLINE", "error": str(error)}
                self.send_response(500)

        elif self.path == "/version":
            data = {"version": "2.1"}
            self.send_response(200)

        elif self.path == "/help":
            data = {
                "help": "Endpoints",
                "visits": "Display the number of visits",
                "reset": "Reset the number of visits to zero",
                "health": "Display DB connection status",
            }
            self.send_response(200)

        elif self.path == "/whoami":
            data = {
                    "hostname": str(hostnm), 
                    "IP": str(p_ip)
                    }
            self.send_response(200)

        else:
            data = {"error": "not found"}
            self.send_response(404)

        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())


server = HTTPServer(("0.0.0.0", 8080), App)
server.serve_forever()
