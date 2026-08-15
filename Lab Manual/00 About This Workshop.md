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

This workshop teaches you the two layers of prompting that some folks blur into one: building a strong prompt *before* you hit enter (role, context, constraints, output shape), then running the refine-and-verify loop *after* the first draft comes back. You'll practice on the jobs you actually do, learn to package prompt workflows into reusable skills, try your hand at breaking AI guardrails which also transfers directly into prompting skills, and finish with a practical understanding of what makes AI output scream "a robot wrote this."

# What to Expect

This is a four-hour, hands-on workshop. There are four labs to build on what we'll discuss regarding prompt engineering. The labs will build on each other but each one stands alone if you need to catch up. There are two take home labs in case you speed through the labs and want to work on harder material or if you actually want to take home additional prompt injection labs to work on later.

You'll work on a local LLM running on your VM. The model is small and runs on CPU, so expect steady responses measured in seconds, not milliseconds. Every lab is sized to run comfortably at that pace. I highly recommend experimenting with different LLM's after you've completed this workshop with something like AWS Bedrock if you don't have the hardware at home.

## Building on *Keeping Things Local*

If you took the *Keeping Things Local: Build It, Mesh It, Lock It* workshop, you already know how to set up Ollama, customize models with Modelfiles, and build a service layer around a local LLM. This workshop picks up where that one left off. Instead of building the infrastructure, you'll learn to get professional-grade output from the model you built.

And if you didn't take the first workshop? No problem. The VM ships ready to go with everything you need and if you're using you're own VM, there's an installer script in this repo to get everything ready to go for the workshop.

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

This manual was written as an [Obsidian](https://obsidian.md/) vault but is perfectly readable in GitHub or in your favorite markdown editor.

### How to Read the Command Boxes

Commands you need to run are wrapped in colored boxes:

> [!vm] Lab VM
> ```shell
> ollama list
> ```

The label tells you the command runs on your lab VM. If you are ever unsure which shell you are in, check the prompt.

## Labs

### [[01 Getting Started]]
Verify your VM, confirm Ollama is running, install the necessary tools to run the labs, and get oriented with the scenario and artifacts you'll use throughout the labs.

### [[02 Building Strong Prompts]]
Start with a bad prompt, see the bad output, then layer in role, context, constraints, and output shape to produce a professional finding. Then choose your path: generate proof-of-concept exploit code (red team) or Splunk detection alerts (blue team) for the same vulnerability.

### [[03 From Prompt to Reusable Skill]]
Take the prompt you refined in Lab 02, separate planning from execution, package it into a reusable Modelfile, and test it against multiple inputs using a structured evaluation rubric.

### [[04 Prompt Injection Challenge]]
Try to extract secret passwords/flags from AI with increasingly hardened defenses. Apply the prompt injection, jailbreaking, and engineering techniques learned against real guardrails and see which ones reveal the flags.

### [[04a Take-Home Level 5 - The Roleplay Trap]]
A take-home challenge with a full walkthrough. The model has been hardened against every common bypass technique. Can you find a way through?

### [[04b Take-Home Level 6 - Defense in Depth]]
The final boss. The model has a decoy password designed to make you think you won, however, the real flag is behind layered defenses. There is a full walkthrough included.

### [[05 Wrap Up and References]]
What you learned, where to take it next, and annotated links to everything referenced in the workshop.

---

> [!navnext]
> [[01 Getting Started]]
