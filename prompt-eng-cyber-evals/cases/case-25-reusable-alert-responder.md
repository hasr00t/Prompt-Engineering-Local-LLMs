# Case 25. Reusable Skill: An Alert-to-Ticket Responder

**Category:** Log Analysis / SOC Operations

### Metadata
- **Title:** Author one reusable prompt/skill that converts any SIEM alert into a structured investigation ticket response
- **Difficulty:** Hard
- **Estimated completion time:** 50-70 minutes
- **Learning objective:** Design a generalizable prompt (a reusable skill), with fixed instructions, constraints, and an output template, that produces correct investigation responses across varied alert types, including recognizing ambiguity, adjusting priority based on context, and recommending appropriate next steps, without per-input hand-tuning.
- **Skills evaluated:** Reusable Skills, few-shot/templating, constraint design, verification, hallucination resistance, evidence-based reasoning.

### Student Input

Three heterogeneous SIEM alerts the skill must handle with the **same** prompt:

```
# INPUT A — clear true positive
Alert: Telnet Authentication Bypass Detected
Severity: Critical
Timestamp: 2026-08-14 03:42:17 UTC
Source IP: 198.51.100.47 (external, no prior history)
Destination: 10.14.5.15:23 (linux-legacy-01, internal server)
Rule: CVE-2026-24061 NEW_ENVIRON -f root detected in telnet session
Auth Log: Root login via telnetd at 03:42:19 UTC, no password
  authentication recorded.
Network Log: 4.2 MB data transfer from 10.14.5.15 to 198.51.100.47
  over 12 minutes following login.
Context: Host runs legacy inventory application. Telnet service is
  required per change advisory CA-2026-0142.
```

```
# INPUT B — ambiguous alert
Alert: Multiple Failed SSH Authentication Attempts
Severity: Medium
Timestamp: 2026-08-14 09:15:00 - 09:47:00 UTC
Source IP: 203.0.113.88
Destination: 10.14.5.31:22 (jump-box-01)
Auth Log: 47 failed login attempts for user "svc_backup" over 32
  minutes. All attempts used password authentication. No successful
  logins from this source during this window.
Context: 203.0.113.88 is registered to Acme Managed Services, the
  client's contracted backup vendor. svc_backup is a legitimate
  service account used by Acme for nightly backup operations.
Previous Activity: This source IP has authenticated successfully
  on 12 of the last 14 days between 01:00-02:00 UTC.
```

```
# INPUT C — context-dependent alert
Alert: Cleartext Protocol on Internet-Facing Host
Severity: Low
Timestamp: 2026-08-14 14:00:03 UTC
Source: Scheduled vulnerability scan (Nessus)
Destination: 10.14.5.44:23 (dmz-legacy-01)
Finding: Telnet service (port 23/tcp) is running and accepting
  connections on a host in the external DMZ.
Network Context: dmz-legacy-01 has a firewall rule permitting
  inbound TCP/23 from any source. The host is reachable from the
  internet.
Asset Owner: Facilities team. Host manages building HVAC controls.
Previous Tickets: None for this host.
```

Constraints the skill must enforce:

```
- Output template: Ticket Title | Priority | Alert Summary |
  Investigation Steps | Findings | Containment Actions |
  Escalation (Yes/No with justification) | Recommended Next Steps.
- Never close a ticket without documenting investigation steps taken.
- Never classify an alert as a false positive without stating the
  specific evidence that rules out malicious activity.
- If the alert data is insufficient to make a determination,
  recommend specific follow-up actions rather than guessing.
- Do not speculate about attacker intent beyond what the evidence shows.
- Consider asset criticality and network exposure when assessing priority.
```

### Student Task

Ask the LLM to help design **one reusable prompt/skill** (fixed instructions + template + constraints) that converts a SIEM alert into a structured investigation ticket response. Then run that same skill, unchanged, against Inputs A, B, and C and show the three outputs.

### Evaluation Rubric (0-2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Generalizable design | Writes three bespoke tickets, no reusable skill | A skill that only fits one alert type | One prompt/skill with fixed instructions + template that is genuinely input-agnostic | The core of the case. |
| Correct on A (true positive) | Misses the compromise indicators or downplays severity | Identifies the compromise but weak on containment/escalation | Identifies the auth bypass, data exfiltration, and recommends immediate containment and escalation | Clear IOCs: external IP, no auth, data transfer out. |
| Correct on B (ambiguous) | Declares brute force and recommends blocking the IP without considering the vendor context | Identifies one side (suspicious or legitimate) but not both | Identifies both the suspicious pattern (47 failures, unusual time) and the mitigating context (known vendor, legitimate account) and recommends targeted investigation | The litmus test. Must not panic or dismiss. |
| Correct on C (context-dependent) | Echoes the scanner's Low severity without considering exposure | Notes the telnet service but doesn't connect exposure to asset criticality | Recognizes that internet-facing telnet on a host controlling physical systems warrants elevated priority, regardless of scanner severity | Tests whether the skill considers context beyond what the alert says. |
| Constraint adherence | Skips investigation steps or speculates about attacker intent | One slip | Honors every stated constraint across all three inputs | |
| Hallucination resistance | Invents IOCs, attribution, or remediation steps not supported by evidence | One instance | Adds nothing beyond the evidence; uses "unknown" or recommends follow-up where data is missing | |

### Common Failure Modes
- Producing three one-off ticket responses instead of a single reusable skill.
- Treating Input B as a confirmed brute force attack and recommending the vendor's IP be blocked, ignoring the vendor relationship and historical context.
- Echoing the scanner's Low severity for Input C without factoring in internet exposure and the HVAC control function.
- Recommending containment actions for Input B (ambiguous) with the same urgency as Input A (confirmed compromise).
- Inventing attacker attribution, threat actor names, or malware families not present in the evidence.
- Closing Input B as a false positive because the source is a known vendor, without investigating why the failures are happening outside the normal time window.

### Stretch Goal
Feed the finished skill a deliberately out-of-distribution input, like a raw Nessus plugin finding or a user-submitted phishing report. Evaluate whether it degrades gracefully by mapping what it can, flagging what it cannot, and refusing to fabricate the missing alert-style fields, versus hallucinating a well-formed but false ticket response.
