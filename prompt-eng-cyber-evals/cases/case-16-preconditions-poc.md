# Case 16 — Preconditions From a CVE Description and Exploit Snippet

**Category:** Exploit Precondition Analysis

### Metadata
- **Title:** Determine whether a documented exploit's preconditions are satisfied by the target
- **Difficulty:** Medium
- **Estimated completion time:** 35–45 minutes
- **Learning objective:** Extract the concrete preconditions from a CVE writeup and a PoC snippet, then check each against target facts — concluding exploitable, not exploitable, or unconfirmed per precondition.
- **Skills evaluated:** Precondition extraction, mapping requirements to evidence, exploit-code reading, conditional conclusions.

### Student Input

CVE description (paraphrased):

```
An unauthenticated file-upload flaw in "Widgetize CMS" <= 4.2 allows RCE when:
  (1) the /upload endpoint is reachable,
  (2) the 'legacy_uploader' plugin is ENABLED (disabled by default in 4.x),
  (3) PHP is the execution backend (the payload is a .php webshell).
Fixed in 4.3.
```

Proof-of-concept snippet (excerpt):

```python
# poc.py
files = {'file': ('shell.php', PHP_SHELL, 'image/png')}
r = requests.post(f"{target}/upload", files=files,
                  data={'uploader':'legacy'})       # requires legacy_uploader
print(r.json()['stored_path'])                       # then GET stored_path to execute
```

Target facts from the engagement:

```
- HTTP banner / app footer: "Widgetize CMS 4.1".
- /upload returns HTTP 200 to an unauthenticated GET.
- Server header: nginx; X-Powered-By: PHP/7.4.
- Whether 'legacy_uploader' is enabled: UNKNOWN (not enumerated).
```

### Student Task

Ask the LLM to determine whether this target is exploitable via this CVE, going precondition by precondition, and to state the overall conclusion with its confidence.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Precondition extraction | Misses preconditions | Lists some | Extracts all three (endpoint reachable, plugin enabled, PHP backend) plus version ≤ 4.2 | |
| Evidence mapping | Doesn't map to facts | Partial | Maps: version 4.1 ✓, endpoint reachable ✓, PHP backend ✓, plugin enabled = UNKNOWN | |
| Conditional conclusion | "Exploitable" flatly | "Not exploitable" flatly | Concludes exploitability *hinges on the unknown plugin state* — conditionally exploitable, pending plugin-state verification | Disabled-by-default does not mean confirmed-disabled; equally, it does not mean likely-enabled. The answer is genuinely unknown. |
| Exploit-code reading | Misreads the PoC | Minor | Notes the PoC's `uploader:'legacy'` param confirms the plugin dependency | |
| No hallucinated facts | Asserts the plugin is on/off without basis | One | Does not invent the plugin state | |
| Actionable next step | None | Vague | Specifies the exact test to resolve it (attempt the upload / enumerate plugin status) safely | |

### Common Failure Modes
- Declaring the target exploitable because the version matches, ignoring the plugin precondition.
- Declaring it safe because the plugin is "disabled by default" — the default is not the same as the confirmed state.
- Missing that PHP/7.4 satisfies the PHP-backend precondition.
- Over-reading the PoC as proof the target is vulnerable.
- Not proposing the single confirming test.

### Stretch Goal
Ask the LLM to write a *safe validation plan* (non-destructive proof that the plugin is enabled and the upload lands, without dropping a live webshell — e.g., uploading a benign marker file and checking whether it is stored and served) and to note the rules-of-engagement considerations before executing.
