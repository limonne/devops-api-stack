import argparse
import json
import math

import requests


def parse_args():
    parser = argparse.ArgumentParser(
        description="Check API liveness, readiness and version"
    )
    parser.add_argument(
        "--environment",
        choices=["compose", "lab", "staging", "production"],
        default="lab",
        help="Environment to analyse",
    )
    parser.add_argument(
        "--config",
        default="config/api-checks.json",
        help="Path to the configuration file",
    )
    parser.add_argument(
        "--output",
        default="/tmp/devops-api-check.json",
        help="Path to the JSON report",
    )
    parser.add_argument(
        "--timeout",
        default=3.0,
        type=float,
        help="HTTP timeout in seconds",
    )

    args = parser.parse_args()

    if not math.isfinite(args.timeout) or args.timeout <= 0:
        parser.error("--timeout must be a positive, finite number")

    return args


def load_inventory(path):
    with open(path, encoding="utf-8") as file:
        return json.load(file)


def check_endpoint(base_url, host, check_config, timeout_seconds):
    url = base_url.rstrip("/") + check_config["path"]

    result = {
        "url": url,
        "status_code": None,
        "expected": check_config["expected"],
        "actual": None,
        "result": "ERROR",
        "error": None,
    }

    try:
        response = requests.get(
            url,
            headers={"Host": host},
            timeout=timeout_seconds,
        )
    except requests.exceptions.Timeout:
        result["error"] = "Request timed out"
        return result
    except requests.exceptions.RequestException as error:
        result["error"] = str(error)
        return result

    result["status_code"] = response.status_code

    if response.status_code != 200:
        result["error"] = f"Unexpected HTTP status: {response.status_code}"
        return result

    try:
        body = response.json()
    except requests.exceptions.JSONDecodeError:
        result["error"] = "Response is not valid JSON"
        return result

    if not isinstance(body, dict):
        result["error"] = "Expected a JSON object"
        return result

    result["actual"] = body.get(check_config["field"])

    if result["actual"] != result["expected"]:
        result["error"] = "Response value does not match expected value"
        return result

    result["result"] = "OK"
    return result


def main():
    args = parse_args()

    try:
        inventory = load_inventory(args.config)
        target = inventory[args.environment]

        for field in ("base_url", "host", "expected_version"):
            value = target[field]
            if not isinstance(value, str) or not value.strip():
                raise ValueError(f"{field} must be a non-empty string")

        base_url = target["base_url"]
        host = target["host"]
        expected_version = target["expected_version"]
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f"Invalid configuration: {error}")
        return 2

    checks = {
        "live": {
            "path": "/api/live",
            "field": "status",
            "expected": "alive",
        },
        "ready": {
            "path": "/api/ready",
            "field": "database",
            "expected": "OK",
        },
        "version": {
            "path": "/api/version",
            "field": "version",
            "expected": expected_version,
        },
    }

    results = []
    totals = {
        "OK": 0,
        "ERROR": 0,
    }

    for check_name, check_config in checks.items():
        record = check_endpoint(
            base_url,
            host,
            check_config,
            args.timeout,
        )
        record["name"] = check_name
        results.append(record)

        if record["result"] == "OK":
            totals["OK"] += 1
        else:
            totals["ERROR"] += 1

        print(
            f"{check_name}: HTTP {record['status_code']} "
            f"-> {record['result']}"
        )

    report = {
        "environment": args.environment,
        "base_url": base_url,
        "host": host,
        "expected_version": expected_version,
        "results": results,
        "totals": totals,
    }

    try:
        with open(args.output, "w", encoding="utf-8") as file:
            json.dump(report, file, indent=2)
    except OSError as error:
        print(f"Cannot write report: {error}")
        return 2

    print(f"Report saved to: {args.output}")

    if totals["ERROR"] > 0:
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
