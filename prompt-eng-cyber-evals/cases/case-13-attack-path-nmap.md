# Case 13 — Attack-Path Summary From an nmap Sweep

**Category:** Threat Analysis

### Metadata
- **Title:** Summarize plausible attack paths across a small internal segment
- **Difficulty:** Medium
- **Estimated completion time:** 35–45 minutes
- **Learning objective:** Build attack-path narratives that are grounded in the scan evidence, label each link's confidence, and avoid inventing the pivots that the data does not show.
- **Skills evaluated:** Attack-path reasoning, evidence grounding, prioritization, confidence labeling.

### Student Input

nmap sweep of segment 10.30.5.0/24 (assumed-breach, low-priv foothold on 10.30.5.60):

```
10.30.5.10  DC01     open: 53,88,389,445,3268  (Windows, SMB signing: True)
10.30.5.22  SQL01    open: 445,1433            (SMB signing: False)
10.30.5.30  JENKINS  open: 8080,22            (HTTP title: "Dashboard [Jenkins]")
10.30.5.45  FILE01   open: 445                 (SMB signing: False)  share: \\FILE01\backups (READ, anon)
10.30.5.60  WKS-FOOThold  (our access: local admin, standard user 'temp1')
```

Additional evidence:

```
- Jenkins 8080 returns HTTP 200, login page present (auth required, version not shown).
- \\FILE01\backups anonymous READ confirmed; a directory listing shows
  "DC01-sysvol-backup-2026-06.zip" (contents NOT downloaded/inspected).
- No credentials cracked yet. No confirmed admin access to any server.
```

### Student Task

Ask the LLM to summarize the most promising attack paths from the 10.30.5.60 foothold toward domain compromise, ranked, with the evidence and assumptions behind each.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Evidence grounding | Paths rely on facts not present | Mostly grounded | Every path cites specific scan evidence (SMB signing False, anon backup share, Jenkins) | |
| Confidence labeling | States paths as certain | Some hedging | Marks each link as confirmed vs. assumed (e.g., relay needs a coercion + admin target — assumed) | |
| Prioritization | Arbitrary order | Loose | Ranks by likelihood/impact (the anon SYSVOL backup is a strong lead; relay to SQL01/FILE01 next) | |
| No hallucinated facts | Invents Jenkins version/CVE or backup contents | One | Does not claim the backup contains hashes without inspecting it; no invented version | The zip is a lead, not proof. |
| Technical accuracy | Misreads signing/relay logic | Minor | Correct on where SMB relay is viable (signing False hosts) and DC being protected (signing True) | |
| Actionable next step | None | Vague | Concrete next actions per path (download+inspect the backup, test relay, enumerate Jenkins) | |

### Common Failure Modes
- Asserting the SYSVOL backup contains GPP/credential material before inspecting it.
- Proposing an SMB relay to the DC (signing True) despite the evidence.
- Inventing a Jenkins version and a matching RCE CVE.
- Presenting assumed pivots (cracked creds, admin rights) as already achieved.
- Failing to rank — dumping every host as equally interesting.

### Stretch Goal
Ask the LLM to render the attack paths as a short attack-tree (or mermaid graph) with each edge annotated `[confirmed]` or `[requires: …]`, so the assumptions are visible at a glance — and to identify which *single* next action would validate the most paths at once.
