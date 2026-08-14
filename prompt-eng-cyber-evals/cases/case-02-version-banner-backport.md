# Case 02 — Version Banner That Might Be a Backport

**Category:** Finding Writing

### Metadata
- **Title:** Write a finding for an "outdated" service where the version banner may be misleading
- **Difficulty:** Medium
- **Estimated completion time:** 30–40 minutes
- **Learning objective:** Recognize that a version string alone does not prove vulnerability, and write a finding that reflects that uncertainty rather than asserting a CVE match.
- **Skills evaluated:** Evidence-based reasoning, handling ambiguity, remediation writing, CVSS/severity restraint.

### Student Input

nmap service/version scan:

```
$ nmap -sV -p 22,80,443 198.51.100.23
Starting Nmap 7.94 ( https://nmap.org ) at 2026-07-10 09:14 UTC
Nmap scan report for 198.51.100.23
Host is up (0.039s latency).

PORT    STATE SERVICE  VERSION
22/tcp  open  ssh      OpenSSH 7.4 (protocol 2.0)
80/tcp  open  http     Apache httpd 2.4.6 ((CentOS))
443/tcp open  ssl/http Apache httpd 2.4.6 ((CentOS))

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 11.83 seconds
```

Client note (excerpt):

```
- Host is a RHEL/CentOS 7 web server. Patch policy: monthly yum updates.
- Vendor confirms system is fully patched per RHEL 7 lifecycle as of last month.
```

Analyst scratch note (present in the input, unverified):

```
"httpd 2.4.6 is ancient (2013), tons of CVEs. Probably vuln to everything."
```

### Student Task

Ask the LLM to write a finding assessing whether the observed Apache and OpenSSH versions represent a real vulnerability, and what to recommend. The output should be defensible if the client pushes back with "our system is fully patched."

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Technical accuracy | Treats banner version as ground truth vulnerability | Notes backports vaguely | Correctly explains RHEL/CentOS backports security fixes while keeping the base version string (2.4.6, 7.4) | This is the crux of the case. |
| No hallucinated facts | Lists specific CVEs as confirmed present | Lists CVEs as "possible" without over-claiming | Does not assert any CVE is exploitable without version-accurate confirmation | |
| Appropriate assumptions | Concludes "vulnerable to everything" per the scratch note | Hedges weakly | Treats the scratch note as an untested hypothesis, not evidence | Tests whether students filter their own noise. |
| Correct prioritization | High/Critical on banner alone | Medium with weak basis | Informational/Low pending confirmation, or clearly conditional severity | The honest answer is "unconfirmed." |
| Actionable remediation | "Upgrade Apache" (wrong for backport model) | Generic patching advice | Recommends confirming the *package* patch level (`rpm -q`, `httpd -v` + errata check), not a source upgrade | |
| Evidence-based reasoning | Ignores the patch-policy note | Mentions it | Weighs banner vs. patch policy and states what would resolve the ambiguity | |

### Common Failure Modes
- Mapping the banner version straight to a CVE list and declaring the host vulnerable.
- Recommending a source upgrade to a newer Apache on a distro that backports.
- Absorbing the analyst scratch note ("vuln to everything") as fact.
- Rating severity High on version strings alone.

### Stretch Goal
Ask the LLM to draft the exact commands and evidence it would request from the client to *definitively* resolve whether the host is vulnerable (e.g., `rpm -q --changelog httpd | head`, RHSA cross-reference), and to specify what result would confirm vs. clear the finding.
