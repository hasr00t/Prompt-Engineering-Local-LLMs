---
author: Ashley
updated: 2026-08-03
presentation_type: Workshop
venue: Antisyphon AI Summit
---

```table-of-contents
title: # Table of Contents
minLevel: 0
maxLevel: 3
```

## Verify Your Environment

Before diving into the labs, confirm that your VM is running and the tools are ready.

### Run the installer

> [!vm] Lab VM
> ```shell
> chmod +x install.sh
>
> ./install.sh
> ```

This should complete without issue, if there are any errors please let me know and we'll work through them together. The root credentials are shown in the MetaCTF/Skillbit workshop page below the VM.

### Confirm Ollama Is Running

> [!vm] Lab VM
> ```shell
> ollama list
> ```

You should see `llama3.2` in the list. If Ollama is not running:

> [!vm] Lab VM
> ```shell
> sudo systemctl start ollama
> ollama list
> ```

### Quick Model Test

Run a quick one-shot prompt to confirm the model responds:

> [!vm] Lab VM
> ```shell
> ollama run llama3.2 "What is a CVE? Answer in one sentence."
> ```

You should get a response within a few seconds. If the response takes more than 30 seconds or errors out, ask for help before continuing.

## The Scenario: CVE-2026-24061

Every lab in this workshop centers on the same vulnerability. You'll write findings about it, generate exploit code and detections for it, and build reusable skills around it.

### What It Is

**CVE-2026-24061** is a critical authentication bypass in GNU inetutils telnetd (through version 2.7-2). An attacker sends a crafted `NEW_ENVIRON` telnet option with the `USER` variable set to `-f root`. The telnet daemon passes this unsanitized value to the `login` process, which interprets `-f root` as "skip authentication and log in as root." The result: instant root shell, no credentials required.

- **CVSS Score:** 9.8 (Critical)
- **Attack Vector:** Network, no authentication required
- **Impact:** Complete system compromise: root access
- **CISA KEV:** Yes, actively exploited in the wild
- **Fix:** Upgrade to GNU inetutils 2.8 or later; disable telnet in favor of SSH

### Why This Vulnerability

This CVE is ideal for learning prompt engineering because:

1. **It's simple to understand** — authentication bypass via environment variable injection
2. **It's real and recent** — CISA added it to the Known Exploited Vulnerabilities catalog in 2026
3. **It has clear offensive and defensive angles** — the exploit is a few lines of Python; the detection is a few lines of Splunk SPL
4. **Your audience has seen it** — every pentester has encountered telnet on legacy hosts, and every blue teamer has been asked to detect unauthorized access

### Your Lab Artifacts

You have two files in the `lab files/artifacts/` directory that simulate what you'd have during a real engagement:

**`cve-2026-24061-nessus.txt`** — A Nessus scan output showing the vulnerability on a target host. This is the raw scanner data that you can copy into a prompt.

**`engagement-notes.txt`** — Engagement context: client name, scope, rules of engagement, and client-provided notes about the affected host. This is important context to give AI so that it understands any constraints or maybe looser rules. Maybe the host has sensitive data or maybe it's a honeypot that they want you to make sure isn't too vulnerable.

Take a minute to read both files. You'll reference them throughout the labs.

> [!vm] Lab VM
> ```shell
> cat ~/lab\ files/artifacts/cve-2026-24061-nessus.txt
> ```

> [!vm] Lab VM
> ```shell
> cat ~/lab\ files/artifacts/engagement-notes.txt
> ```

### Build the Prompt Injection Challenge Models

The prompt injection lab uses custom Modelfiles. Build them now so they're ready when you get to Lab 04:

> [!vm] Lab VM
> ```shell
> cd ~/lab\ files/modelfiles/
> for i in 1 2 3 4 5 6; do
>   ollama create injection-level$i -f Modelfile.injection-$i
>   echo "Built injection-level$i"
> done
> ```

You should see six models build successfully. Each one takes a second or two since they all build on the pre-loaded `llama3.2`.

> [!checkpoint] Checkpoint
> You have finished this lesson when all of the boxes below are ticked.
>
> - [ ] `ollama list` shows `llama3.2`
> - [ ] A one-shot prompt returns a response within a few seconds
> - [ ] You have read both artifact files (`cve-2026-24061-nessus.txt` and `engagement-notes.txt`)
> - [ ] All six `injection-level` models built without error

---

> [!nav]
> [[00 About This Workshop]]
>
> [[02 Building Strong Prompts]]
