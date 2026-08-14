# Case 11 — Web Attack Buried in Scanner Noise

**Category:** Log Analysis

### Metadata
- **Title:** Identify genuine web attacks in an Apache access log amid benign scanning
- **Difficulty:** Medium
- **Estimated completion time:** 35–45 minutes
- **Learning objective:** Pick out a likely-successful attack from a log full of automated scanner noise and one suspicious-looking-but-benign request, and judge success by response codes/sizes.
- **Skills evaluated:** Log triage, HTTP status reasoning, false-positive discrimination, prioritization.

### Student Input

Apache combined access log (excerpt):

```
203.0.113.7 - - [10/Jul/2026:14:02:11 +0000] "GET /wp-login.php HTTP/1.1" 404 209 "-" "Mozilla/5.0 zgrab/0.x"
203.0.113.7 - - [10/Jul/2026:14:02:12 +0000] "GET /.env HTTP/1.1" 404 209 "-" "Mozilla/5.0 zgrab/0.x"
203.0.113.7 - - [10/Jul/2026:14:02:13 +0000] "GET /phpmyadmin/ HTTP/1.1" 404 209 "-" "Mozilla/5.0 zgrab/0.x"
198.51.100.44 - - [10/Jul/2026:14:20:05 +0000] "GET /search?q=SELECT+FROM HTTP/1.1" 200 1841 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
198.51.100.44 - - [10/Jul/2026:14:21:33 +0000] "GET /product?id=10 HTTP/1.1" 200 2203 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
198.51.100.44 - - [10/Jul/2026:14:22:01 +0000] "GET /product?id=10%27 HTTP/1.1" 500 617 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
198.51.100.44 - - [10/Jul/2026:14:22:19 +0000] "GET /product?id=10%27%20UNION%20SELECT%20username%2Cpassword%20FROM%20users-- HTTP/1.1" 200 8402 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
198.51.100.44 - - [10/Jul/2026:14:22:45 +0000] "GET /product?id=11 HTTP/1.1" 200 2198 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
203.0.113.7 - - [10/Jul/2026:14:31:00 +0000] "GET /robots.txt HTTP/1.1" 200 88 "-" "Mozilla/5.0 zgrab/0.x"
```

Client note:

```
- /product?id= is backed by a database. /search is a static site-search widget
  (returns the same page regardless of query).
- Reminder: request paths in the raw log are URL-encoded (%27 = ', %20 = space,
  %2C = comma). Decode before interpreting.
```

### Student Task

Ask the LLM to identify which entries represent a real attack, whether it appears successful, and which entries are benign noise — then recommend next steps.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Identifies the real attack | Misses the SQLi | Flags it weakly | Identifies the `/product?id=` SQLi sequence from 198.51.100.44 | |
| Judges likely success | Ignores status/size | Mentions codes | Reasons that the `500` on `id=10'` then a `200` with a much larger body (8402) on the UNION suggests successful extraction | Evidence-based, still probabilistic. |
| Discriminates false positive | Flags `/search?q=SELECT` as SQLi | Unsure | Recognizes `/search` is static (per note) and the SQL-looking query is not an injection there | The planted FP. |
| Noise handling | Treats zgrab 404s as attacks | Partial | Classifies the zgrab 404 sweep as benign automated scanning | |
| Prioritization | Flat list | Loose | Leads with the confirmed-looking SQLi over the scanner noise | |
| Actionable next step | None | Vague | Recommends pulling the app/db logs for 14:22, checking for data egress, and reviewing the `id` parameter's query handling | |

### Common Failure Modes
- Flagging `/search?q=SELECT+FROM` as SQL injection despite it hitting a static widget.
- Treating the zgrab 404 scan as a serious attack.
- Declaring the SQLi "confirmed successful" with certainty (it is *likely*, from response size — not proven).
- Missing the significance of the 500-then-200 size jump.
- Attributing the attack to a named actor or assuming internet-wide campaign.

### Stretch Goal
Ask the LLM to reconstruct a concise incident timeline for source 198.51.100.44 (recon → probe → exploit) and to specify exactly which correlating evidence in the *application* and *database* logs would move the assessment from "likely successful" to "confirmed data exposure."
