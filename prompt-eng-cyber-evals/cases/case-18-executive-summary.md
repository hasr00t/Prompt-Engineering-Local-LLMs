# Case 18 — Executive Summary From a Set of Findings

**Category:** Documentation and Reporting

### Metadata
- **Title:** Write an executive summary from a list of penetration-test findings
- **Difficulty:** Easy
- **Estimated completion time:** 25–35 minutes
- **Learning objective:** Synthesize findings into a business-readable executive summary that conveys risk and priorities without technical dump or exaggeration.
- **Skills evaluated:** Synthesis, audience calibration, prioritization, faithful summarization.

### Student Input

Findings list (from the technical report):

```
1. [High]   Domain user can dump AD credentials via unconstrained delegation on APP03.
2. [High]   SMB signing not required on 6 servers (relay/lateral movement).
3. [Medium] Kerberoastable service account 'svc_sql' with a weak password (cracked offline).
4. [Medium] Missing MFA on the VPN for 12% of accounts.
5. [Low]    Verbose error messages disclose stack traces on the intranet portal.
6. [Info]   TLS 1.0/1.1 enabled on an internal legacy app.
```

Engagement context:

```
- Internal assumed-breach test. Overall result: domain compromise was achieved
  in the lab by chaining findings 3 -> 2 -> 1.
- Audience for the summary: CISO + non-technical risk committee.
- Test duration: 5 days.
```

### Student Task

Ask the LLM to write a one-page executive summary: overall risk posture, what was achieved, the key themes, and top priorities — for a non-technical leadership audience.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Faithful summarization | Adds findings/severities not in the list | Minor drift | Accurately reflects the six findings and the achieved domain compromise | No new severities. |
| Audience calibration | Jargon-heavy | Uneven | Plain-language, business-impact framing; defines the few unavoidable terms | |
| Prioritization | Flat or wrong order | Loose | Leads with the compromise chain (3→2→1) as the headline risk | |
| Correct impact framing | Over- or under-states | Slight | Conveys "full domain compromise was achievable" accurately, without sensationalism | |
| No hallucinated facts | Invents metrics, timelines, or attacker attribution | One | Uses only given context (5 days, 12%, etc.) | |
| Professional writing | Poor structure | OK | Clean one-pager: posture → what happened → themes → priorities | |

### Common Failure Modes
- Inventing a risk score, a "number of vulnerabilities," or a comparison to industry peers.
- Burying the domain-compromise headline under a list of every finding.
- Writing at engineer-level detail for a risk committee.
- Overstating ("catastrophic," "imminent breach") beyond what a lab chain shows.
- Reordering priorities so a Low finding appears to matter more than the chain.

### Stretch Goal
Ask the LLM to add a short "themes" paragraph that abstracts the individual findings into 2–3 root causes (e.g., weak service-account hygiene, missing SMB hardening, incomplete MFA coverage) — demonstrating synthesis rather than restatement.
