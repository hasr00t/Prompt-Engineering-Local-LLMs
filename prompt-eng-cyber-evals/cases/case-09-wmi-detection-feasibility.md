# Case 09 — Detection That Overlaps Legitimate Admin Activity

**Category:** Detection Engineering

### Metadata
- **Title:** Decide whether reliable detection is even possible from the given telemetry
- **Difficulty:** Hard
- **Estimated completion time:** 45–55 minutes
- **Learning objective:** Recognize when the requested detection cannot cleanly separate malicious from benign with the available fields, and say so — proposing baselining/enrichment instead of shipping a rule that will drown the SOC.
- **Skills evaluated:** Detection feasibility judgment, false-positive realism, recognizing insufficient telemetry, alternative-control proposal.

### Student Input

Ask: "Write a detection for lateral movement via WMI."

Available Sysmon telemetry (only these fields are collected in this environment):

```
Sysmon EID 1 (ProcessCreate): Image, CommandLine, ParentImage, User
- WmiPrvSE.exe frequently spawns processes as part of normal WMI usage.
```

Sample events over one hour:

```
Image=C:\Windows\System32\wbem\WmiPrvSE.exe  ParentImage=C:\Windows\System32\services.exe  User=NT AUTHORITY\SYSTEM
  -> spawns: cmd.exe /c ipconfig /all           User=CORP\helpdesk    (ticketed: workstation triage)
  -> spawns: powershell.exe Get-Service         User=CORP\svc_monitor (monitoring account, runs constantly)
  -> spawns: cmd.exe /c whoami                   User=CORP\jsmith      (unknown context)
```

Note on what is NOT collected:

```
- No Sysmon EID 3 (network connections).
- No Sysmon EID 19/20/21 (WMI event subscription).
- No Windows Security 4688 with parent, no command-line auditing on servers.
- No source-host attribution (can't tell which host initiated the WMI call).
```

### Student Task

Ask the LLM to write a detection for WMI-based lateral movement using only the available telemetry, or to determine whether that is feasible.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Feasibility judgment | Ships a confident `ParentImage=WmiPrvSE.exe` rule as the answer | Notes FPs weakly | Concludes that with only local EID 1 and no source attribution, this telemetry cannot reliably separate lateral WMI from benign WMI | The intended outcome. |
| Recognizing insufficient telemetry | Ignores the "not collected" note | Mentions it | Uses the gap list to justify the conclusion (no source host, no network, no WMI-subscription events) | |
| False-positive realism | Claims low FPs | Some | Explains `WmiPrvSE.exe`-parented processes are routine (monitoring, helpdesk) and a naive rule alerts constantly | |
| Actionable alternative | None | Vague | Recommends enabling the missing telemetry (EID 3, command-line auditing, source correlation) and/or baselining WmiPrvSE children | Turns "no" into a path forward. |
| Evidence-based reasoning | Asserts which sample event is the attack | Guesses | Notes none of the three samples can be confirmed malicious from these fields alone | The `jsmith` one is tempting but unconfirmed. |
| No hallucinated facts | Invents fields not collected | One | Works within the stated telemetry | |

### Common Failure Modes
- Shipping `ParentImage|endswith: \WmiPrvSE.exe` as a working detection — it will fire on all normal WMI.
- Declaring the `whoami`/`jsmith` event the attack without basis.
- Ignoring that no source-host attribution exists, which is central to detecting *lateral* movement.
- Recommending a rule and then burying "may have false positives" instead of leading with feasibility.
- Inventing EID 3 / subscription data that the environment does not collect.

### Stretch Goal
Ask the LLM to design a *phased* plan: (1) telemetry to enable first and why, (2) a baselining approach for legitimate `WmiPrvSE.exe` children, (3) the higher-fidelity detection it would build only *after* that data exists — making explicit that the good rule depends on data not yet available.
