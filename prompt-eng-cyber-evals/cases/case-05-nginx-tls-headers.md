# Case 05 — nginx TLS and Security Headers, With Distractions

**Category:** Configuration Review

### Metadata
- **Title:** Review an nginx server block for TLS and header misconfigurations amid noise
- **Difficulty:** Medium
- **Estimated completion time:** 30–40 minutes
- **Learning objective:** Find the real weaknesses (TLS version, missing headers) while ignoring commented blocks and a directive that looks alarming but is correct in context.
- **Skills evaluated:** Contextual judgment, noise filtering, header/TLS knowledge, remediation specificity.

### Student Input

`/etc/nginx/conf.d/app.conf` (excerpt):

```nginx
server {
    listen 443 ssl;
    server_name app.example.com;

    ssl_certificate     /etc/nginx/certs/app.crt;
    ssl_certificate_key /etc/nginx/certs/app.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    add_header X-Frame-Options "SAMEORIGIN";
    # add_header Strict-Transport-Security "max-age=31536000" always;
    # add_header Content-Security-Policy "default-src 'self'";

    server_tokens on;

    location /healthz {
        access_log off;
        return 200 'ok';
    }

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

# Legacy block — kept for reference, not loaded
# server {
#     listen 80;
#     ssl_protocols SSLv3;
#     ...
# }
```

Client note:

```
- Public-facing marketing/app site. Compliance wants "modern TLS."
- proxy_pass to localhost:8080 is the intended app backend.
```

### Student Task

Ask the LLM to identify the security misconfigurations in the active server block and recommend fixes, appropriate for a public site with a "modern TLS" requirement.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Technical accuracy | Misidentifies the TLS issue | Partial | Flags `TLSv1`/`TLSv1.1` enabled and `server_tokens on`; notes HSTS/CSP present but commented (inactive) | |
| Precision (no over-flagging) | Flags `proxy_pass http://127.0.0.1` as cleartext exposure | One false flag | Recognizes localhost proxy over HTTP is normal and not a finding | The alarming-but-fine line. |
| Noise filtering | Treats the commented legacy `SSLv3` block as an active critical finding | Mentions it ambiguously | Ignores it as unloaded, or explicitly notes it is commented and thus not active | |
| Completeness | Misses HSTS/CSP being commented out | Catches one | Catches disabled HSTS, disabled CSP, weak TLS versions, and version disclosure | |
| Actionable remediation | Vague | Correct, imprecise | Exact directives: `ssl_protocols TLSv1.2 TLSv1.3;`, uncomment/enable HSTS+CSP, `server_tokens off;` | |
| Correct prioritization | Random | Loose | Weak TLS and missing HSTS ahead of version disclosure | |

### Common Failure Modes
- Reporting the **commented** `SSLv3` legacy block as a live critical finding.
- Flagging the localhost `proxy_pass` over HTTP as a plaintext-transmission vulnerability.
- Missing that HSTS and CSP are present but commented out (a subtle "almost right" config).
- Recommending TLSv1.2-only without also enabling TLSv1.3.
- Over-flagging `ssl_ciphers HIGH:!aNULL:!MD5` as broken when it is acceptable (improvable, not a hole).

### Stretch Goal
Ask the LLM to propose a CSP that would realistically work for a proxied app (acknowledging it cannot know the app's asset origins), and to explain why a copy-paste `default-src 'self'` may break the site — demonstrating that it should flag the *need to test* rather than assert a final CSP.
