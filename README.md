# Prompt Engineering for Cyber Security

**A hands-on workshop for getting professional-grade output from AI on real security tasks.**

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

Presented at the **Antisyphon AI Summit, August 2026**.

---

## About This Workshop

Anyone can type a question into a chatbot. Getting an AI to reliably produce work you'd actually put your name on (a defensible finding, a tuned detection, a configuration review that identifies the real escalation path) is a different but learnable skill. This four-hour, hands-on workshop teaches the two layers of prompting that most people blur into one: building a strong prompt before you hit enter, then running the refine-and-verify loop after the first draft comes back.

This workshop is the second in a two-part series. The first, [Keeping Things Local: Build Private LLMs for Your Team](https://github.com/DeltaCorvi/AT-Workshop-Keeping-Things-Local-2026), covers setting up local LLMs with Ollama, mesh networking, and authentication. You'll build on that foundation here. Didn't take the first workshop? No problem: a ready-to-go cloud hosted VM is provided.

## What You'll Build

A prompt engineering workflow you can apply to any security task: from a first-draft prompt that produces mediocre output, through structured iteration, to a polished result that's client-ready, then packaged into a reusable Modelfile you can run again on the next engagement. Along the way, you'll break AI defenses in a hands-on prompt injection challenge to understand why prompt-based guardrails aren't a security boundary.

## What You'll Learn

By the end of the workshop, you will be able to:

- Build strong prompts with the right role, context, constraints, and output shape
- Run a disciplined refine-and-verify loop on real security tasks: findings, config analysis, detections, and proof-of-concept tooling
- Detect and eliminate AI "tells" from client-facing writing
- Separate planning from execution across multiple sessions
- Package repeatable prompt workflows into reusable Skills (Modelfiles)
- Build lightweight evaluation sets to compare prompt revisions and measure improvement
- Craft and recognize injection, jailbreaking, and data-extraction prompts, and understand why they work

## Who This Is For

Security practitioners who want to get real, defensible work out of an AI, and who'd rather keep sensitive prompts on hardware they control. It's a strong fit for:

- **Red teamers and penetration testers** who want to speed up findings, tooling, and PoC validation without shipping client data to a third party
- **Blue teamers and detection engineers** who want to draft and tune Splunk and EDR detections faster
- **Consultants and MSSP staff** who write a high volume of client-facing deliverables and can't afford AI fingerprints in a report
- **Anyone** who has used an AI chatbot, been underwhelmed by the results, and suspects better prompting would get better results

**Skill level:** Beginner to intermediate. No prior prompt-engineering experience required.

## Prerequisites

- Completion of [Keeping Things Local](https://github.com/DeltaCorvi/AT-Workshop-Keeping-Things-Local-2026) or equivalent comfort with Ollama on the command line
- A laptop that can run the provided lab VM (see System Requirements below)
- No prior prompt-engineering experience required

## System Requirements

The lab VM and everything you need are provided. If you are running the VM locally, VMware Workstation Pro and Fusion Pro are free for personal, educational, and commercial use with no license key required.

- 16 GB RAM (24 GB or more recommended)
- A modern multi-core CPU (no GPU required)
- Approximately 40 GB free disk space
- CPU with virtualization support enabled in BIOS/UEFI
- VMware Workstation, VMware Player, VMware Fusion, or VirtualBox
- Internet connection to download and import the VM before class

## Lab VM and Large Files

The lab VM and pre-loaded models are **distributed separately** from this repository because of their size. Access instructions and credentials are provided before class.

> **If you are running the VM locally, download and import everything ahead of time.** The model files are large and take time to download and extract.

## Quick Start

After the VM is running and Ollama is available:

```bash
./install.sh
```

The install script checks prerequisites, pulls `llama3.2` if needed, builds the six injection challenge models, and sets up a Python virtual environment for the web app.

## Viewing the Lab Manual

The lab manual is written as an [Obsidian](https://obsidian.md/) vault, and this repository is that vault. The lab VM has Obsidian installed with the manual loaded and ready to use. To view a separate copy as intended, open the repository folder as a vault in Obsidian instead of reading the files on GitHub or in another Markdown editor. In Obsidian, the manual renders with callouts, labels showing which VM each command runs on, checkpoints, and Previous/Next navigation.

If you don't have Obsidian, the markdown stays perfectly readable on GitHub or in any plain Markdown viewer. The formatting and callouts just won't render as prettily.

## Workshop Modules

The lab manual is organized into sequential modules. Each builds on the last.

| # | Module | What it covers |
|---|--------|---|
| 00 | [About This Workshop](Lab%20Manual/00%20About%20This%20Workshop.md) | Orientation, tools, and how the labs fit together |
| 01 | [Getting Started](Lab%20Manual/01%20Getting%20Started.md) | Verify your environment, meet the CVE, and build the injection models |
| 02 | [Building Strong Prompts](Lab%20Manual/02%20Building%20Strong%20Prompts.md) | Iterate from a lazy prompt to a professional pentest finding, then generate PoC exploit code or Splunk detections |
| 03 | [From Prompt to Reusable Skill](Lab%20Manual/03%20From%20Prompt%20to%20Reusable%20Skill.md) | Package a refined prompt into a Modelfile, test it across varied inputs with a structured evaluation rubric |
| 04 | [Prompt Injection Challenge](Lab%20Manual/04%20Prompt%20Injection%20Challenge.md) | Extract secrets from AI models with escalating defenses across 4 in-class levels and 2 take-home challenges with walkthroughs |
| 05 | [Wrap Up and References](Lab%20Manual/05%20Wrap%20Up%20and%20References.md) | Key takeaways, further reading, and where to go from here |

All labs center on **CVE-2026-24061** (GNU inetutils telnetd authentication bypass, CVSS 9.8), a real, recently disclosed vulnerability with clear offensive and defensive angles.

## Repository Layout

```
.
├── README.md                       This file
├── LICENSE                         CC BY 4.0
├── install.sh                      Lab installer script
├── Lab Manual/                     The workshop modules (00-05) and walkthroughs
│   └── assets/                     Diagrams and screenshots used in the manual
├── lab files/                      Lab materials
│   ├── modelfiles/                 Prompt injection Modelfiles (levels 1-6)
│   ├── injection-app/              Flask web app for the injection challenge
│   └── artifacts/                  CVE scan output and engagement notes
├── prompt-eng-cyber-evals/         24 evaluation test cases for prompt quality
├── assets/                         Workshop images and diagrams
└── reference/                      Slide decks, talk notes, and working files
```

## Tools Used

- **[Ollama](https://ollama.com/)**: local LLM runtime
- **`llama3.2`**: the pre-loaded model used throughout the workshop
- **Modelfiles**: Ollama recipes for custom models (skills and injection challenges)
- **[Flask](https://flask.palletsprojects.com/)**: lightweight web framework for the prompt injection challenge app
- **[Obsidian](https://obsidian.md/)**: the intended reader for the workshop manual and its interactive checkpoints
- **VMware Workstation / Fusion**: the current local virtualization path for the lab VM

## Special Thanks

**Bronwen Aker**, for building the [Keeping Things Local](https://github.com/DeltaCorvi/AT-Workshop-Keeping-Things-Local-2026) prerequisite workshop and making this two-part series possible.

**Antisyphon Training**, for making classes like this possible.

**The BHIS Community**, for making this kind of project worth doing.

## License

This work is licensed under the [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/). You are free to share and adapt this material for any purpose, including commercially, provided you give appropriate credit, link to the license, and indicate if changes were made. See [LICENSE](LICENSE) for the full text.

## Author

**Ashley**, Black Hills Information Security
