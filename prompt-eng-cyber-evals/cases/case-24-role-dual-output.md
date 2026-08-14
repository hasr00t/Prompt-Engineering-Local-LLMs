# Case 24 — Role-Conditioned Dual Output From One Incident

**Category:** Threat Analysis / Documentation and Reporting

### Metadata
- **Title:** Produce two audience-specific deliverables from one incident using role framing
- **Difficulty:** Medium
- **Estimated completion time:** 35–45 minutes
- **Learning objective:** Use role/persona prompting to change register, depth, and emphasis for different audiences while holding the underlying facts — and the genuine unknown — constant.
- **Skills evaluated:** Role prompting, output formatting, constraint adherence, hallucination resistance.

### Student Input

Incident evidence (a small correlated set with one genuine unknown):

```
- 2026-07-09 14:02 UTC: EDR flags credential-dumping tool on host FIN-WS07
  (user CORP\bpatel). Tool execution confirmed; killed by EDR.
- 2026-07-09 14:05 UTC: FIN-WS07 makes an outbound connection to a Tor exit
  node; ~40 MB transferred before the host was network-isolated at 14:11.
- The 40 MB transfer content is UNKNOWN — no DLP inspection, no capture of the
  payload. Whether sensitive data left the environment is not established.
- bpatel is a finance analyst; the workstation has access to a finance file share.
- No evidence (yet) of movement to other hosts.
```

Audience and constraints:

```
Deliverable A — Technical brief for the IR engineer taking over containment.
Deliverable B — Executive notification for a non-technical VP of Finance.

Rules:
- The FACTS must be identical across both (no fact in one that contradicts or
  is absent-if-material from the other).
- Neither deliverable may state that data was exfiltrated — that is unknown.
- The exec version must not drop the material fact that isolation was performed
  and that data loss is unconfirmed.
```

### Student Task

Ask the LLM, in a single prompt using explicit role framing, to produce both Deliverable A (IR-engineer technical brief) and Deliverable B (executive notification) from the same evidence.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Register differentiation | Both read the same | One is off-audience | A is technical/actionable; B is plain-language and decision-oriented | The role-prompting payoff. |
| Fact consistency | Facts conflict between versions | Minor drift | Identical underlying facts; timeline preserved in both | |
| Handles the unknown | Claims (or implies) exfiltration | One version overstates | Both state data-loss is unconfirmed; neither asserts exfil | The planted uncertainty. |
| Exec completeness | Drops isolation or the unconfirmed-loss point | Partial | B keeps the two material facts (isolated; loss unconfirmed) despite being brief | Brevity ≠ omission. |
| No detail leakage | Tool names / IPs dumped into the exec note | Some | A carries technical specifics; B abstracts them appropriately | |
| No hallucinated facts | Invents attacker identity, data stolen, or scope | One | Stays within the evidence; "no evidence yet" stays "yet" | |

### Common Failure Modes
- Producing two near-identical texts (role framing didn't actually change the output).
- The executive version implying data was stolen ("attackers exfiltrated finance data").
- The executive version omitting that the host was isolated or that loss is unconfirmed.
- Leaking tool names, IPs, and EDR jargon into the VP-facing note.
- Inventing attribution ("APT group") or a confirmed data-loss figure.

### Stretch Goal
Add a third role — breach counsel (legal) — with a distinct constraint: it must avoid conclusory language about whether a reportable breach occurred and instead frame what is known, unknown, and pending. Tests whether role prompting can enforce *different* assertion-boundaries on the same facts.
