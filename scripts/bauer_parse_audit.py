#!/usr/bin/env python3
"""
Bauer CI Audit Log Parser v1.0.0
Guardian: Bauer | Ministry: Verification & Audit
Compliance: Seven Pillars §4 (Audit Logging), Trinity v1.0.0
"""

import json
import sys
from pathlib import Path
from typing import Any, Dict, List
from datetime import datetime, timezone


def parse_audit_logs(audit_dir: Path) -> Dict[str, Any]:
    """Aggregate all audit logs into single summary"""
    violations: List[Dict[str, Any]] = []
    duration_total = 0
    files_scanned = 0

    for audit_file in audit_dir.glob("*.json"):
        # Skip the summary itself if it exists
        if audit_file.name == "ci-summary.json":
            continue

        try:
            with open(audit_file) as f:
                data = json.load(f)

            # Extract violations
            if "violations" in data:
                for v in data["violations"]:
                    v["source_file"] = audit_file.name
                    violations.append(v)

            # Sum durations
            if "duration_ms" in data:
                duration_total += data["duration_ms"]

            files_scanned += 1
        except (json.JSONDecodeError, IOError) as e:
            print(f"⚠️  Warning: Failed to parse {audit_file}: {e}", file=sys.stderr)

    # Determine status
    critical_count = len([v for v in violations if v.get("severity") == "critical"])
    warning_count = len([v for v in violations if v.get("severity") == "warning"])
    status = "fail" if critical_count > 0 else "pass"

    return {
        "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "guardian": "Bauer",
        "ministry": "Verification & Audit",
        "status": status,
        "duration_ms": duration_total,
        "files_scanned": files_scanned,
        "violations": violations,
        "critical_count": critical_count,
        "warning_count": warning_count,
        "summary": f"{critical_count} critical, {warning_count} warnings across {files_scanned} audit files",
    }


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Aggregate Bauer audit logs for CI")
    parser.add_argument("--input", required=True, help="Audit directory path")
    parser.add_argument("--output", required=True, help="Output JSON file path")
    parser.add_argument(
        "--fail-on",
        choices=["critical", "warning", "none"],
        default="critical",
        help="Exit code failure threshold",
    )
    args = parser.parse_args()

    audit_dir = Path(args.input)
    summary: Dict[str, Any]

    if not audit_dir.exists():
        # If directory doesn't exist, we can't audit, but don't fail CI if no results yet
        print(f"⚠️  Warning: Audit directory not found: {audit_dir}", file=sys.stderr)
        summary = {
            "status": "pass",
            "duration_ms": 0,
            "files_scanned": 0,
            "violations": [],
            "critical_count": 0,
            "warning_count": 0,
            "summary": "No audit files found (directory missing)",
        }
    else:
        summary = parse_audit_logs(audit_dir)

    # Write summary
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(summary, f, indent=2)

    # Typed views for mypy and logic
    crit_count: int = summary["critical_count"]
    warn_count: int = summary["warning_count"]
    status_val: str = str(summary.get("status", "fail"))

    # Console output
    print("📊 Bauer Audit Summary")
    print(f"   Status: {'✅ PASS' if status_val == 'pass' else '❌ FAIL'}")
    print(f"   Duration: {summary.get('duration_ms', 0)}ms")
    print(f"   Files Scanned: {summary.get('files_scanned', 0)}")
    print(f"   {summary.get('summary', 'No summary available')}")

    # Exit code logic
    if args.fail_on == "critical" and crit_count > 0:
        print(f"\n❌ Failing due to {crit_count} critical violations", file=sys.stderr)
        sys.exit(1)
    elif args.fail_on == "warning" and warn_count > 0:
        print(f"\n⚠️  Failing due to {warn_count} warnings", file=sys.stderr)
        sys.exit(1)

    print(f"\n✅ Audit summary written to: {output_path}")
    sys.exit(0)
