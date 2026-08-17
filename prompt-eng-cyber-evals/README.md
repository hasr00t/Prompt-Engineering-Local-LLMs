# Prompt Engineering for Cyber Security — Evaluation Dataset

A collection of 25 hands-on evaluation cases for the **Prompt Engineering for Cyber Security** workshop. Each case is a self-contained Markdown file under [`cases/`](cases/).

## Purpose

These evaluations are **not** LLM benchmarks. They are practice artifacts for students learning to *iteratively improve prompts* against realistic security tasks. Each case mirrors work a security consultant, penetration tester, detection engineer, or SOC analyst actually performs.

The core teaching goal: **reason from the evidence provided.** Several cases are deliberately built so that the strongest possible answer is *"the evidence is insufficient — here is what I would collect next."* Students should learn that confident-sounding output is not the same as correct output, and that appropriate uncertainty is a professional skill, not a failure.

## How to use these

1. Pick a case. Read the metadata and the student input.
2. Draft a prompt that hands the input to an LLM and asks for the described task.
3. Run it. Score the output against the rubric (0–2 per criterion).
4. Revise the prompt to fix the lowest-scoring criteria. Re-run. Compare.
5. Discuss which prompt changes moved which scores, and why.

The value is in the *iteration*, not the first score.

## Scoring convention

Every criterion is scored **0, 1, or 2**:

- **0** — Fails the criterion (absent, wrong, or actively misleading).
- **1** — Partially meets it (present but incomplete, hedged incorrectly, or with notable gaps).
- **2** — Fully meets it.

Total possible points vary by case (number of criteria × 2). Record the raw total and the per-criterion breakdown; the breakdown is what tells students where the prompt is weak.

## Categories and case index

Cases 01–20 are the core set (7 categories). Cases 21–24 were added to balance prompt-engineering skill coverage (see [`COVERAGE.md`](COVERAGE.md)).

| # | Category | Case | Difficulty | File |
|---|----------|------|------------|------|
| 01 | Finding writing | SMB signing not required (internal) | Easy | [case-01](cases/case-01-smb-signing-finding.md) |
| 02 | Finding writing | Version banner, possible backport | Medium | [case-02](cases/case-02-version-banner-backport.md) |
| 03 | Finding writing | "Decommissioned" host still responding | Hard | [case-03](cases/case-03-decommissioned-host.md) |
| 04 | Configuration review | sshd_config hardening | Easy | [case-04](cases/case-04-sshd-config-hardening.md) |
| 05 | Configuration review | nginx TLS + headers with noise | Medium | [case-05](cases/case-05-nginx-tls-headers.md) |
| 06 | Configuration review | AWS IAM policy with conditions | Hard | [case-06](cases/case-06-iam-policy-conditions.md) |
| 07 | Detection engineering | Sigma rule for service-creation persistence | Medium | [case-07](cases/case-07-sigma-service-creation.md) |
| 08 | Detection engineering | Reduce false positives in an existing rule | Medium | [case-08](cases/case-08-sigma-tuning-powershell.md) |
| 09 | Detection engineering | Detection vs. legitimate admin activity | Hard | [case-09](cases/case-09-wmi-detection-feasibility.md) |
| 10 | Log analysis | 4625 failed logons: spray vs. brute force | Easy | [case-10](cases/case-10-failed-logons-spray.md) |
| 11 | Log analysis | Web attack in access logs amid scanner noise | Medium | [case-11](cases/case-11-web-attack-noise.md) |
| 12 | Log analysis | Lateral movement with timezone ambiguity | Hard | [case-12](cases/case-12-lateral-movement-timezone.md) |
| 13 | Threat analysis | Attack-path summary from nmap | Medium | [case-13](cases/case-13-attack-path-nmap.md) |
| 14 | Threat analysis | Exploitability of a vuln in context | Medium | [case-14](cases/case-14-exploitability-context.md) |
| 15 | Threat analysis | "Were we breached?" with thin evidence | Hard | [case-15](cases/case-15-were-we-breached.md) |
| 16 | Exploit precondition analysis | Preconditions from CVE + exploit snippet | Medium | [case-16](cases/case-16-preconditions-poc.md) |
| 17 | Exploit precondition analysis | Nessus CVE flag, unconfirmed precondition | Hard | [case-17](cases/case-17-nessus-precondition.md) |
| 18 | Documentation and reporting | Executive summary from findings | Easy | [case-18](cases/case-18-executive-summary.md) |
| 19 | Documentation and reporting | Rewrite a finding for a non-technical owner | Medium | [case-19](cases/case-19-rewrite-for-owner.md) |
| 20 | Documentation and reporting | Report section from gappy, conflicting notes | Hard | [case-20](cases/case-20-gappy-notes.md) |
| 21 | Finding writing | Few-shot: match the house finding style | Medium | [case-21](cases/case-21-fewshot-house-style.md) |
| 22 | Documentation and reporting | Reusable Nessus-to-finding skill | Hard | [case-22](cases/case-22-reusable-nessus-skill.md) |
| 23 | Detection engineering / Log analysis | Structured JSON output for a triage pipeline | Medium | [case-23](cases/case-23-structured-json-triage.md) |
| 24 | Threat analysis / Reporting | Role-conditioned dual output | Medium | [case-24](cases/case-24-role-dual-output.md) |
| 25 | Log analysis / SOC operations | Reusable alert-to-ticket responder | Hard | [case-25](cases/case-25-reusable-alert-responder.md) |

## Files

- [`cases/`](cases/) — the 25 evaluation cases, one Markdown file per case (`case-NN-slug.md`).
- [`COVERAGE.md`](COVERAGE.md) — prompt-engineering skill coverage matrix and gap analysis across all 24 cases.

## Design principles baked into the dataset

Every case intentionally contains one or more of:

- **Missing information** — no version, no exposure data, no asset owner.
- **Ambiguous evidence** — banners that could be backported, timestamps without timezones.
- **Contradictory evidence** — client notes that disagree with scan results.
- **Noisy data** — benign scanner traffic, irrelevant log lines, commented-out config.
- **Irrelevant information** — details that look important but do not affect the answer.
- **Edge cases** — findings that are real but low-impact, or high-severity but unexploitable in context.
- **"Insufficient evidence" outcomes** — cases where the correct answer is to withhold a conclusion.

None of these are puzzles. None require obscure CVE trivia. They require careful reading of the evidence in front of you.
