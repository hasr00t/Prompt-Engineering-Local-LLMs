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

# Lab: Building Strong Prompts

This lab has two exercises. In the first, you'll write a professional pentest finding, starting with a terrible prompt and iterating until the output is something you'd actually deliver to a client. In the second, you'll choose your own path: generate proof-of-concept exploit code (red team) or Splunk detection alerts (blue team) for the same vulnerability.

Both exercises use CVE-2026-24061 and the artifacts you reviewed in [[01 Getting Started]].

---

## Exercise A: From Lazy Prompt to Client-Ready Finding

### Step 1: The Naive Prompt

Start with the worst prompt you can think of. Open an interactive session and type something like this:

> [!vm] Lab VM
> ```shell
> ollama run llama3.2
> >>> Write a finding about CVE-2026-24061
> ```

Read the output carefully. Don't fix it yet. Study it. You're looking for two categories of problems:

**Structural problems:**
- Is the finding organized the way your firm's deliverables are?
- Does it have the sections a client needs (title, severity, description, impact, evidence, remediation)?
- Is severity justified or just stated?

**AI tells, the words that scream "a robot wrote this":**
Look for these specific patterns from the talk:
- Em dashes everywhere (—)
- "Crucial," "robust," "comprehensive," "critical importance"
- "Delve into," "it is important to note," "this vulnerability underscores"
- Hedging language: "It should be noted that," "It is worth mentioning"
- Puffed-up significance: "represents a significant threat to the security landscape"
- Generic advice that adds no value: "organizations should prioritize security"

> [!tip] Keep Count
> Count the AI tells in the output. Write the number down. You'll compare it to your refined output later.

### Step 2: Add Role

Exit the session (`/bye`) and start a new one. This time, give the model a role:

> [!vm] Lab VM
> ```shell
> ollama run llama3.2
> >>> You are a senior penetration tester writing findings for a client deliverable. Write a finding about CVE-2026-24061.
> ```

Compare this output to your first attempt. What changed? The model now has a perspective. It knows who it is and who it's writing for. But it still doesn't know anything about *your* engagement.

### Step 3: Add Context

Now feed it the actual engagement data. Copy the content from your artifact files and include it in the prompt. Start a new session:

> [!vm] Lab VM
> ```shell
> ollama run llama3.2
> ```

This time, build a prompt with context. Here's a template. Paste in the actual content from your artifact files where indicated:

```
You are a senior penetration tester writing a finding for a client deliverable.

Here is the Nessus scan output:
[paste the contents of cve-2026-24061-nessus.txt here]

Here is the engagement context:
[paste the contents of engagement-notes.txt here]

Write a finding for this vulnerability.
```

> [!tip] Pasting Multi-Line Prompts
> In `ollama run`, you can paste multi-line text directly. If your terminal has trouble, use the `"""` multi-line input mode: type `"""`, press Enter, paste your content, then type `"""` and press Enter again to submit.

Compare again. The output should now reference the actual host, the client context, and the engagement scope. But it might still have structural problems.

### Step 4: Add Constraints and Output Shape

Now add the constraints that turn generic output into a professional deliverable. Start a fresh session and build the full prompt:

```
You are a senior penetration tester writing a finding for an internal 
network penetration test report delivered to a corporate client.

Write in a direct, professional, factual tone. Do not use marketing 
language, superlatives, or filler. Do not use the words "crucial," 
"robust," "comprehensive," "landscape," or "delve." Avoid em dashes. 
Do not editorialize about the importance of security in general.

Here is the Nessus scan output:
[paste Nessus output]

Here is the engagement context:
[paste engagement notes]

Write a finding using this exact format:

**Title:** [Descriptive title including the affected host]
**Severity:** [Critical/High/Medium/Low/Informational — justify the rating]
**Affected Host(s):** [IP and hostname]
**Description:** [What the vulnerability is, in 2-3 sentences]
**Impact:** [What an attacker can do, specific to this environment]
**Evidence:** [What the scanner found — quote the relevant output]
**Remediation:** [Specific, actionable steps — not generic advice]
**References:** [CVE number and relevant links]
```

### Step 5: Compare Before and After

Look at your Step 4 output next to your Step 1 output. Count the AI tells in the new version.

You should see:
- **Step 1:** Generic, sloppy, full of AI tells, no engagement context
- **Step 4:** Structured, specific, scoped to the engagement, reads like a human wrote it

The difference is the prompt, not the model. The same LLM produced both outputs.

> [!tip] The Refine-and-Verify Loop
> If the Step 4 output still has problems, like a weak severity justification or generic remediation, don't start over. Tell the model what's wrong:
> ```
> The remediation section is too generic. Rewrite it with specific 
> steps for this environment: the host runs a legacy inventory 
> management app that requires the telnet interface, and the client 
> said the SSH migration stalled. Address that constraint.
> ```
> This is the refine-and-verify loop: iterate on the output, don't re-prompt from scratch.

---

## Exercise B: Choose Your Path

Pick **one** of the two exercises below based on your role. Red teamers and pentesters: go with the exploit code. Blue teamers and detection engineers: go with the Splunk alerts. If you finish early, try the other one.

### Red Path: Proof-of-Concept Exploit Code

Your goal: prompt the LLM to generate a Python proof-of-concept that exploits CVE-2026-24061.

**What the exploit does:** Connects to a target host on port 23, sends a crafted `NEW_ENVIRON` telnet option with `USER` set to `-f root`, and establishes an unauthenticated root session.

Start with a prompt and iterate. Here are things to think about:

- **Specify the language and libraries:** "Write a Python 3 script using the `socket` library..."
- **Describe the exploit mechanism:** The model needs to know that the attack uses the `NEW_ENVIRON` telnet option to inject `-f root` as the USER variable
- **Constrain the output format:** Ask for commented code, usage instructions, a specific function structure
- **Request safety features:** A banner that prints the CVE number, a disclaimer, a confirmation prompt before exploitation

> [!vm] Lab VM
> ```shell
> ollama run llama3.2
> ```

**Example starting prompt** (iterate from here):

```
You are an exploit developer writing a proof-of-concept for 
authorized penetration testing. Write a Python 3 script that 
exploits CVE-2026-24061 (GNU inetutils telnetd authentication bypass).

The exploit works by sending a NEW_ENVIRON telnet option with the 
USER variable set to "-f root", which causes the telnet daemon to 
pass this to the login process, bypassing authentication.

Requirements:
- Use the socket library (no third-party dependencies)
- Accept a target IP as a command-line argument
- Print a banner with CVE number and disclaimer
- Include inline comments explaining each step of the telnet 
  protocol negotiation
- Handle connection errors gracefully
- Print the server's response after authentication bypass
```

**Iterate on:**
- Does the telnet protocol negotiation look correct? Ask the model to walk you through it.
- Are the telnet option codes right? (IAC=0xff, WILL=0xfb, SB=0xfa, SE=0xf0, NEW_ENVIRON=0x27)
- Does the script handle the case where the host isn't vulnerable?

> [!note]
> A small local model may not produce a perfectly working exploit on the first try. That's fine. The lab is about prompt iteration, not about having a working 0-day at the end. Focus on how much better the output gets as you refine the prompt.

---

### Blue Path: Splunk Detection Alerts

Your goal: prompt the LLM to generate Splunk SPL queries that detect exploitation of CVE-2026-24061.

**What to detect:** 
1. Telnet connections to port 23 with suspicious `NEW_ENVIRON` options containing `-f` 
2. Authentication log anomalies: root login events via telnetd with no password authentication
3. Correlation: telnet session followed by privileged commands within a time window

Start with a prompt and iterate:

> [!vm] Lab VM
> ```shell
> ollama run llama3.2
> ```

**Example starting prompt** (iterate from here):

```
You are a detection engineer writing Splunk SPL alerts to detect 
exploitation of CVE-2026-24061 (GNU inetutils telnetd authentication 
bypass) in an enterprise environment.

The attack pattern:
1. An attacker connects to port 23 (telnet)
2. During session negotiation, the attacker sends a NEW_ENVIRON 
   option with USER set to "-f root"
3. The telnet daemon passes this to login, granting root access 
   without credentials
4. The attacker now has a root shell

Write three Splunk SPL detection queries:

1. NETWORK DETECTION: Alert on telnet connections to port 23 from 
   non-approved source IPs (assume an index called "network" with 
   fields: src_ip, dest_ip, dest_port, protocol)

2. AUTH LOG DETECTION: Alert on root login events via telnetd where 
   no password authentication occurred (assume an index called 
   "linux_auth" with syslog-format auth.log data)

3. CORRELATION: Combine network and auth log data to alert when a 
   telnet session from an external IP is followed by a root login 
   within 60 seconds on the same host

For each query, include:
- The full SPL query
- A one-line description of what it detects
- The recommended alert threshold and schedule
- Known false positive scenarios and how to tune them out
```

**Iterate on:**
- Are the field names realistic for your SIEM environment?
- Do the time windows make sense?
- Are the false positive scenarios actionable or generic?
- Would you actually deploy these alerts, or do they need tuning?

---

> [!checkpoint] Checkpoint
> You have finished this lab when all of the boxes below are ticked.
>
> - [ ] You wrote a naive prompt and identified AI tells in the output
> - [ ] You iterated through role, context, and constraints to produce a professional finding
> - [ ] The final finding is structured, specific to the engagement, and reads like a human wrote it
> - [ ] You completed at least one Exercise B path (red or blue) and iterated on the output at least once

> [!tip] Practice Cases
> Want more reps? The `prompt-eng-cyber-evals/cases/` directory has evaluation cases with rubrics you can use to keep practicing. Try these, sorted by difficulty:
>
> - **Case 01** (Easy): Write a finding for SMB signing not required on an internal host
> - **Case 02** (Medium): Handle a version banner finding with a possible vendor backport
> - **Case 03** (Hard): A "decommissioned" host that's still responding on the network
> - **Case 21** (Medium): Use few-shot prompting to match a firm's house finding style
>
> Each case has a scoring rubric. Run your prompt, score the output, revise, and re-score.

---

> [!nav]
> [[01 Getting Started]]
>
> [[03 From Prompt to Reusable Skill]]
