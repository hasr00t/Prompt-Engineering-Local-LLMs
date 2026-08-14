# Case 10 — Failed Logons: Password Spray vs. Brute Force

**Category:** Log Analysis

### Metadata
- **Title:** Classify a burst of 4625 failed-logon events
- **Difficulty:** Easy
- **Estimated completion time:** 20–30 minutes
- **Learning objective:** Read Windows failed-logon events and correctly distinguish password spraying (many accounts, few attempts each) from brute force (one account, many attempts), citing the evidence.
- **Skills evaluated:** Log reading, pattern classification, evidence citation, restraint.

### Student Input

Windows Security log — Event ID 4625, normalized SIEM view (Splunk), one DC (DC01), 09:00–09:04 local time:

```
09:00:11  4625  Account: alice    Src: 10.9.4.51  Logon Type: 3  Sub-status: 0xC000006A (bad password)
09:00:12  4625  Account: bob      Src: 10.9.4.51  Logon Type: 3  Sub-status: 0xC000006A
09:00:13  4625  Account: carol    Src: 10.9.4.51  Logon Type: 3  Sub-status: 0xC000006A
09:00:14  4625  Account: dave     Src: 10.9.4.51  Logon Type: 3  Sub-status: 0xC000006A
09:00:15  4625  Account: erin     Src: 10.9.4.51  Logon Type: 3  Sub-status: 0xC000006A
...
09:03:59  4625  Account: yolanda  Src: 10.9.4.51  Logon Type: 3  Sub-status: 0xC000006A
```

Additional context in the same export (noise):

```
09:02:30  4625  Account: svc_backup  Src: 10.9.4.51  Logon Type: 3  Sub-status: 0xC0000234 (account locked out)
08:47:02  4625  Account: jsmith  Src: 10.9.7.12  Logon Type: 2  Sub-status: 0xC000006A  (one event, interactive)
```

### Student Task

Ask the LLM to determine what the 4625 pattern most likely represents and to state the evidence supporting its conclusion.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Correct classification | Calls it brute force | Hedges without picking | Identifies password spraying: many distinct accounts, ~1 attempt each, one source, short window | |
| Evidence citation | No specifics | Some | Cites the many-accounts/one-source/one-attempt pattern and the single source IP 10.9.4.51 | |
| Noise handling | Treats `jsmith` (different IP, interactive, single) as part of the attack | Unsure | Excludes the unrelated `jsmith` event and notes the lockout is collateral from the spray | The lockout implies svc_backup was already near threshold; the spray attempt was the final straw. Stating it is "a consequence of the spray" is acceptable; asserting the spray alone caused the lockout from zero is slightly imprecise. |
| Technical accuracy | Misreads Logon Type 3 or the sub-status | Minor | Correctly reads network logons and bad-password vs. lockout codes | |
| Appropriate assumptions | Asserts the account owner or attacker identity | Slight | Does not invent who is behind 10.9.4.51 | |
| Actionable next step | None | Vague | Suggests checking for any 4624 success from the same source and scoping the account list | |

### Common Failure Modes
- Labeling it brute force despite each account seeing a single attempt.
- Folding the unrelated `jsmith` interactive failure into the incident.
- Reading the lockout event as the "goal" rather than collateral.
- Claiming the source IP is external or attributing it to a named threat actor.
- Declaring a breach without any 4624 success in evidence.

### Stretch Goal
Ask the LLM to write the KQL/Splunk logic it would use to confirm the spray hypothesis at scale (distinct-account count per source IP over a sliding window) and to state the one additional event type that would upgrade this from "attempted" to "successful."
