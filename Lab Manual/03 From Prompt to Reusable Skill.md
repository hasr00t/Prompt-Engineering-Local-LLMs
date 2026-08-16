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

# Lab: From Prompt to Reusable Skill

In the previous lab, you built a prompt that produces a good finding for *one specific vulnerability*. That prompt dies when you close the session. In this lab, you'll turn it into a **reusable skill**: a Modelfile with a structured SYSTEM prompt that works across *any* Nessus finding. You will test it using a structured evaluation method.

If you took the *Keeping Things Local* workshop, you already know how to build Modelfiles with `FROM`, `PARAMETER`, and `SYSTEM`. This lab builds on that foundation, but instead of a persona (Daffy Duck) or a simple task (quizmaker), you're building a professional tool.

---

## What Goes Where: The Decision Framework

Before you start building, you need to answer a question that comes up in every AI tool **where should this instruction live?**

Every AI tool has layers... things you type once per conversation, things that persist across sessions, and things baked into the model itself. The layers look different depending on the tool, but the decision is always the same.

### The Three Layers

| Layer | What goes here | Lifespan |
|-------|---------------|----------|
| **The prompt** | Anything that changes per task: the specific input, the specific question, engagement-specific context | One conversation |
| **Persistent instructions** | Anything you'd want every time you do this *type* of work: output format, tone, constraints, your firm's template, banned words | Every session that loads them |
| **The model** | General knowledge, language ability, reasoning | Permanent (you don't control this with local models) |

The middle layer is the one people get wrong. They either put everything in the prompt (re-typing the same format instructions every session) or they try to bake everything into persistent instructions (making them so long they waste tokens on context that only applies sometimes).

**The test:** Before putting an instruction in a persistent file, ask *will I want this instruction next time too?* If yes, it belongs in the persistent layer. If it depends on the engagement, the client, or the input, it belongs in the prompt.

### How This Looks Across Tools

The persistent-instruction layer has a different name in every tool, but it works the same way:

| Tool | Persistent instructions file | How it loads |
|------|------------------------------|-------------|
| **Ollama** | Modelfile `SYSTEM` block | Baked in at `ollama create` — edit the file and rebuild to update |
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

If you use Claude Code, your `CLAUDE.md` is the equivalent of a Modelfile's SYSTEM block. A good one for security work might include:

```markdown
# Project: Pentest Report Automation

## Role
Senior penetration tester writing findings for client deliverables.

## Output Standards
- Use the firm's finding template: Title, Severity, Affected Host(s),
  Description, Impact, Evidence, Remediation, References
- Justify severity ratings don't just state them
- Quote scanner output in the Evidence section

## Constraints
- Never invent CVEs, version numbers, or exposure data not in the input
- Never assign severity higher than evidence supports
- Mark version-only findings as "Needs Validation" with a backport note
- Downgrade informational/noise findings don't present port scans as risks

## Style
- Direct, professional, factual tone
- No marketing language, superlatives, or filler
- No em dashes, no "crucial," no "robust," no "landscape," no "delve"
```

Notice what's NOT in there: the specific vulnerability, the specific client, the specific host. Those change per task and go in the prompt.

### What a Good Modelfile SYSTEM Looks Like

You'll build one in the next section. The same principles apply. The SYSTEM block carries the instructions that are true for every run of this skill. The per-run input comes from what the user types at the `>>>` prompt.

---

## Part 1: Separate Planning from Execution

One of the most effective prompt engineering techniques is **separating planning from execution**. When you plan and build in the same session, the conversation accumulates context that can pollute the model's output: earlier bad attempts, corrections, tangents. A clean session with a refined prompt produces better results than a long session that arrived at the same prompt through trial and error.

### Step 1: Plan the Skill (This Session)

Open a session and have the model help you design the skill. You're not asking it to write findings yet you're asking it to help you design the *instructions* that will write findings.

> [!vm] Lab VM
> ```shell
> ollama run llama3.2
> ```

```
I need to design a reusable prompt that converts any Nessus scan output into a client-ready penetration test finding. The prompt should work for any Nessus plugin whether it's a clear vulnerability, an ambiguous version-based finding, or a context-dependent finding where severity depends on network position.

Help me design the instruction set. What sections, constraints, and output template should the prompt include to handle all three cases correctly?
```

Iterate with the model on the design. Think about:
- What output format should every finding follow?
- How should the skill handle ambiguous evidence (like version banners that might be backported)?
- How should it handle informational/noise findings that aren't real vulnerabilities?
- What should it *never* do (invent CVEs, inflate severity, fabricate evidence)?

### Step 2: Build the Modelfile (Fresh Session)

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

You are a senior penetration tester converting Nessus scan output into client-ready findings for a penetration test report.

# INSTRUCTIONS

[The instructions you made with the prompt above go here.]

# CONSTRAINTS

[Your constraints — what the model must never do]

- Never assign a severity higher than the evidence supports.
- Never invent CVE numbers, version numbers, or exposure data 
  not present in the input.
- If the finding is based solely on a version banner, mark 
  Confidence as "Needs Validation" and note that vendor backports 
  may apply.
- If the input is purely informational (e.g., port scan, service 
  detection), classify it as Informational and do not present it 
  as a security risk.

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

## Part 2: Evaluate With a Rubric

A good skill works across varied inputs, not just the one you tested it on. The evaluation method here is simple: **score each output criterion on a 0-1-2 scale**, identify the weakest criterion, and fix it.

### The Scoring Convention

Every criterion gets a **0, 1, or 2**:

| Score | Meaning |
|-------|---------|
| **0** | Fails — absent, wrong, or actively misleading |
| **1** | Partial — present but incomplete, hedged incorrectly, or with gaps |
| **2** | Full — meets the criterion cleanly |

### The Three Test Inputs

Run your `findingwriter` skill against these three inputs **without changing the skill between runs**. The skill must handle all three correctly as-is.

**Input A — Clear, actionable finding:**

```
Plugin 57690 - Microsoft Windows SMBv1 Enabled
Host: 10.14.5.20 (tcp/445)   Risk: High
Synopsis: The remote host supports the SMBv1 protocol.
Plugin Output: The remote host supports SMB version 1. SMBv1 has known
  design weaknesses and is deprecated by Microsoft.
Solution: Disable SMBv1 and use SMBv2/3.
```

**Input B — Ambiguous, version-based finding:**

```
Plugin 100123 - OpenSSH < 8.0 Multiple Vulnerabilities
Host: 10.14.5.31 (tcp/22)    Risk: High
Synopsis: The SSH server is running an outdated version of OpenSSH.
Plugin Output: Detected version: OpenSSH 7.4 (banner).
Detection Method: Banner version check.
Note (from engagement): host is RHEL 7; vendor backports security fixes.
```

**Input C — Informational noise:**

```
Plugin 11219 - Nessus SYN scanner (Service Detection)
Host: 10.14.5.44 (tcp/443)   Risk: None / Info
Synopsis: It was possible to identify open ports and running services.
Plugin Output: Port 443/tcp was found to be open.
```

### Score Each Output

For each of the three outputs, score these criteria:

| Criterion | Input A | Input B | Input C |
|-----------|---------|---------|---------|
| **Follows the output template exactly** | | | |
| **Severity matches the evidence** | | | |
| **Confidence level is appropriate** (Confirmed / Needs Validation / Informational) | | | |
| **No hallucinated CVEs, versions, or data** | | | |
| **Remediation is specific and actionable** | | | |
| **Total (out of 10)** | | | |

### Interpret Your Scores

- **Input A** should score high. If it doesn't, your basic instructions are wrong.
- **Input B** is the litmus test. A score of 2 on Confidence means your skill correctly marks it as "Needs Validation" and mentions backporting. A 0 means your skill declared it confirmed-vulnerable based on a banner alone. That mistake ends up in real reports all the time.
- **Input C** should be downgraded to Informational. If your skill wrote it up as a real finding, your constraints aren't strong enough.

### Fix and Re-Test

Look at your lowest-scoring criterion. Edit your Modelfile to address it, rebuild, and test again:

> [!vm] Lab VM
> ```shell
> nano ~/Modelfile.findingwriter
> ollama create findingwriter -f ~/Modelfile.findingwriter
> ollama run findingwriter
> ```

Run the same three inputs. Did the score improve? Did fixing one thing break another?

This is the core loop of prompt engineering: **change → test → score → repeat**.

---

## Part 3: The Skill Is the Deliverable

You now have a Modelfile that:
- Encodes your professional judgment about how findings should be written
- Handles clear, ambiguous, and noise findings differently
- Produces consistent, structured output
- Can be shared with teammates or loaded on any Ollama instance

This is what a **skill** is in practice: a reusable, structured package of knowledge that makes an AI good at one specific task. You didn't retrain the model. You wrote a system prompt that carries your expertise.

> [!tip] Stretch Goal
> If you finish early, try feeding your skill a deliberately weird input — a Burp Suite web application finding instead of a Nessus plugin, or a hand-written vulnerability note with no structured fields. Does the skill degrade gracefully (mapping what it can, flagging what it can't)? Or does it hallucinate a well-formed but false finding? That tells you how strong your constraints are.

> [!checkpoint] Checkpoint
> You have finished this lab when all of the boxes below are ticked.
>
> - [ ] You planned the skill instructions in one session, then built the Modelfile in a fresh session
> - [ ] `ollama create findingwriter` builds without error
> - [ ] You ran the skill against all three test inputs without modifying the skill between runs
> - [ ] You scored each output using the rubric and identified the weakest criterion
> - [ ] You iterated on the Modelfile at least once and re-tested

---

> [!nav]
> [[02 Building Strong Prompts]]
>
> [[04 Prompt Injection Challenge]]
