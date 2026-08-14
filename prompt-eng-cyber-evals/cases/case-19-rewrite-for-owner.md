# Case 19 — Rewrite a Finding for a Non-Technical System Owner

**Category:** Documentation and Reporting

### Metadata
- **Title:** Translate a technical finding into remediation guidance a non-technical owner can act on
- **Difficulty:** Medium
- **Estimated completion time:** 30–40 minutes
- **Learning objective:** Rewrite for a specific non-expert audience while preserving technical accuracy and not diluting the required action.
- **Skills evaluated:** Audience translation, accuracy preservation, actionable remediation, tone.

### Student Input

Original technical finding:

```
Title: Insecure Direct Object Reference (IDOR) in /api/v2/invoices/{id}
Severity: High
Detail: The endpoint returns invoice objects by integer ID without verifying
that the authenticated user owns the invoice. Iterating {id} from 1..N returns
other tenants' invoices (PII: names, addresses, amounts). Confirmed by
retrieving invoice 1041 (belongs to tenant B) while authenticated as tenant A.
Remediation: Enforce server-side authorization checks (object-level access
control) on the invoice retrieval path; do not rely on client-supplied IDs.
```

Audience and context:

```
- Recipient: the product owner for the billing app (business background,
  not an engineer). They will forward the required fix to a dev contractor.
- They asked: "Can you explain what this means and exactly what my developer
  needs to do, in plain terms?"
```

### Student Task

Ask the LLM to rewrite the finding as a plain-language explanation plus a precise, developer-forwardable remediation — without losing technical correctness.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Accuracy preserved | Introduces errors while simplifying | Minor slip | Simplifies without misstating (still an authorization/ownership check gap) | Simplification must not corrupt the fix. |
| Audience calibration | Still full of jargon, or dumbed down to uselessness | Uneven | Plain analogy for the owner + a precise technical instruction block for the developer | Two registers in one doc. |
| Actionable remediation | Vague ("make it secure") | Correct but loose | Clear dev instruction: enforce server-side object-level authorization tying the invoice to the requesting user/tenant | |
| Impact clarity | Over/understates | OK | Conveys that other customers' personal/billing data is exposed — the business stake | |
| No hallucinated facts | Invents record counts, breach claims | One | Uses only the confirmed detail (invoice 1041, cross-tenant read) | Don't claim it was exploited by outsiders. |
| Tone | Alarmist or dismissive | Uneven | Calm, direct, respectful of a non-technical reader | |

### Common Failure Modes
- Simplifying into inaccuracy (e.g., calling it "a password problem" or "encryption issue").
- Keeping IDOR/OWASP jargon the owner cannot use.
- Giving remediation too vague for the contractor to implement.
- Inflating impact to "data breach affecting all customers" beyond what was confirmed.
- Losing the key point that the check must be **server-side** and per-object.

### Stretch Goal
Ask the LLM to include a 3-line "how we'll verify the fix" note the owner can send back to the developer (re-test iterating IDs across two tenant accounts and confirming access is denied), so remediation closes with evidence rather than assertion.
