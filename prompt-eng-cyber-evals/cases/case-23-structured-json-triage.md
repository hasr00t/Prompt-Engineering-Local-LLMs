# Case 23 — Structured JSON Output for a Triage Pipeline

**Category:** Detection Engineering / Log Analysis

### Metadata
- **Title:** Emit schema-conformant JSON for a ticketing pipeline, preserving unknowns
- **Difficulty:** Medium
- **Estimated completion time:** 30–40 minutes
- **Learning objective:** Produce strictly-formatted, machine-consumable output that validates against a given schema, and preserve genuine uncertainty *inside* the structure (null / "unknown") instead of fabricating a value to satisfy it.
- **Skills evaluated:** Structured outputs, constraint adherence, verification, hallucination resistance.

### Student Input

Alerts to be normalized (from a SIEM export):

```
[1] EDR: process 'mimikatz.exe' executed on host FIN-WS07 by user CORP\bpatel,
    source host of the logon session: DESKTOP-4K2 (10.8.6.19). High confidence.
[2] Firewall: outbound connection FIN-WS07 -> 185.220.101.4:443, 40MB transferred,
    destination flagged as a known Tor exit node. Medium confidence.
[3] Proxy: user CORP\bpatel downloaded 'invoice_q3.zip' from a webmail provider.
    No malware verdict available; sandbox detonation not performed.
    Source IP of the client: not recorded in this log source.
```

Target JSON schema (each alert must conform):

```json
{
  "alert_id": "integer",
  "host": "string",
  "severity": "one of: low | medium | high | critical",
  "technique": "string (short label)",
  "confidence": "one of: low | medium | high",
  "source_ip": "string or null",
  "recommended_action": "string",
  "evidence_summary": "string"
}
```

Constraints:

```
- Output MUST be a JSON array that validates against the schema.
- Use null for any field whose value is genuinely not present in the evidence.
- Do NOT invent IP addresses, verdicts, or severities not supported by the input.
- severity is your assessment; confidence must reflect the source's stated confidence.
```

### Student Task

Ask the LLM to convert the three alerts into a schema-conformant JSON array, mapping each field from the evidence and using `null` where a value is unknown.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Schema validity | Output isn't valid JSON / wrong fields | Minor deviation | Valid JSON array; every object has exactly the schema fields with correct types | Should parse without edits. |
| Preserves unknowns | Fabricates a source_ip for alert [3] | Uses empty string ambiguously | Sets `source_ip: null` for alert [3] (not recorded) | The central test. |
| Correct field mapping | Miswires confidence/severity | One slip | source-stated confidence in `confidence`; analyst severity in `severity`; keeps them distinct | Alert [3] has no verdict → not high severity. |
| Host attribution | Invents a host for alert [3] | — | Alert [3] does not explicitly name a host. Inferring FIN-WS07 from the shared user (CORP\bpatel) across all three alerts is reasonable; flagging it as assumed is better. Fabricating a different host is a failure. | `host` is non-nullable in the schema, so the student must make a judgment call. |
| No hallucinated facts | Invents a malware verdict for [3] or a technique it can't support | One | Labels [3] as unverified download; no invented verdict | |
| Severity reasoning | Flat or inflated | Uneven | mimikatz = high/critical; Tor exfil = high; unverified download = low/medium | Evidence-proportionate. |
| Actionable field | Empty/generic actions | Vague | Concrete `recommended_action` per alert (isolate host, block IP, detonate the zip) | |

### Common Failure Modes
- Inventing a `source_ip` for alert [3] to avoid an empty field, instead of `null`.
- Collapsing `severity` and `confidence` into one value.
- Rating the unverified download high because it "looks phishing-y."
- Emitting prose around the JSON so it no longer parses cleanly.
- Adding extra fields not in the schema.

### Stretch Goal
Ask the LLM to emit a second JSON object listing, per alert, which fields were set to `null`/unknown and exactly what evidence would populate them (e.g., "source_ip for alert 3 requires the webmail provider's auth log") — turning the gaps into a collection task list.
