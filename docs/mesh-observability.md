# RylanLabs Mesh Observability Specification

Maturity: Level 5 (Autonomous)  
Agent: Whitaker (Detection)

This document defines the metrics, logging patterns, and alerting thresholds for the GitHub Mesh.

## 1. Metrics Specification (Grafana)

The Whitaker agent tracks compliance states via `.audit/*.json` artifacts.

| Metric | Target | Success Threshold |
| :--- | :--- | :--- |
| Mesh Compliance Rate | % of satellite repos with GREEN status | >95% |
| Drift Remediation Time | Time from RED detection to PR creation | <15 mins |
| Secret Scan Pass Rate | % of PRs passing Gitleaks checks | 100% |
| Commit Sign Rate | % of commits in the last 30 days signed | 100% |

## 2. Logging Aggregation (Loki/Promtail)

Audit logs in `.audit/` must follow a structured JSON format to enable Loki aggregation.

**Log Pattern**:

\`\`\`json
{
  "timestamp": "ISO8601",
  "actor": "AgentName",
  "action": "Audit|Remediate|Cascade",
  "target": "RepoName",
  "status": "GREEN|RED|YELLOW",
  "details": "..."
}
\`\`\`

## 3. Alerting Thresholds

Alerts are routed to `#rylan-ops-alerts` via the `compliance-gate` outputs.

| Severity | Condition | Trigger |
| :--- | :--- | :--- |
| 🔴 CRITICAL | Drift detected in Tier 0 (Canon) | Immediate Slack/PagerDuty |
| 🟠 HIGH | Drift detected in Tier 1 (Inventory) | Immediate Slack |
| 🟡 MEDIUM | Failed remediation after 3 attempts | Daily Slack Summary |
| 🔵 INFO | Successful automatic remediation | Weekly Report |

---

*Note: This spec is authoritative for future Grafana/Loki implementations.*
