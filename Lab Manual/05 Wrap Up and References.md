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

# Wrap Up

## What You Built Today

Over four hours, you developed a practical prompt engineering toolkit for security work:

**A structured prompting method.** Role, context, constraints, output shape — not as a formula to memorize, but as a checklist you internalized through practice. The gap between your first finding in Lab 02 and your last one was the prompt, not the model.

**An evaluation discipline.** The 0/1/2 rubric scoring method gives you a way to measure whether a prompt change actually improved the output, rather than just feeling different. When you revisit a prompt next month, you can compare scores instead of guessing.

**A reusable skill.** The Modelfile you built in Lab 03 encodes your professional judgment in a format that survives session boundaries, works on any Ollama instance, and can be shared with teammates. Every engagement-specific workflow you standardize this way is time you don't spend re-prompting.

**An adversarial intuition.** The injection challenge isn't just about breaking AI guardrails — it's about understanding that system prompts are instructions, not security boundaries. Every AI application you build or assess from here on should be informed by what you learned in Lab 04: if the model can see it, assume an attacker can extract it.

## Where to Go Next

**Practice the eval cases.** The `prompt-eng-cyber-evals` directory on the VM contains 24 evaluation cases spanning finding writing, config review, detection engineering, log analysis, threat analysis, exploit precondition analysis, and documentation. Each case has a rubric. Pick cases that match your day-to-day work and use them to sharpen your prompts.

**Build more skills.** Every time you spend more than 10 minutes iterating on a prompt for a recurring task, stop and ask: should this be a Modelfile? Report section templates, methodology checklists, config review rubrics, triage playbooks — if you've done the work to get good output once, package it.

**Try Gandalf.** [gandalf.lakera.ai](https://gandalf.lakera.ai/baseline) is a web-based prompt injection challenge with more levels and different defense strategies than what we covered today. Good practice for the adversarial side.

**Take the HuggingFace Context Engineering Course.** The [Context Engineering Course](https://huggingface.co/learn/context-course/en/unit0/introduction) covers skills, context management, and agent design in more depth than a single workshop can.

**Run your own model.** If you took *Keeping Things Local* and have a decent GPU, run a larger model at home. The prompting techniques transfer directly — they just land harder on a more capable model.

---

## References

### From the Talk

- [Prompt Injection and AI Security Research — Palo Alto Unit 42](https://unit42.paloaltonetworks.com/new-frontier-of-genai-threats-a-comprehensive-guide-to-prompt-attacks/)
- [LLM Guardrails vs Roleplaying Prompts — alice.io](https://alice.io/blog/llm-guardrails-are-being-outsmarted-by-roleplaying-and-conversational-prompts)
- [Adversarial Prompt Engineering — Obsidian Security](https://www.obsidiansecurity.com/blog/adversarial-prompt-engineering)
- [Jailbreak-Proof AI Security: Zero Trust — Xage](https://xage.com/blog/jailbreak-proof-ai-security-why-zero-trust-beats-guardrails/)
- [What Are Abliterated Models — WebDecoy](https://webdecoy.com/blog/wtf-are-abliterated-models-uncensored-llms-explained/)
- [AI Agent Glossary — HuggingFace](https://huggingface.co/blog/agent-glossary)
- [How to Save Tokens — MyDataSchool](https://mydataschool.com/blog/how-to-save-tokens/)

### Academic Papers

- [LLM Writing Detection — Science Advances](https://www.science.org/doi/10.1126/sciadv.adt3813)
- [Prompt Injection Taxonomy — ACL Anthology](https://aclanthology.org/2025.coling-main.426.pdf)
- [AI-Generated Text Analysis — PNAS](https://www.pnas.org/doi/10.1073/pnas.2422455122)
- [Adversarial Attacks on LLMs — arXiv](https://arxiv.org/html/2512.01353v2)

### CVE-2026-24061

- [CVE-2026-24061 NVD Entry](https://nvd.nist.gov/vuln/detail/cve-2026-24061)
- [Root Cause Analysis and PoC — SafeBreach Labs](https://www.safebreach.com/blog/safebreach-labs-root-cause-analysis-and-poc-exploit-for-cve-2026-24061/)
- [Detection Guidance — SOC Prime](https://socprime.com/blog/cve-2026-24061-vulnerability/)
- [Active Exploitation Report — TXOne Networks](https://www.txone.com/blog/cve-2026-24061-gnu-inetutils-telnet-exploitation/)

### Tools

- [Ollama](https://ollama.com/) — Local LLM runtime
- [Gandalf by Lakera](https://gandalf.lakera.ai/baseline) — Prompt injection challenge
- [Uncensored Models on HuggingFace](https://huggingface.co/models?search=uncensored)
- [HuggingFace Context Engineering Course](https://huggingface.co/learn/context-course/en/unit0/introduction)

---

> [!nav]
> [[04b Take-Home Level 6 - Defense in Depth]]
>
> [[00 About This Workshop]]
