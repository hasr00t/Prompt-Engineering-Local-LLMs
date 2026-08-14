# Case 03 — "Decommissioned" Host That Is Still Answering

**Category:** Finding Writing

### Metadata
- **Title:** Reconcile contradictory evidence when a host the client called decommissioned responds to scans
- **Difficulty:** Hard
- **Estimated completion time:** 40–50 minutes
- **Learning objective:** Handle directly contradictory evidence in a finding — surface the contradiction, avoid picking a side without basis, and drive toward validation.
- **Skills evaluated:** Handling contradiction, professional skepticism, evidence-based reasoning, actionable next steps.

### Student Input

Client asset note (from kickoff):

```
- 10.14.9.15 (LEGACY-APP01): DECOMMISSIONED 2025-Q4. Ignore if seen.
```

nmap results from the current engagement:

```
$ nmap -Pn -sV -p- 10.14.9.15
Starting Nmap 7.94 ( https://nmap.org ) at 2026-07-10 09:22 UTC
Nmap scan report for 10.14.9.15
Host is up (0.0011s latency).
Not shown: 65532 filtered tcp ports (no-response)

PORT     STATE SERVICE       VERSION
80/tcp   open  http          Microsoft IIS httpd 8.5
445/tcp  open  microsoft-ds?
3389/tcp open  ms-wbt-server Microsoft Terminal Services
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

$ crackmapexec smb 10.14.9.15
SMB  10.14.9.15  445  WIN-Q3FK9DLMN2P  [*] Windows Server 2012 R2 Standard 9600 x64 (name:WIN-Q3FK9DLMN2P) (domain:WIN-Q3FK9DLMN2P) (signing:False) (SMBv1:True)
```

Additional signal (present, ambiguous):

```
- crackmapexec reports domain:WIN-Q3FK9DLMN2P (identical to the hostname),
  meaning the host is in a WORKGROUP, not joined to the corp domain. The
  default-style computer name suggests it was never brought under management.
- DNS: no PTR record for 10.14.9.15.
- The IP was in-scope per the provided /16, but was NOT on the "live hosts"
  list the client sent two weeks before the test.
```

### Student Task

Ask the LLM to write a finding (or a decision on whether a finding is warranted) about 10.14.9.15, given that the client said it was decommissioned but it is clearly responding.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Handling contradiction | Silently trusts the client note and drops the host | Picks the scan blindly, ignores the note | Explicitly names the contradiction and treats "still live" as the observed fact | The core skill. |
| Appropriate assumptions | Concludes it is a rogue/attacker host | Speculates without labeling | Lists plausible explanations (incomplete decommission, reused IP, shadow asset) as hypotheses, not conclusions | |
| Technical accuracy | Misreads the services | Minor error | Correctly notes an exposed Windows host with RDP/SMB (signing off) is a live risk regardless of its "decommissioned" label | |
| Correct prioritization | Dismisses as out-of-scope noise | Rates without justification | Treats a responsive, unmanaged Windows host with RDP as a meaningful finding; justifies severity | An unmanaged asset is often *higher* risk. |
| Actionable remediation | None, or "delete it" | Vague | Recommends confirming ownership/status, then either true decommission or bringing under management/patching | |
| Evidence-based reasoning | Overclaims compromise | Weak | Distinguishes "confirmed live and exposed" from "unconfirmed why" | |

### Common Failure Modes
- Deferring to the client note and omitting the host entirely.
- Swinging the other way and asserting it is attacker infrastructure.
- Rating it low because it was "supposed to be" gone.
- Inventing a hostname, patch level, or breach narrative.
- Failing to state the single most useful next step: confirm current ownership/status with the client.

### Stretch Goal
Have the LLM write two short paragraphs: (1) the finding as it would appear in the report, and (2) a separate note for the *verbal* readout to the client's IT lead, phrased to prompt investigation without accusing anyone of a process failure.
