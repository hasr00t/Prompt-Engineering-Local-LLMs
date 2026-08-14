# Case 20 — Report Section From Gappy, Contradictory Notes

**Category:** Documentation and Reporting

### Metadata
- **Title:** Draft a report section from raw field notes that are incomplete and internally inconsistent
- **Difficulty:** Hard
- **Estimated completion time:** 45–60 minutes
- **Learning objective:** Produce honest report prose from messy source notes — flagging gaps and contradictions rather than resolving them by invention, and marking what needs analyst confirmation before publication.
- **Skills evaluated:** Faithful drafting under uncertainty, contradiction handling, refusal to fabricate, editorial flagging.

### Student Input

Raw tester notes (verbatim, messy):

```
- got shell on WEB02 ~ day 2. via the upload thing (need to double check which param).
- WEB02 = 10.20.3.11 ... or was it .12? one of the two, .11 in nmap but ticket says .12
- creds found in config: db_user / [REDACTED in notes]. worked against DB01.
- pretty sure we pivoted to DB01 but I don't see the proof screenshot, might be on the other laptop
- DB01 had customer records. did NOT exfil (out of scope). ~ maybe 50k rows? didn't count.
- client said WEB02 was "hardened per CIS" but clearly it wasn't (upload flaw). or maybe a diff box was hardened.
- someone (teammate?) noted "WAF blocked initial attempts" but I got through, unclear how.
```

Task context:

```
- These notes feed the "Attack Narrative" section of the client report.
- Anything stated in the report must be defensible if the client challenges it.
```

### Student Task

Ask the LLM to draft the "Attack Narrative" section from these notes, handling the gaps and contradictions appropriately and marking anything that needs confirmation before the report is finalized.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Refusal to fabricate | Invents the param, the IP, the row count, the WAF-bypass method | Fills one gap | States confirmed facts as facts and leaves gaps as explicit TODO/needs-confirmation | The central test. |
| Contradiction handling | Silently picks .11 or .12; ignores the CIS/WAF conflicts | Notes one | Flags the IP discrepancy, the "hardened per CIS" contradiction, and the unverified WAF-bypass as open items | |
| Faithful drafting | Overstates certainty | Uneven | Writes defensible prose: what is proven (shell on WEB02, creds worked on DB01) vs. what is claimed-but-unverified (pivot proof missing, row count) | |
| Evidence flagging | No markers | Some | Clearly marks each unconfirmed item and what evidence would confirm it (screenshot, nmap re-check, param) | |
| Scope fidelity | Implies data was exfiltrated | Ambiguous | Preserves "did NOT exfiltrate, out of scope" accurately | |
| Professional writing | Unusable | Rough | Clean narrative with a visible "to confirm before publish" list | |

### Common Failure Modes
- Picking an IP (.11 or .12) and stating it as fact instead of flagging the conflict.
- Reporting "~50k customer records" as a firm number.
- Inventing the upload parameter or the WAF-bypass technique to make the narrative flow.
- Silently resolving the "hardened per CIS" contradiction instead of surfacing it.
- Implying data was exfiltrated when the notes say it was not.
- Producing confident prose that would collapse the moment the client asks for proof.

### Stretch Goal
Ask the LLM to output two artifacts: (1) the draft narrative with inline `[CONFIRM: …]` markers, and (2) a separate, prioritized "evidence to gather before finalizing" checklist the tester can work through — turning messy notes into both a draft and a QA plan.
