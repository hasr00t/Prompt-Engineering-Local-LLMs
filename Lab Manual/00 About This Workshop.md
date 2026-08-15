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

# Welcome

Thank you for signing up for *Prompt Engineering for Cyber Security* at the Antisyphon AI Summit, 2026.

Anyone can type a question into a chatbot. Getting an AI to reliably produce work you'd actually put your name on, like a defensible finding, a tuned detection, or a configuration review that identifies the real escalation path, is a different but learnable skill. I find that a lot of Googling skills are transferrable to AI prompting skills.

This workshop teaches you the two layers of prompting that most people blur into one: building a strong prompt *before* you hit enter (role, context, constraints, output shape), then running the refine-and-verify loop *after* the first draft comes back. You'll practice on the jobs you actually do, learn to package prompt workflows into reusable skills, try your hand at breaking AI guardrails, and finish with a practical understanding of what makes AI output scream "a robot wrote this."

# What to Expect

This is a four-hour, hands-on workshop. There are four labs to build on what we'll discuss regarding prompt engineering. The labs will build on each other but each one stands alone if you need to catch up.

You'll work on a local LLM running on your VM — your prompts stay on your machine, not shipped to a cloud provider. The model is small and runs on CPU, so expect steady responses measured in seconds, not milliseconds. Every lab is sized to run comfortably at that pace.

## Building on *Keeping Things Local*

If you took the *Keeping Things Local: Build It, Mesh It, Lock It* workshop, you already know how to set up Ollama, customize models with Modelfiles, and build a service layer around a local LLM. This workshop picks up where that one left off. Instead of building the infrastructure, you'll learn to get professional-grade output from the model you built.

Didn't take the first workshop? No problem. The VM ships ready to go with everything you need.

## Tools We Will Use

* **Lab environment**
	* A Linux virtual machine with Ollama and a small open-weight LLM pre-installed
	* VMware Workstation or Fusion for running the VM on your own computer
* **Local model**
	* Ollama: the local model runtime and API
	* `llama3.2`: the pre-loaded model used throughout the workshop
	* Modelfiles: Ollama recipes that combine a base model with parameters and a system prompt
* **Lab applications**
	* A browser-based prompt injection challenge application (pre-installed on the VM)
* **Workshop manual**
	* Obsidian: the Markdown application used to read this manual and its lab-specific formatting

## Reading This Manual

This manual was written as an [Obsidian](https://obsidian.md/) vault. Everything is written using markdown, and if you use a reader other than Obsidian, it probably won't render the way it was intended but will still be functional.

### How to Read the Command Boxes

Commands you need to run are wrapped in colored boxes:

> [!vm] Lab VM
> ```shell
> ollama list
> ```

The label tells you the command runs on your lab VM. If you are ever unsure which shell you are in, check the prompt.

## Labs

### [[01 Getting Started]]
Verify your VM, confirm Ollama is running, and get oriented with the scenario and artifacts you'll use throughout the labs.

### [[02 Building Strong Prompts]]
Start with a bad prompt, see the bad output, then layer in role, context, constraints, and output shape to produce a professional finding. Then choose your path: generate proof-of-concept exploit code (red team) or Splunk detection alerts (blue team) for the same vulnerability.

### [[03 From Prompt to Reusable Skill]]
Take the prompt you refined in Lab 02, separate planning from execution, package it into a reusable Modelfile, and test it against multiple inputs using a structured evaluation rubric.

### [[04 Prompt Injection Challenge]]
Try to extract secret passwords from AI models with increasingly hardened defenses. Apply the prompt injection, jailbreaking, and social engineering techniques from the talk against real guardrails and see which ones hold.

### [[04a Take-Home Level 5 - The Roleplay Trap]]
A take-home challenge with a full walkthrough. The model has been hardened against every common bypass technique. Can you find a way through?

### [[04b Take-Home Level 6 - Defense in Depth]]
The final boss. The model has a decoy password designed to make you think you won. The real flag is behind layered defenses. Full walkthrough included.

### [[05 Wrap Up and References]]
What you learned, where to take it next, and annotated links to everything referenced in the workshop.

---

> [!navnext]
> [[01 Getting Started]]
