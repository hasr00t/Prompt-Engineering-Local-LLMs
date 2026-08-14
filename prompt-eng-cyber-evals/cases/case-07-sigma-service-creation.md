# Case 07 — Sigma Rule for Service-Creation Persistence

**Category:** Detection Engineering

### Metadata
- **Title:** Draft a Sigma rule to detect persistence via Windows service creation
- **Difficulty:** Medium
- **Estimated completion time:** 30–40 minutes
- **Learning objective:** Translate a described behavior into a valid, correctly-scoped Sigma rule with real field names and a sensible false-positive section.
- **Skills evaluated:** Sigma syntax, log-source selection, field accuracy, false-positive awareness.

### Student Input

Behavior description from a threat brief:

```
Operators install a new Windows service pointing at a binary dropped in a
world-writable path (C:\Windows\Temp or C:\Users\Public) to survive reboots.
Observed both via the Service Control Manager (System log Event ID 7045) and
via Sysmon process creation of sc.exe / new service registry writes.
```

Reference field data the student is given:

```
- Windows System log, Event ID 7045: fields ServiceName, ImagePath, ServiceType, StartType
- Sysmon Event ID 1 (ProcessCreate): Image, CommandLine, ParentImage
- Sysmon Event ID 13 (RegistryValueSet): TargetObject, Details
```

### Student Task

Ask the LLM to write a Sigma rule that detects service creation where the service binary path lives in a world-writable/temp location, using Event ID 7045. Include a false-positives section and an appropriate level.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Sigma validity | Won't parse; invented top-level keys | Minor schema issues | Valid structure (title, logsource, detection, condition, level, tags) | |
| Field accuracy | Wrong field/log source (e.g., Security log, wrong EID) | One wrong field | Correct `logsource` (product: windows, service: system) with `EventID: 7045` in the detection selection, and real fields (`ImagePath`, `ServiceName`) | EID belongs in detection, not logsource. |
| Detection logic | Matches everything or nothing | Overly broad/narrow | Matches `ImagePath` containing `\Windows\Temp\` or `\Users\Public\` with a sound `condition` | |
| False-positive awareness | No FP section, or "none" | Generic FP text | Names realistic FPs (legit installers using temp, EDR/agent services) | |
| No hallucinated facts | Invents field names or EIDs | One | Uses only the provided/real fields | Watch for `EventID: 4697` vs `7045` confusion. |
| Professional formatting | Not valid YAML | Messy YAML | Clean, commented, ready to commit | |

### Common Failure Modes
- Using the Security log 4697 while claiming System 7045 (or mixing them silently).
- Inventing Sysmon field names that do not exist for 7045.
- Writing a `contains` on the whole path that also matches `C:\Windows\System32` legitimately.
- Omitting the false-positives section entirely, or writing "None."
- Setting `level: critical` for a behavior that is frequently benign without context.

### Stretch Goal
Ask the LLM to produce a *second* correlated rule using Sysmon EID 1 (`sc.exe create` / service-install command lines) and EID 13, then explain how correlating the two log sources reduces false positives compared to either alone — and what it still cannot distinguish from a legitimate admin installing a service to a temp path.
