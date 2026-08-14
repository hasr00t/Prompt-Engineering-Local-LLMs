# Case 12 — Possible Lateral Movement, Ambiguous Timestamps

**Category:** Log Analysis

### Metadata
- **Title:** Assess a suspected lateral-movement chain where timestamps span systems with unclear timezones
- **Difficulty:** Hard
- **Estimated completion time:** 45–60 minutes
- **Learning objective:** Resist assembling a tidy attack narrative when the correlating evidence hinges on timestamps whose timezones are inconsistent or unstated — the correct output flags the ambiguity as decisive.
- **Skills evaluated:** Cross-source correlation, timezone/skew reasoning, resisting narrative bias, insufficient-evidence judgment.

### Student Input

Splunk search results, combined from three sources (as provided by the client):

```
# Source A: VPN concentrator (timezone: UTC, per vendor default)
2026-07-09 22:14:03  user=mchen  action=vpn_connect  src_ip=45.77.x.x  result=success

# Source B: Windows DC 4624 (timezone: NOT SET in the export; DC is configured America/New_York)
2026-07-09 18:15:40  Account=mchen  LogonType=3  Src=10.8.2.19  -> DC01
2026-07-09 18:31:12  Account=mchen  LogonType=3  Src=10.8.2.19  -> FS02

# Source C: EDR process events (timezone: epoch converted to UTC by the SIEM)
2026-07-09 22:33:57  host=FS02  user=mchen  proc=rundll32.exe  cmdline="rundll32.exe C:\Users\mchen\AppData\Local\Temp\a.dll,Start"
```

Client note:

```
- mchen is a legitimate developer, normally works 9-5 Eastern.
- The SOC is asking: "Is this an attacker who stole mchen's account moving
  laterally from VPN -> DC -> FS02 and running a malicious DLL?"
- We do not have confirmation that Source B's timestamps were normalized.
```

### Student Task

Ask the LLM to assess whether the evidence supports a lateral-movement compromise of mchen's account, and to state its confidence.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Timezone reasoning | Treats all timestamps as directly comparable | Notes TZ in passing | Recognizes Source B may be Eastern (18:15 EDT ≈ 22:15 UTC), which *changes the ordering* relative to the 22:14 VPN connect | The crux. |
| Insufficient-evidence judgment | Confidently confirms the attack chain | Leans one way | Concludes the sequence is plausible but **cannot be confirmed** until Source B's timezone is verified | |
| Resisting narrative bias | Accepts the SOC's ready-made story | Partially | Treats the VPN→DC→FS02→DLL chain as a hypothesis to test, not a conclusion | |
| Technical accuracy | Misreads events | Minor | Correctly reads the events; notes `rundll32` of a temp-path DLL is genuinely suspicious on its own merits | The DLL is suspect regardless of timeline. |
| Actionable next step | None | Vague | Leads with: confirm Source B timezone/normalization; then re-evaluate ordering; isolate/triage FS02 for the DLL now regardless | |
| No hallucinated facts | Invents offsets or a confirmed offset | One | Does not assert the offset it cannot verify | |

### Common Failure Modes
- Building a confident VPN→DC→FS02 kill-chain by comparing 22:14, 18:15, 22:33 as if same-zone.
- Dismissing the whole thing because "the DC events are 4 hours earlier" (also a TZ mistake).
- Ignoring that the temp-path `rundll32` DLL warrants immediate triage independent of the timeline question.
- Declaring mchen's account confirmed-compromised.
- Not naming timezone verification as the single blocking question.

### Stretch Goal
Ask the LLM to write two versions of the SOC update: (a) if Source B is confirmed to be Eastern (chain is temporally consistent — escalate), and (b) if Source B is confirmed UTC (chain ordering breaks — the DC logons *precede* the VPN connect, suggesting either a second access path or a different explanation). This forces reasoning about how one unknown flips the conclusion.
