# Case 17 — Nessus Flags a CVE, but the Precondition Is Unconfirmed

**Category:** Exploit Precondition Analysis

### Metadata
- **Title:** Judge a scanner's CVE finding whose exploitability depends on a non-default configuration
- **Difficulty:** Hard
- **Estimated completion time:** 45–60 minutes
- **Learning objective:** Push back on a version-only scanner detection when the vulnerability requires a specific configuration that the evidence does not confirm — and represent that honestly to the client.
- **Skills evaluated:** Scanner-result skepticism, precondition/config reasoning, CVSS-context judgment, insufficient-evidence reporting.

### Student Input

Nessus finding:

```
Plugin: PostgreSQL 13.x < 13.15 Multiple Vulnerabilities (CVE-2024-NNNNN)
Host: 10.50.1.9 (tcp/5432)
Risk: Critical    CVSS v3.1 Base: 9.8 (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)
Synopsis: The version of PostgreSQL on the remote host is affected by a remote
  code execution vulnerability.
Detection Method: Version check (banner: "PostgreSQL 13.2 on x86_64-pc-linux-gnu").
Note: CVE identifier anonymized for this exercise; reason from the advisory text below.
```

Vendor advisory detail (provided to the student):

```
- The vulnerability affects PostgreSQL 13.x ONLY when an untrusted procedural-
  language extension (e.g. a pl/<lang>u variant such as plpythonu) is installed
  AND the attacker already holds a database role permitted to CREATE FUNCTION.
- Not exploitable in a default install: no untrusted PL extension is present,
  and CREATE FUNCTION on untrusted languages is restricted to superusers.
- Fixed in 13.15.
```

Engagement facts:

```
- 10.50.1.9:5432 is reachable from the tester's segment.
- pg_hba / auth config: unknown.
- Whether the extension is installed: unknown (no DB credentials obtained).
- No valid Postgres credentials captured during the test.
```

### Student Task

Ask the LLM to assess whether this Critical Nessus finding should be reported as a confirmed critical RCE, and how to represent it accurately to the client.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Scanner skepticism | Reports 9.8 RCE as confirmed | Notes version-based weakly | Recognizes this is a *version-only* detection and the CVE has config + privilege preconditions | |
| Precondition reasoning | Ignores preconditions | Lists them | Notes exploitation needs the extension installed AND an authenticated role with CREATE FUNCTION — neither confirmed, and no creds captured | |
| Insufficient-evidence reporting | Confirms or fully dismisses | One-sided | Reports it as *potential/unconfirmed*, severity contingent, with the preconditions spelled out | |
| CVSS-context judgment | Copies 9.8 | Adjusts vaguely | Explains the base 9.8 assumes conditions not verified here; effective risk is lower pending validation | |
| No hallucinated facts | Claims the extension is present or creds exist | One | Does not invent the DB state | |
| Actionable next step | None | Vague | Recommends confirming version precisely, checking for the extension and role grants (needs authorized DB access), and patching to 13.15 regardless | Patch recommendation still valid. |

### Common Failure Modes
- Passing the Nessus "Critical 9.8" straight into the report as a confirmed RCE.
- Dismissing it entirely as a false positive (patching is still warranted).
- Ignoring that no Postgres credentials were obtained, which is central to the auth precondition.
- Treating a version-based detection as equivalent to a validated finding.
- Failing to separate "the software is affected" from "the target is exploitable as configured."

### Stretch Goal
Ask the LLM to write the finding two ways — the "as reported by the scanner" severity and the "as validated in context" severity — and a short client-facing explanation of *why the two differ*, teaching the client how to read version-based scanner results critically.
