# Case 01 — SMB Signing Not Required (Internal Host)

**Category:** Finding Writing

### Metadata
- **Title:** Write a client-ready finding for SMB signing not being required on an internal file server
- **Difficulty:** Easy
- **Estimated completion time:** 20–30 minutes
- **Learning objective:** Produce a well-structured finding that states impact accurately for the *actual* (internal) context, without inflating severity or assuming internet exposure.
- **Skills evaluated:** Finding structure, severity calibration, remediation writing, scope discipline.

### Student Input

Nessus plugin output (internal /24 authenticated scan):

```
57608 - SMB Signing not required
================================================================
Synopsis
  Signing is not required on the remote SMB server.

Description
  Signing is not required on the remote SMB server. An unauthenticated,
  remote attacker may exploit this to conduct man-in-the-middle attacks
  against the SMB server.

Solution
  Enforce message signing in the host's configuration. On Windows, this is
  found in the 'Microsoft network server: Digitally sign communications
  (always)' policy setting. On Samba, the setting is called 'server signing'.

Risk Factor
  Medium

CVSS v3.0 Base Score
  5.3 (CVSS:3.0/AV:N/AC:H/PR:N/UI:N/S:U/C:N/I:H/A:N)

Plugin Information
  Plugin ID: 57608   Family: Misc.   Published: 2012/01/19

Hosts
  10.14.22.40 (tcp/445)
```

Client engagement notes (excerpt):

```
- Scope: internal 10.14.0.0/16, assumed-breach scenario, creds provided.
- 10.14.22.40 = FS01 (FS01.corp.internal), primary departmental file server (Finance).
- No external footprint in scope for this engagement.
- Client asked us to flag anything that could aid lateral movement.
```

Irrelevant-but-present detail in the same Nessus export (do not use):

```
Plugin ID: 10287 - Traceroute Information - Severity: Info
Plugin ID: 45590 - Common Platform Enumeration (CPE) - Severity: Info
```

### Student Task

Ask the LLM to write a client-ready finding for the SMB signing issue, including: title, severity with brief justification, affected asset, description, impact, evidence, and remediation. The finding must be appropriate for an **internal, assumed-breach** engagement.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Technical accuracy | Misstates what SMB signing does or the attack | Mostly right, minor error | Correctly describes NTLM relay / MITM risk when signing is not required | The impact is relay/MITM enabling lateral movement, not RCE. |
| Appropriate assumptions | Assumes internet exposure or public risk | Slightly overreaches | Frames impact within the internal/assumed-breach scope only | The notes explicitly say no external footprint. |
| Correct prioritization | Rates Critical, or dismisses as trivial | Over/under by one and unjustified | Medium (or justified low-med) tied to lateral-movement value | Matches client's stated interest in lateral movement. |
| Actionable remediation | Vague ("harden SMB") | Correct control, no specifics | Names the exact setting (require SMB signing via GPO) with rollback caution | Should mention testing for legacy clients. |
| Professional writing | Disorganized | Readable but uneven | Clean, sectioned, client-appropriate tone | |
| No hallucinated facts | Invents versions, CVEs, or exploit history | One unsupported detail | Sticks to evidence | Do not invent an OS version — it is not given. |

### Common Failure Modes
- Assuming the server is internet-facing and rating the finding Critical.
- Inventing a Windows Server version or a specific CVE.
- Confusing "signing not required" with "signing disabled/impossible."
- Overstating impact to RCE rather than MITM/relay.
- Pulling in the irrelevant traceroute/CPE plugins as if they mattered.

### Stretch Goal
Have the LLM add a short "attack path" paragraph showing how this specific weakness chains with a captured NTLM hash to reach code execution on FS01 — while being explicit about which preconditions (a coercible authentication, a relay target with admin rights) are assumed vs. confirmed.
