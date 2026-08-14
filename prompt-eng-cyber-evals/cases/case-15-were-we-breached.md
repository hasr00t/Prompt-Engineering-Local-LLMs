# Case 15 — "Were We Breached?" With Thin Evidence

**Category:** Threat Analysis

### Metadata
- **Title:** Answer a compromise question where the available evidence cannot support a yes or no
- **Difficulty:** Hard
- **Estimated completion time:** 45–60 minutes
- **Learning objective:** Deliver "insufficient evidence" as a professional, actionable answer — neither falsely reassuring nor alarmist — and specify the collection that would resolve it.
- **Skills evaluated:** Uncertainty communication, evidence sufficiency judgment, collection planning, stakeholder-appropriate tone.

### Student Input

What the client can provide (and only this):

```
- One EDR alert (medium): "Possible credential access" on host HR-WS12,
  2026-07-08 03:11, process lsass.exe accessed by taskmgr.exe (user: CORP\it_admin2).
- The alert auto-resolved; EDR did not quarantine.
- No memory capture was taken. Endpoint has since been rebooted (patch night).
- Netflow retention: 24 hours (already rolled off for the 07-08 window).
- No EDR command-line or child-process detail retained for the event.
- it_admin2 says they "might have opened Task Manager to kill a hung app" that night.
```

Client question:

```
"Was this a credential-theft breach? We need a yes/no for the risk committee
by end of day."
```

### Student Task

Ask the LLM to determine whether a credential-theft breach occurred and to produce a response suitable for the risk committee.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Evidence sufficiency | Gives a definitive yes or no | Hedges vaguely | States clearly that available evidence cannot confirm or refute credential theft, and why | The intended answer. |
| Benign-alternative reasoning | Ignores the taskmgr explanation | Mentions it | Notes taskmgr.exe accessing lsass is a known benign pattern (opening the Processes tab), consistent with the admin's account | Real detail that matters. |
| Not falsely reassuring | Declares "no breach, all clear" | Leans safe | Avoids both false all-clear and unfounded alarm; frames as unresolved | |
| Collection planning | None | Partial | Lists what would have resolved it (memory capture, retained command line, longer netflow) and what can still be done (creds rotation for it_admin2, hunt for downstream use) | |
| Stakeholder tone | Technical dump or panic | Uneven | Committee-appropriate: plain risk statement + recommended precaution | |
| No hallucinated facts | Invents dump artifacts or attacker actions | One | Sticks to the one alert and its limits | |

### Common Failure Modes
- Answering the demanded yes/no despite the evidence not supporting either.
- Declaring it definitely benign because taskmgr is "normal," ignoring that detail cannot be verified post-reboot.
- Declaring it a confirmed breach from a single medium, auto-resolved alert.
- Overlooking that the reboot + rolled-off netflow destroyed the evidence that would decide it.
- Not offering a precautionary action (rotate it_admin2 credentials, targeted hunt) that is reasonable *despite* the uncertainty.

### Stretch Goal
Ask the LLM to draft a short "evidence handling" recommendation the client could adopt so the *next* such alert is answerable (e.g., auto memory capture on credential-access alerts, minimum netflow/command-line retention), turning this dead end into a program improvement.
