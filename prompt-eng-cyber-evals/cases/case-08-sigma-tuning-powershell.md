# Case 08 — Tune a Noisy PowerShell Detection

**Category:** Detection Engineering

### Metadata
- **Title:** Reduce false positives in an existing Sigma rule for encoded PowerShell
- **Difficulty:** Medium
- **Estimated completion time:** 30–40 minutes
- **Learning objective:** Improve an over-broad detection without blinding it — add filters that cut known-benign noise while keeping the malicious cases.
- **Skills evaluated:** Detection tuning, false-positive analysis, precision vs. recall trade-off, evidence-based filtering.

### Student Input

Existing Sigma rule (fires hundreds of times a day):

```yaml
title: Suspicious PowerShell Encoded Command
logsource:
  product: windows
  category: process_creation
detection:
  selection:
    Image|endswith: '\powershell.exe'
    CommandLine|contains: '-enc'
  condition: selection
level: high
```

Sample of what it is firing on (analyst-triaged):

```
1. powershell.exe -enc SQBFAFgA...        <- confirmed malicious (IEX download)
2. powershell.exe -EncodedCommand ...     <- legit: SCCM software deployment (runs as SYSTEM, from C:\Windows\CCM\)
3. powershell.exe -encoding UTF8 ...       <- FALSE MATCH: '-encoding', not '-enc' encoded command
4. powershell.exe -enc <base64>            <- legit: internal monitoring agent, ParentImage C:\Program Files\Acme\agent.exe
5. pwsh.exe -enc ...                        <- missed entirely (rule only matches powershell.exe)
```

### Student Task

Ask the LLM to improve the rule to reduce false positives (items 2, 3, 4) while still catching item 1 and ideally item 5, and to explain each change.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Fixes the `-encoding` false match | Ignores it | Partial | Tightens matching so `-encoding` no longer triggers (e.g., anchored/regex on the actual param) | Item 3 is a logic bug, not a tuning choice. |
| Adds sound filters | No filters | One | Filter blocks for SCCM (`\CCM\`) and the known agent `ParentImage`, expressed as Sigma `filter` + `condition: selection and not filter` | Items 2, 4. |
| Preserves detection | Filters out the malicious case too | Weakens recall | Item 1 still fires; ideally adds `pwsh.exe` for item 5 | Don't over-filter. |
| Evidence-based reasoning | Filters on guesses | Some justification | Each filter maps to a specific triaged FP, not speculation | |
| Sigma validity | Broken | Minor | Valid `filter`/`condition` structure | |
| Documents residual risk | Claims "no more FPs" | Vague | Notes that path/parent filters can be abused (attacker drops into `\CCM\`) and are a trade-off | Honesty about the filter's own weakness. |

### Common Failure Modes
- "Fixing" noise by adding unrelated broad conditions that also drop the real detection.
- Filtering on `ParentImage` or path without noting an attacker can spoof/abuse those to evade.
- Missing the `-encoding` vs `-enc` substring bug (treating it as tuning rather than a match error).
- Claiming the tuned rule now has "no false positives."
- Forgetting `pwsh.exe`, leaving PowerShell 7 uncovered.

### Stretch Goal
Ask the LLM to add detection for the *content* of the encoded payload where the platform decodes it (e.g., a `ScriptBlockText` selection catching `IEX`/`DownloadString`), and to discuss the detection-engineering trade-off between filtering on brittle context (paths/parents) versus intent (decoded behavior).
