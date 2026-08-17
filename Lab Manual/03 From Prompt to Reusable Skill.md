---
author: Ashley
updated: 2026-08-15
presentation_type: Workshop
venue: Antisyphon AI Summit
---

```table-of-contents
title: # Table of Contents
minLevel: 0
maxLevel: 3
```

# Lab: From Prompt to Reusable Skill

In the previous lab, you built a prompt that produces good output for *one specific vulnerability*. That prompt dies when you close the session. In this lab, you'll turn it into a **reusable skill**: a Modelfile with a structured SYSTEM prompt that works across varied inputs. You will test it using a structured evaluation method.

Like the previous lab, this one has a red path and a blue path. Red teamers will build a **finding writer** that converts Nessus scan output into client-ready pentest findings. Blue teamers will build an **alert responder** that converts SIEM alerts into structured investigation ticket responses. Both paths follow the same workflow: plan, build, evaluate, iterate.

If you took the *Keeping Things Local* workshop, you already know how to build Modelfiles with `FROM`, `PARAMETER`, and `SYSTEM`. This lab builds on that foundation, but instead of a persona (Daffy Duck) or a simple task (quizmaker), you're building a professional tool.

---

## What Goes Where: The Decision Framework

Before you start building, you need to answer a question that comes up in every AI tool: **where should this instruction live?**

Every AI tool has layers: things you type once per conversation, things that persist across sessions, and things baked into the model itself. The layers look different depending on the tool, but the decision is always the same.

### The Three Layers

| Layer | What goes here | Lifespan |
|-------|---------------|----------|
| **The prompt** | Anything that changes per task: the specific input, the specific question, engagement-specific context | One conversation |
| **Persistent instructions** | Anything you'd want every time you do this *type* of work: output format, tone, constraints, your firm's template, banned words | Every session that loads them |
| **The model** | General knowledge, language ability, reasoning | Permanent (you don't control this with local models) |

The middle layer is the one people get wrong. They either put everything in the prompt (re-typing the same format instructions every session) or they try to bake everything into persistent instructions (making them so long they waste tokens on context that only applies sometimes).

**The test:** Before putting an instruction in a persistent file, ask: *will I want this instruction next time too?* If yes, it belongs in the persistent layer. If it depends on the engagement, the client, or the input, it belongs in the prompt.

### How This Looks Across Tools

The persistent-instruction layer has a different name in every tool, but it works the same way:

| Tool | Persistent instructions file | How it loads |
|------|------------------------------|-------------|
| **Ollama** | Modelfile `SYSTEM` block | Baked in at `ollama create`; edit the file and rebuild to update |
| **Claude Code** | `CLAUDE.md` in the project directory | Read automatically when Claude Code opens the directory |
| **ChatGPT** | Custom Instructions / GPT configuration | Set in account settings or GPT builder |
| **Cursor** | `.cursorrules` in the project root | Read automatically when the project opens |
| **API calls** | The `system` parameter | Passed on every request by your code |

Different mechanisms, same judgment call. Here are examples of that judgment:

| Instruction | Layer | Why |
|-------------|-------|-----|
| "Use this finding format: Title, Severity, Description..." | **Persistent** (Modelfile / CLAUDE.md) | Same format every engagement |
| "The client is Initech Corporation, internal network scope" | **Prompt** | Changes every engagement |
| "Never invent CVEs not present in the evidence" | **Persistent** | You always want this constraint |
| "This host runs a legacy inventory app that needs telnet" | **Prompt** | Specific to one host on one engagement |
| "Write in a direct, professional tone. No em dashes." | **Persistent** | Your style standard doesn't change |
| "Focus on the business impact for a non-technical CISO" | **Prompt** | Depends on the audience for this report |

### What a Good CLAUDE.md Looks Like

If you use Claude Code, your `CLAUDE.md` is the equivalent of a Modelfile's SYSTEM block. Here are examples for both paths:

**Red team (pentest report automation):**

```markdown
# Project: Pentest Report Automation

## Role
Senior penetration tester writing findings for client deliverables.

## Output Standards
- Use the firm's finding template: Title, Severity, Affected Host(s),
  Description, Impact, Evidence, Remediation, References
- Justify severity ratings, don't just state them
- Quote scanner output in the Evidence section

## Constraints
- Never invent CVEs, version numbers, or exposure data not in the input
- Never assign severity higher than evidence supports
- Mark version-only findings as "Needs Validation" with a backport note
- Downgrade informational/noise findings, don't present port scans as risks

## Style
- Direct, professional, factual tone
- No marketing language, superlatives, or filler
- No em dashes, no "crucial," no "robust," no "landscape," no "delve"
```

**Blue team (SOC ticket automation):**

```markdown
# Project: SOC Investigation Response

## Role
Senior SOC analyst writing investigation ticket responses.

## Output Standards
- Use the team's ticket template: Title, Priority, Alert Summary,
  Investigation Steps, Findings, Containment, Escalation, Next Steps
- Justify priority and escalation decisions with specific evidence
- Document every investigation step, even the ones that found nothing

## Constraints
- Never close a ticket without documenting what you checked
- Never classify an alert as a false positive without stating the
  specific evidence that rules out malicious activity
- If evidence is insufficient, recommend follow-up rather than guessing
- Do not speculate about attacker intent beyond what the data shows

## Style
- Direct, professional, factual tone
- No marketing language, superlatives, or filler
- No em dashes, no "crucial," no "robust," no "landscape," no "delve"
```

Notice what's NOT in either: the specific alert, the specific client, the specific host. Those change per task and go in the prompt.

### What a Good Modelfile SYSTEM Looks Like

You'll build one in the next section. The same principles apply. The SYSTEM block carries the instructions that are true for every run of this skill. The per-run input comes from what the user types at the `>>>` prompt.

---

## Part 1: Plan, Build, and Test

One of the most effective prompt engineering techniques is **separating planning from execution**. When you plan and build in the same session, the conversation accumulates context that can pollute the model's output: earlier bad attempts, corrections, tangents. A clean session with a refined prompt produces better results than a long session that arrived at the same prompt through trial and error.

Pick your path below. If you finish early, try the other one.

---

### Red Path: Finding Writer

Your goal: build a Modelfile that converts any Nessus scan output into a client-ready penetration test finding.

#### Step 1: Plan the Skill (This Session)

Open a session and have the model help you design the skill. You're not asking it to write findings yet. You're asking it to help you design the *instructions* that will write findings.

> [!vm] Lab VM
> ```shell
> ollama run llama3.2
> ```

```
I need to design a reusable prompt that converts any Nessus scan 
output into a client-ready penetration test finding. The prompt 
should work for any Nessus plugin, whether it's a clear 
vulnerability, an ambiguous version-based finding, or a 
context-dependent finding where severity depends on network 
position.

Help me design the instruction set. What sections, constraints, 
and output template should the prompt include to handle all three 
cases correctly?
```

Iterate with the model on the design. Think about:
- What output format should every finding follow?
- How should the skill handle ambiguous evidence (like version banners that might be backported)?
- How should severity change based on network context (internal vs. externally facing)?
- What should it *never* do (invent CVEs, inflate severity, fabricate evidence)?

#### Step 2: Build the Modelfile (Fresh Session)

Exit the planning session (`/bye`). Now open a text editor and create a Modelfile. The file should live at `~/Modelfile.findingwriter`:

> [!vm] Lab VM
> ```shell
> nano ~/Modelfile.findingwriter
> ```

Use this skeleton and fill in the SYSTEM block with the instructions you designed:

```
FROM llama3.2

PARAMETER temperature 0.3

SYSTEM """
# IDENTITY AND PURPOSE

You are a senior penetration tester converting Nessus scan output 
into client-ready findings for a penetration test report.

# INSTRUCTIONS

[Your designed instructions go here: the steps the model should 
follow for every input]

# CONSTRAINTS

[Your constraints: what the model must never do]

- Never assign a severity higher than the evidence supports.
- Never invent CVE numbers, version numbers, or exposure data 
  not present in the input.
- If the finding is based solely on a version banner, mark 
  Confidence as "Needs Validation" and note that vendor backports 
  may apply.
- Consider network position when assessing severity. The same 
  service on an internal host and an internet-facing host carry 
  different risk levels.

# OUTPUT TEMPLATE

Title:
Severity: [Critical / High / Medium / Low / Informational]
Affected Asset: [IP and port from the input]
Description: [2-3 sentences, what the vulnerability is]
Impact: [What an attacker could do]
Evidence: [Quote the relevant scanner output]
Remediation: [Specific, actionable steps]
Confidence: [Confirmed / Needs Validation / Informational]

# INPUT:

"""
```

> [!tip] Why temperature 0.3?
> You want consistency, not creativity. A lower temperature makes the model stick to your template and constraints more reliably. The *Keeping Things Local* workshop used temperature 1.0 for Daffy Duck because variety was the goal. Here, predictability is.

Build and test it:

> [!vm] Lab VM
> ```shell
> ollama create findingwriter -f ~/Modelfile.findingwriter
> ollama run findingwriter
> ```

Paste your CVE-2026-24061 Nessus output from the artifacts and see if the output follows your template.

---

### Blue Path: Alert Responder

Your goal: build a Modelfile that converts SIEM alerts into structured SOC investigation ticket responses.

#### Step 1: Plan the Skill (This Session)

Open a session and have the model help you design the skill. You're not asking it to write tickets yet. You're asking it to help you design the *instructions* that will write them.

> [!vm] Lab VM
> ```shell
> ollama run llama3.2
> ```

```
I need to design a reusable prompt that converts SIEM alerts into 
structured SOC investigation ticket responses. The prompt should 
work for any alert type: clear true positives that need immediate 
action, ambiguous alerts that require further investigation, and 
context-dependent alerts where priority depends on exposure and 
asset criticality.

Help me design the instruction set. What sections, constraints, 
and output template should the prompt include to handle all three 
cases correctly?
```

Iterate with the model on the design. Think about:
- What output format should every ticket response follow?
- How should the skill handle ambiguous alerts where the source could be legitimate or malicious?
- How should priority change based on context (asset criticality, network exposure, prior history)?
- What should it *never* do (close without documenting, classify as false positive without evidence)?

#### Step 2: Build the Modelfile (Fresh Session)

Exit the planning session (`/bye`). Now open a text editor and create a Modelfile. The file should live at `~/Modelfile.alertresponder`:

> [!vm] Lab VM
> ```shell
> nano ~/Modelfile.alertresponder
> ```

Use this skeleton and fill in the SYSTEM block with the instructions you designed:

```
FROM llama3.2

PARAMETER temperature 0.3

SYSTEM """
# IDENTITY AND PURPOSE

You are a senior SOC analyst converting SIEM alerts into structured 
investigation ticket responses.

# INSTRUCTIONS

[Your designed instructions go here: the steps the model should 
follow for every alert]

# CONSTRAINTS

[Your constraints: what the model must never do]

- Never close a ticket without documenting investigation steps taken.
- Never classify an alert as a false positive without stating the 
  specific evidence that rules out malicious activity.
- If the alert data is insufficient to make a determination, 
  recommend specific follow-up actions rather than guessing.
- Do not speculate about attacker intent beyond what the evidence 
  shows.
- Consider asset criticality and network exposure when assessing 
  priority. The same alert on an internal workstation and an 
  internet-facing server carry different urgency.

# OUTPUT TEMPLATE

Ticket Title:
Priority: [Critical / High / Medium / Low]
Alert Summary: [What fired and why, in 2-3 sentences]
Investigation Steps: [What you checked and what you found]
Findings: [What the evidence shows]
Containment Actions: [If applicable, what was done or should be done]
Escalation: [Yes/No, with justification]
Recommended Next Steps: [Specific follow-up actions]

# ALERT DATA:

"""
```

Build and test it:

> [!vm] Lab VM
> ```shell
> ollama create alertresponder -f ~/Modelfile.alertresponder
> ollama run alertresponder
> ```

Paste the following test alert and see if the output follows your template:

```
Alert: Telnet Authentication Bypass Detected
Severity: Critical
Timestamp: 2026-08-14 03:42:17 UTC
Source IP: 198.51.100.47 (external, no prior history)
Destination: 10.14.5.15:23 (linux-legacy-01, internal server)
Rule: CVE-2026-24061 NEW_ENVIRON -f root detected in telnet session
Auth Log: Root login via telnetd at 03:42:19 UTC, no password 
  authentication recorded.
```

---

## Part 2: Evaluate With a Rubric

A good skill works across varied inputs, not just the one you tested it on. The evaluation method here is simple: **score each output criterion on a 0-1-2 scale**, identify the weakest criterion, and fix it.

### The Scoring Convention

Every criterion gets a **0, 1, or 2**:

| Score | Meaning |
|-------|---------|
| **0** | Fails: absent, wrong, or actively misleading |
| **1** | Partial: present but incomplete, hedged incorrectly, or with gaps |
| **2** | Full: meets the criterion cleanly |

Run your skill against all three test inputs for your path **without changing the skill between runs**. The skill must handle all three correctly as-is.

---

### Red Path Test Inputs

**Input A: Clear, actionable finding**

```
Plugin 57690 - Microsoft Windows SMBv1 Enabled
Host: 10.14.5.20 (tcp/445)   Risk: High
Synopsis: The remote host supports the SMBv1 protocol.
Plugin Output: The remote host supports SMB version 1. SMBv1 has known
  design weaknesses and is deprecated by Microsoft.
Solution: Disable SMBv1 and use SMBv2/3.
```

**Input B: Ambiguous, version-based finding**

```
Plugin 100123 - OpenSSH < 8.0 Multiple Vulnerabilities
Host: 10.14.5.31 (tcp/22)    Risk: High
Synopsis: The SSH server is running an outdated version of OpenSSH.
Plugin Output: Detected version: OpenSSH 7.4 (banner).
Detection Method: Banner version check.
Note (from engagement): host is RHEL 7; vendor backports security fixes.
```

**Input C: Context-dependent finding**

```
Plugin 42263 - Unencrypted Telnet Server
Host: 10.14.5.44 (tcp/23)    Risk: Low
Synopsis: The remote host is running a telnet server.
Plugin Output: The telnet service is listening on port 23/tcp.
  All traffic including credentials will be transmitted in cleartext.
Scope Note (from engagement): This host is in the external DMZ. 
  Firewall rules permit inbound TCP/23 from any source. The host 
  is reachable from the internet.
```

#### Red Path Rubric

| Criterion | Input A | Input B | Input C |
|-----------|---------|---------|---------|
| **Follows the output template exactly** | | | |
| **Severity matches the evidence** | | | |
| **Confidence level is appropriate** (Confirmed / Needs Validation / Informational) | | | |
| **No hallucinated CVEs, versions, or data** | | | |
| **Remediation is specific and actionable** | | | |
| **Total (out of 10)** | | | |

#### Red Path: Interpret Your Scores

- **Input A** should score high. If it doesn't, your basic instructions are wrong.
- **Input B** is the litmus test for ambiguity handling. A score of 2 on Confidence means your skill correctly marks it as "Needs Validation" and mentions backporting. A 0 means your skill declared it confirmed-vulnerable based on a banner alone. That mistake ends up in real reports all the time.
- **Input C** tests whether your skill considers context. Nessus flagged this as Low, but the engagement notes say it's internet-facing. Telnet on an internal network is a minor issue (no encryption, but limited exposure). Telnet exposed to the internet is a serious finding: credentials in cleartext over an untrusted network, and the service accepts connections from anyone. If your skill echoed the scanner's Low rating without considering the external exposure, your constraints need work.

---

### Blue Path Test Inputs

**Input A: Clear true positive**

```
Alert: Telnet Authentication Bypass Detected
Severity: Critical
Timestamp: 2026-08-14 03:42:17 UTC
Source IP: 198.51.100.47 (external, no prior history)
Destination: 10.14.5.15:23 (linux-legacy-01, internal server)
Rule: CVE-2026-24061 NEW_ENVIRON -f root detected in telnet session
Auth Log: Root login via telnetd at 03:42:19 UTC, no password 
  authentication recorded.
Network Log: 4.2 MB data transfer from 10.14.5.15 to 198.51.100.47 
  over 12 minutes following login.
Context: Host runs legacy inventory application. Telnet service is 
  required per change advisory CA-2026-0142.
```

**Input B: Ambiguous alert**

```
Alert: Multiple Failed SSH Authentication Attempts
Severity: Medium
Timestamp: 2026-08-14 09:15:00 - 09:47:00 UTC
Source IP: 203.0.113.88
Destination: 10.14.5.31:22 (jump-box-01)
Auth Log: 47 failed login attempts for user "svc_backup" over 32 
  minutes. All attempts used password authentication. No successful 
  logins from this source during this window.
Context: 203.0.113.88 is registered to Acme Managed Services, the 
  client's contracted backup vendor. svc_backup is a legitimate 
  service account used by Acme for nightly backup operations.
Previous Activity: This source IP has authenticated successfully 
  on 12 of the last 14 days between 01:00-02:00 UTC.
```

**Input C: Context-dependent alert**

```
Alert: Cleartext Protocol on Internet-Facing Host
Severity: Low
Timestamp: 2026-08-14 14:00:03 UTC
Source: Scheduled vulnerability scan (Nessus)
Destination: 10.14.5.44:23 (dmz-legacy-01)
Finding: Telnet service (port 23/tcp) is running and accepting 
  connections on a host in the external DMZ.
Network Context: dmz-legacy-01 has a firewall rule permitting 
  inbound TCP/23 from any source. The host is reachable from the 
  internet.
Asset Owner: Facilities team. Host manages building HVAC controls.
Previous Tickets: None for this host.
```

#### Blue Path Rubric

| Criterion | Input A | Input B | Input C |
|-----------|---------|---------|---------|
| **Follows the output template exactly** | | | |
| **Priority matches the evidence** | | | |
| **Investigation steps are specific and logical** | | | |
| **No speculative claims beyond what evidence shows** | | | |
| **Next steps are actionable** | | | |
| **Total (out of 10)** | | | |

#### Blue Path: Interpret Your Scores

- **Input A** should score high. Clear indicators of compromise: external IP, no prior history, authentication bypass, data exfiltration. If the skill doesn't recommend immediate containment and escalation, the instructions are too passive.
- **Input B** is the litmus test for ambiguity handling. A score of 2 on Investigation Steps means the skill identified both the suspicious pattern (47 failed logins on a service account) and the mitigating context (known vendor, legitimate account, normal activity pattern on most days) and recommended targeted investigation. A 0 means it jumped straight to "brute force attack, block the IP" without considering the vendor relationship, or dismissed it as normal without investigating why the logins are failing during an unusual time window.
- **Input C** tests context awareness. The scan flagged it as Low, but this is internet-facing telnet on a host that controls physical building systems. Cleartext credentials over the internet plus access to HVAC controls is not a Low-priority ticket. If your skill echoed the scanner's severity without factoring in the exposure and asset criticality, your constraints need work.

---

### Fix and Re-Test

Look at your lowest-scoring criterion. Edit your Modelfile to address it, rebuild, and test again:

> [!vm] Lab VM
> ```shell
> # Red path:
> nano ~/Modelfile.findingwriter
> ollama create findingwriter -f ~/Modelfile.findingwriter
> ollama run findingwriter
>
> # Blue path:
> nano ~/Modelfile.alertresponder
> ollama create alertresponder -f ~/Modelfile.alertresponder
> ollama run alertresponder
> ```

Run the same three inputs. Did the score improve? Did fixing one thing break another?

This is the core loop of prompt engineering: **change, test, score, repeat**.

---

## Part 3: The Skill Is the Deliverable

You now have a Modelfile that:
- Encodes your professional judgment about how this type of work should be done
- Handles clear, ambiguous, and context-dependent inputs differently
- Produces consistent, structured output
- Can be shared with teammates or loaded on any Ollama instance

This is what a **skill** is in practice: a reusable, structured package of knowledge that makes an AI good at one specific task. You didn't retrain the model. You wrote a system prompt that carries your expertise.

> [!tip] Stretch Goal
> If you finish early, try feeding your skill a deliberately weird input. Red path: a Burp Suite web application finding instead of a Nessus plugin, or a hand-written vulnerability note with no structured fields. Blue path: a raw syslog dump instead of a structured alert, or an alert from a completely different product than the one you designed for. Does the skill degrade gracefully (mapping what it can, flagging what it can't)? Or does it hallucinate a well-formed but wrong response? That tells you how strong your constraints are.

> [!checkpoint] Checkpoint
> You have finished this lab when all of the boxes below are ticked.
>
> - [ ] You chose a path (red: findingwriter, blue: alertresponder) and planned the skill in one session
> - [ ] You built the Modelfile in a fresh session and it creates without error
> - [ ] You ran the skill against all three test inputs without modifying the skill between runs
> - [ ] You scored each output using the rubric and identified the weakest criterion
> - [ ] You iterated on the Modelfile at least once and re-tested

> [!tip] Practice Cases
> The `prompt-eng-cyber-evals/cases/` directory has formal evaluation cases with detailed rubrics for this exact exercise:
>
> - **Case 22** (Hard): Build a reusable Nessus-to-finding skill and test it against three inputs (red path)
> - **Case 25** (Hard): Build a reusable alert-to-ticket skill and test it against three inputs (blue path)
>
> These cases have more detailed rubrics and common failure modes documented. Good for testing your skill after the workshop, or for comparing your approach with a teammate's.

---

> [!nav]
> [[02 Building Strong Prompts]]
>
> [[04 Prompt Injection Challenge]]
