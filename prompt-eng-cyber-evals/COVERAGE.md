# Prompt-Engineering Skill Coverage Matrix

This matrix maps the 24 evaluation cases against the twelve prompt-engineering skills taught in the workshop. It identifies which skills are well exercised and which are thin. Cases 01-20 are the core set; cases 21-25 were added specifically to close coverage gaps found in the core set (see "Gap analysis" below).

Legend: **●** = primary skill the case is designed to exercise · **○** = secondary skill the case also touches · blank = not meaningfully exercised.

## Matrix

| # | Case (short) | Role prompting | Context mgmt | Output formatting | Constraints | Few-shot | Planning vs execution | Verification | Hallucination resistance | Evidence-based reasoning | Adversarial robustness | Structured outputs | Reusable Skills |
|---|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 01 | SMB signing finding | ○ | | ● | ● | | | | ● | ○ | ○ | | |
| 02 | Version backport | | | | ○ | | | ● | ● | ● | ● | | |
| 03 | Decommissioned host | ○ | ○ | | | | | | ● | ● | ● | | |
| 04 | sshd_config | | | ● | ● | | | | ○ | | ● | ○ | |
| 05 | nginx w/ noise | | ● | ○ | | | | ○ | | ○ | ● | | |
| 06 | IAM policy | | ● | | ○ | | ○ | | ● | ● | | ○ | |
| 07 | Sigma persistence | | | ● | | ○ | | | ● | ○ | | ● | |
| 08 | Sigma tuning | | | | | ○ | | ○ | | ● | ● | ● | |
| 09 | WMI feasibility | | ○ | | ● | | ● | | ● | ● | ○ | | |
| 10 | 4625 spray | | | ○ | | ○ | | ○ | | ● | ● | | |
| 11 | Web attack noise | | ● | | | | ○ | | ○ | ● | ● | | |
| 12 | Lateral / timezone | | ● | | | | | ● | ○ | ● | ● | | |
| 13 | Attack-path nmap | | ○ | | | | ● | | ● | ● | | ○ | |
| 14 | Exploitability ctx | | | | ○ | | ○ | | ● | ● | | | |
| 15 | "Were we breached?" | ○ | | | ● | | ● | | ● | ● | ● | | |
| 16 | Preconditions + PoC | | | ○ | | | ○ | ● | ● | ● | | | |
| 17 | Nessus precondition | | | ○ | | | | ● | ● | ● | ● | | |
| 18 | Exec summary | ● | ○ | ● | ● | | | | ● | | | | |
| 19 | Rewrite for owner | ● | | ● | ● | ○ | | ○ | ○ | | | | |
| 20 | Gappy notes | | ○ | ○ | | | ● | ● | ● | ● | ● | ○ | |
| 21 | Few-shot house style | ○ | | ● | ○ | ● | | | ● | | | | |
| 22 | Reusable Nessus skill | | ○ | ○ | ● | ● | | ● | ● | | | | ● |
| 23 | Structured JSON triage | | | | ● | | | ○ | ● | ○ | | ● | |
| 24 | Role-conditioned dual output | ● | ○ | ● | ● | | | | ● | | | | |
| 25 | Reusable alert responder | | ○ | ○ | ● | ● | | ● | ● | ● | | | ● |
| **Totals (● / ● + ○)** | | **3 / 7** | **4 / 11** | **8 / 14** | **10 / 14** | **3 / 7** | **4 / 7** | **8 / 13** | **18 / 20** | **13 / 17** | **10 / 11** | **4 / 8** | **2 / 2** |

## Gap analysis (core set, cases 01–20)

The primary counts below describe the **core 20 cases**, which is what motivated adding cases 21–24. (The matrix totals above include all 24.)

**Strongly covered (primary in 6+ cases):**
- **Hallucination resistance** (13 primary) — the dataset's backbone; nearly every case penalizes invented versions, CVEs, exfil claims, or attacker attribution.
- **Evidence-based reasoning** (12 primary) — reasoning strictly from provided artifacts is the core teaching goal.
- **Adversarial robustness** (10 primary) — planted noise, contradictions, misleading scanner verdicts, and pressure to over-conclude appear throughout.
- **Output formatting** (6), **Constraints** (6), **Verification** (6) — healthy coverage.

**Adequately covered:**
- **Context management** (4 primary), **Planning vs execution** (4 primary) — present and distributed across difficulties.

**Thin / gaps (fewer than 3 primary):**
- **Role prompting** (2 primary) — appears mainly in reporting cases (18, 19). No case where the *choice of role* is the decisive lever tested in isolation.
- **Structured outputs** (3 primary) — Sigma YAML (07, 08) and attack-tree (13) cover it, but there is no case requiring a strict, schema-conformant machine-readable output (e.g., JSON for a pipeline) where formatting fidelity is scored.
- **Few-shot prompting** (0 primary, 4 secondary) — no case is built around supplying worked examples to steer style or classification. Currently only incidental.
- **Reusable Skills** (0) — **the largest gap.** No case asks students to author a *generalizable* prompt/skill that works across many inputs and to validate it against a set — the central idea of building a reusable capability rather than a one-off answer.

## The added cases (21–24)

These five cases (now written and included in [`cases/`](cases/)) close the gaps above while staying inside the existing categories and design principles (missing info, contradiction, noise, insufficient-evidence).

### Case 21 — Few-shot: match the house finding style
- **Category:** Finding writing · **Difficulty:** Medium
- **Gap filled:** Few-shot prompting (primary), Output formatting, Role prompting.
- **Input:** Two complete example findings written in a firm's house style (fixed section order, severity phrasing, a standard "Business Impact" sentence pattern), plus one raw Nessus/nmap artifact for a *new* issue not covered by the examples.
- **Task:** Using the two examples as the pattern, ask the LLM to produce a third finding that matches the house style exactly.
- **Why it fills the gap:** Success depends on the student *supplying and exploiting examples* rather than describing the format in prose. Rubric scores style-match fidelity, and includes a trap: one example contains a stylistic quirk that should be imitated and a factual detail that should **not** be carried over to the new finding (hallucination-resistance cross-check).
- **Stretch:** Add a third example that subtly contradicts the other two on section order; the student must decide which pattern to follow and justify it.

### Case 22 — Reusable Skill: a Nessus-to-finding converter
- **Category:** Documentation and reporting · **Difficulty:** Hard
- **Gap filled:** Reusable Skills (primary), Few-shot, Constraints, Verification, Hallucination resistance.
- **Input:** Three heterogeneous Nessus plugin outputs — one clear real issue, one version-based/backport-ambiguous finding, and one that is informational and should be *suppressed or downgraded*.
- **Task:** Author **one reusable prompt/skill** (with fixed instructions, constraints, and output template) that converts *any* Nessus finding into a client-ready finding — then run it unchanged against all three inputs.
- **Why it fills the gap:** Forces the student to design for generality and robustness, not a single answer. The skill is graded on whether the *same* prompt handles all three correctly — especially whether it self-limits on the ambiguous one and downgrades the informational one, without per-input hand-tuning.
- **Stretch:** Hand the finished skill a deliberately out-of-distribution input (a web-app finding, not a Nessus plugin) and score whether the skill degrades gracefully or hallucinates.

### Case 23 — Structured output for a triage pipeline
- **Category:** Detection engineering / Log analysis · **Difficulty:** Medium
- **Gap filled:** Structured outputs (primary), Constraints, Verification, Hallucination resistance.
- **Input:** A short set of alerts/log lines plus a **strict JSON schema** (fields, `severity` enum, required vs. optional, `null` allowed for unknowns) that a ticketing system will ingest.
- **Task:** Produce output that validates against the schema exactly — including one alert where a required field's value is genuinely unknown, which must be emitted as `null`/`"unknown"` rather than fabricated.
- **Why it fills the gap:** Tests machine-consumable formatting under constraint, and whether the model preserves uncertainty *inside* a rigid structure instead of inventing a value to satisfy the schema. Rubric includes "output parses/validates" as a scored criterion.
- **Stretch:** Require the model to also emit a second JSON object listing which fields it marked unknown and what evidence would populate them.

### Case 24 — Role-conditioned dual output from one incident
- **Category:** Threat analysis / Reporting · **Difficulty:** Medium
- **Gap filled:** Role prompting (primary), Output formatting, Constraints, Hallucination resistance.
- **Input:** One set of incident evidence (a handful of correlated events with one genuine unknown).
- **Task:** From a single prompt, produce two deliverables driven by explicit role/persona framing: (a) a SOC-analyst-to-IR-engineer technical brief, and (b) an executive notification for a non-technical VP.
- **Why it fills the gap:** Isolates role prompting as the decisive variable — the *facts must be identical* across both outputs while register, depth, and emphasis change. Rubric penalizes any case where the technical detail leaks into the exec version, where the exec framing drops a material fact, or where either version resolves the genuine unknown.
- **Stretch:** Add a third role (legal/breach-counsel) with different constraints (what may/may not be asserted before confirmation), testing constraint-adherence under role.

### Case 25 — Reusable Skill: an alert-to-ticket responder
- **Category:** Log analysis / SOC operations - **Difficulty:** Hard
- **Gap filled:** Reusable Skills (primary), Few-shot, Constraints, Verification, Hallucination resistance, Evidence-based reasoning.
- **Input:** Three heterogeneous SIEM alerts: one clear true positive (CVE-2026-24061 exploitation with data exfiltration), one ambiguous (failed SSH logins from a known vendor's IP outside normal hours), and one context-dependent (internet-facing telnet on a host controlling building HVAC).
- **Task:** Author **one reusable prompt/skill** (with fixed instructions, constraints, and output template) that converts any SIEM alert into a structured investigation ticket response, then run it unchanged against all three inputs.
- **Why it fills the gap:** The blue-team counterpart to Case 22. Forces the student to design for generality across alert types, not a single investigation. The skill is graded on whether the same prompt handles a confirmed compromise, an ambiguous vendor situation, and a context-dependent exposure correctly, without per-input adjustment.
- **Stretch:** Hand the finished skill a raw Nessus plugin finding instead of a SIEM alert and score whether it degrades gracefully or hallucinates.

## Coverage after adding 21-25

| Skill | Primary in core (01-20) | Primary in full set (01-25) |
|---|:--:|:--:|
| Role prompting | 2 | 3 |
| Few-shot prompting | 0 | 3 |
| Structured outputs | 3 | 4 |
| Reusable Skills | 0 | 2 |

All twelve skills are now exercised as a primary focus in at least one case, with the three foundational skills (hallucination resistance, evidence-based reasoning, adversarial robustness) remaining the most heavily reinforced, which is appropriate for a security-reasoning curriculum.
