# Case 22 — Reusable Skill: A Nessus-to-Finding Converter

**Category:** Documentation and Reporting

### Metadata
- **Title:** Author one reusable prompt/skill that converts any Nessus finding into a client-ready finding
- **Difficulty:** Hard
- **Estimated completion time:** 50–70 minutes
- **Learning objective:** Design a *generalizable* prompt (a reusable skill), with fixed instructions, constraints, and an output template, that behaves correctly across varied inputs — including self-limiting on ambiguous evidence and downgrading noise — without per-input hand-tuning.
- **Skills evaluated:** Reusable Skills, few-shot/templating, constraint design, verification, hallucination resistance.

### Student Input

Three heterogeneous Nessus plugin outputs the skill must handle with the **same** prompt:

```
# INPUT A — clear, actionable
Plugin 57690 - Microsoft Windows SMBv1 Enabled
Host: 10.14.5.20 (tcp/445)   Risk: High
Synopsis: The remote host supports the SMBv1 protocol.
Plugin Output: The remote host supports SMB version 1. SMBv1 has known
  design weaknesses and is deprecated by Microsoft.
Solution: Disable SMBv1 and use SMBv2/3.
```

```
# INPUT B — version-based, backport-ambiguous
Plugin 100123 - OpenSSH < 8.0 Multiple Vulnerabilities
Host: 10.14.5.31 (tcp/22)    Risk: High
Synopsis: The SSH server is running an outdated version of OpenSSH.
Plugin Output: Detected version: OpenSSH 7.4 (banner).
Detection Method: Banner version check.
Note (from engagement): host is RHEL 7; vendor backports security fixes.
```

```
# INPUT C — informational / noise
Plugin 11219 - Nessus SYN scanner (Service Detection)
Host: 10.14.5.44 (tcp/443)   Risk: None / Info
Synopsis: It was possible to identify open ports and running services.
Plugin Output: Port 443/tcp was found to be open.
```

Constraints the skill must enforce:

```
- Output template: Title | Severity | Affected Asset | Description | Impact |
  Remediation | Confidence (Confirmed / Needs Validation / Informational).
- Never assign a severity higher than the evidence supports.
- Never invent versions, CVEs, or exposure not present in the input.
- If a finding is version-based only, mark Confidence = Needs Validation.
- If a finding is purely informational, downgrade it (do not present as a risk).
```

### Student Task

Ask the LLM to help design **one reusable prompt/skill** (fixed instructions + template + constraints) that converts a Nessus finding into a client-ready finding — then run that same skill, unchanged, against Inputs A, B, and C and show the three outputs.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Generalizable design | Writes three bespoke answers, no reusable skill | A skill that only fits one input | One prompt/skill with fixed instructions + template that is genuinely input-agnostic | The core of the case. |
| Correct on A (actionable) | Mis-rates or garbles | Minor | Produces a clean High SMBv1 finding, Confidence = Confirmed | |
| Correct on B (ambiguous) | Declares confirmed-vulnerable on the banner | Hedges weakly | Marks Confidence = Needs Validation and notes the backport caveat — *from the skill's own rules, not hand-editing* | |
| Correct on C (noise) | Presents the port scan as a risk finding | Ambiguous | Downgrades to Informational per the skill's constraint | |
| Constraint adherence | Violates severity/no-invention rules | One slip | Honors every stated constraint across all three | |
| Hallucination resistance | Invents CVEs/versions to enrich outputs | One | Adds nothing beyond the evidence | |

### Common Failure Modes
- Producing three one-off answers instead of a single reusable skill.
- A skill that works on the clean input (A) but over-claims on the ambiguous one (B).
- Presenting the informational service-detection (C) as a rateable weakness.
- Baking Input A's specifics into the "reusable" instructions (over-fitting).
- Letting the skill invent CVE numbers or CVSS scores to look thorough.

### Stretch Goal
Feed the finished skill a deliberately out-of-distribution input (e.g., a Burp Suite web-app finding rather than a Nessus plugin) and evaluate whether it degrades gracefully — mapping what it can, flagging what it cannot, and refusing to fabricate the missing Nessus-style fields — versus hallucinating a well-formed but false finding.
