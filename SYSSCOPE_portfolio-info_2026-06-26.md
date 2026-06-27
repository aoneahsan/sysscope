# SysScope — Portfolio Info

Reference Date: 2026-06-26
Project Type: CLI / system-audit utility — a modular, read-only Bash tool that audits a Mac/Linux machine and reports which local AI models (Ollama) and dev workloads it can actually run; distributed via npm (`npx sysscope`) and a `curl | bash` single-file bundle
Project Slug: sysscope
Primary Email Reference: aoneahsan@gmail.com
Current Version Reviewed: `1.0.0` (`package.json` + `SYSSCOPE_VERSION` in `audit.sh`)
Last Portfolio Update: 2026-06-26
Next Eligible Update After: 2026-07-03

---

## Identity & Distribution (Authoritative)

| Field | Value |
| --- | --- |
| Project Slug | `sysscope` |
| Public Brand Name | SysScope |
| Public URL (Live) | not applicable (CLI tool; no hosted web surface) |
| Repository | https://github.com/aoneahsan/sysscope |
| Main Project Link | https://npmjs.com/package/sysscope |
| NPM Package | `sysscope` — https://npmjs.com/package/sysscope (run via `npx sysscope`) |
| Gist Mirror | https://gist.github.com/aoneahsan/d55e9709334ef5723468ad44fa667c6d (referenced in README) |
| Docs | https://github.com/aoneahsan/sysscope#readme |
| Android / iOS / Chrome / PyPI | N/A (no mobile, desktop, browser-extension, or PyPI surface) |
| License | MIT (declared in `package.json`; `LICENSE` file present in repo) |
| Author | Ahsan Mahmood — aoneahsan@gmail.com — https://aoneahsan.com |
| Payment / Support URL | https://aoneahsan.com/payment?project-id=sysscope&project-identifier=sysscope |
| Agent-Readable Pricing | N/A (free, open-source; no paid tiers) |

> **Asks for next refresh:** none outstanding — links, npm package name, license, and repo are all recorded in the master JSON. Confirm the published npm version on the next refresh if it advances beyond `1.0.0`.

---

## Brand Assets

### Logo (SVG — inline)

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96" role="img" aria-label="SysScope">
  <defs>
    <linearGradient id="sysscope-grad" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#22D3EE"/>
      <stop offset="100%" stop-color="#0891B2"/>
    </linearGradient>
  </defs>
  <rect x="2" y="2" width="92" height="92" rx="22" fill="#0F172A"/>
  <!-- scope / lens ring: the "audit & inspect" cue -->
  <circle cx="42" cy="42" r="22" stroke="url(#sysscope-grad)" stroke-width="6" fill="none"/>
  <!-- inner reticle crosshair -->
  <path d="M42 30 L42 54 M30 42 L54 42" stroke="#22D3EE" stroke-width="3" stroke-linecap="round" opacity="0.85"/>
  <!-- scope handle -->
  <path d="M59 59 L74 74" stroke="url(#sysscope-grad)" stroke-width="7" stroke-linecap="round"/>
  <!-- health pip: green "all clear" dot -->
  <circle cx="42" cy="42" r="4" fill="#22C55E"/>
</svg>
```

### Color Palette

| Role | Token | Hex | Usage |
| --- | --- | --- | --- |
| Primary | Cyan 600 | `#0891B2` | Brand mark, scope/lens, links |
| Primary — bright | Cyan 400 | `#22D3EE` | Terminal cyan accents, highlights |
| Secondary | Slate 900 | `#0F172A` | Terminal/dark backdrop, surfaces |
| Status — good | Green 500 | `#22C55E` | 🟢 health "good", `[OK]` lines |
| Status — warn | Amber 500 | `#EAB308` | 🟡 "tight" / caution rows |
| Status — critical | Red 500 | `#EF4444` | 🟥 "critical" / "too big" rows |

> SysScope is a terminal-first CLI with no web theme; the palette is derived from its own ANSI output (`lib_core.sh` defines BOLD/DIM plus RED/GRN/YLW/BLU/MAG/CYN) and the 🔭 telescope brand mark. Cyan is the dominant accent; green/amber/red map directly to the 🟢🟡🟥 health scorecard the tool prints.

---

## Update History (max 10 records)

| Date | Type | Notes |
| --- | --- | --- |
| 2026-06-26 | Created | First portfolio file generated from the verified codebase at v1.0.0 (npm-published, `npx sysscope`). Identity table reconciled from the master JSON (repo, npm, docs, MIT license, contact). |

---

## One-Line Summary

SysScope is a modular, read-only Bash CLI — run instantly with `npx sysscope` — that audits any Mac (and most Linux boxes), grades 15 popular Ollama models against your real memory budget with a "fits / tight / too big" verdict, and prints a health scorecard plus a shareable Markdown report, all with zero installs and no network calls.

## Elevator Pitch

SysScope answers a question every developer asks before installing local-AI tooling: *"what will actually run well on this machine, and what should I pick?"* It detects your real hardware (Apple Silicon core layout, GPU cores, Metal version, NVIDIA VRAM, RAM, disk pressure, battery health, thermal throttling), computes a realistic inference memory budget, and grades a built-in catalog of 15 Ollama models against it. It then prints a colorized terminal report and writes a shareable Markdown report (with optional JSON), and a `--share` privacy mode redacts serials, UUIDs, and hostname so the output is safe to post publicly. It is pure Bash, compatible with the bash 3.2 that ships on macOS, dependency-free, and never modifies, uploads, or phones home from the host it audits.

## What This Project Is About

SysScope is a system-capability and AI-readiness auditor for developers who run (or want to run) local LLMs, containers, VMs, and emulators. The repository is a deliberately small, modular shell project: a single entry point (`audit.sh`) sources two libraries (`lib_core.sh` for output/detection/prompts, `lib_report.sh` for the Markdown/JSON document lifecycle) and one module per subsystem (`mod_system`, `mod_cpu`, `mod_memory`, `mod_gpu`, `mod_storage`, `mod_power`, `mod_software`, `mod_ai`, `mod_recommend`). `build.sh` concatenates everything into a self-contained `audit-bundle.sh` for `curl | bash` distribution, and a thin Node launcher (`bin/sysscope.js`) makes `npx sysscope` work by running the bundled script and passing args/exit codes straight through. The tool ships three presets — full (default), quick, and ai-only — plus output flags (`--output`, `--no-report`, `--json`, `--deep`), a `--share` privacy mode, and unattended/`--yes` operation.

## Vision

A tiny, trustworthy, read-only tool that gives any developer an instant, honest verdict on what their machine can run — especially local AI — without installs, accounts, or telemetry.

## Mission

Replace guesswork and marketing-spec confusion with a plain-language, machine-specific report: detect the real hardware, compute the memory budget that actually governs inference, grade concrete models against it, and hand back a shareable, privacy-safe summary — all from one dependency-free Bash script that never changes the system it inspects.

## Tech Stack

| Layer | Technology |
| --- | --- |
| Language | Pure Bash (POSIX-friendly; compatible with macOS's bash 3.2 — no associative arrays, no `${var,,}`) |
| Dependencies | None — standard Unix tools only (`awk`, `sed`, `df`, etc.) |
| Architecture | Modular: `audit.sh` entry point sources `lib_*.sh` + `mod_*.sh`; one job per file |
| Distribution (npm) | `bin/sysscope.js` Node launcher → `npx sysscope` (engines: Node `>=14`) |
| Distribution (single file) | `build.sh` bundles all modules into `audit-bundle.sh` for `curl | bash` |
| Hardware probes | macOS `system_profiler`/`sysctl` paths, `nvidia-smi` for VRAM, battery/thermal probes |
| Output | Colorized terminal (ANSI), GitHub-Flavored-Markdown report, optional JSON metrics |
| AI engine | Built-in 15-model Ollama catalog with Q4 size estimates and a budget-fit grader (`mod_ai.sh`) |
| Privacy | `--share` redaction of serials / UUIDs / hostname; no network connections |
| Platforms | macOS Apple Silicon (primary), macOS Intel (full), Linux NVIDIA/generic (best-effort), Windows via WSL |
| License | MIT |

## Feature Catalog

- **AI capability engine** — computes a realistic inference memory budget (unified RAM on Apple Silicon = total − 4.5 GB; ~92% of VRAM on NVIDIA via `nvidia-smi`; total − 3 GB CPU-only with a "this will be slow" warning) and grades 15 popular Ollama models with a fits / tight / too-big verdict (`size × 1.3 ≤ budget` comfortably fits, where ×1.3 covers KV cache/context).
- **Real hardware detection** — Apple Silicon P/E core layout, GPU cores, Metal version, NVIDIA VRAM, RAM/swap/pressure, disk capacity and free space, battery health/charge, thermal throttling.
- **Health scorecard** — disk / memory / AI / battery each rated 🟢🟡🟥 with a one-line reason, plus concurrency/workload guidance so you don't blow your RAM budget.
- **Capability tiers + starter sets** — picks a tier (Minimal → Workstation) and prints a tailored starter model set with install commands.
- **Modular by design** — one subsystem per file (`lib_*`, `mod_*`); easy to read, extend (add a `mod_yours.sh`), or trim.
- **Single-file bundle** — `build.sh` concatenates everything into `audit-bundle.sh` for `curl | bash` distribution with no Node required.
- **Three run modes** — `--full` (default), `--quick` (skips software inventory & deep disk scan), `--ai-only` ("which models can I run?").
- **Multiple outputs** — pretty terminal report, shareable Markdown report, and machine-readable JSON (`--json`).
- **Privacy mode** — `--share` redacts serials, UUIDs, and hostname and stamps a privacy banner so the Markdown is safe to publish.
- **Interactive or unattended** — menu-driven by default; fully scriptable with `--yes` and other flags.
- **Software inventory** — detects installed languages, package managers, containers, VMs, and LLM tooling.
- **Portable & safe** — pure Bash 3.2-compatible, zero dependencies, read-only, and makes no network calls.

## Hidden Facts & Unique Angles

- **Read-only and offline by contract** — the tool makes no network connections and writes nothing outside the report/JSON paths you choose; the public `CLAUDE.md`/`AGENTS.md` even enforce "never modify, upload, or phone home" as a hard rule.
- **Built for the bash that's actually on macOS** — deliberately targets bash 3.2 (no associative arrays, no `${var,,}`), so it runs on a stock Mac with zero installs — a real constraint most modern shell tools ignore.
- **Two distribution paths from one source** — `build.sh` flattens the modular tree into a single `audit-bundle.sh`, and `bin/sysscope.js` lets the same script run via `npx sysscope` (or `npx github:aoneahsan/sysscope` for the unreleased `main`).
- **The Neural Engine myth, called out explicitly** — on Apple Silicon, Ollama/llama.cpp use the GPU via Metal, *not* the Neural Engine; SysScope says so to clear up a common misconception.
- **Honest about precision** — generation speed is memory-bandwidth-bound, so the tool gives qualitative tok/s ranges instead of false-precision numbers, and the README carries a disclaimer that sizes/budgets are estimates.
- **Privacy is a first-class feature, not an afterthought** — `--share` exists specifically so users can post their audit publicly without leaking serials/UUIDs/hostname.
- **The model catalog is just data** — the 15-model list with Q4 sizes lives in `mod_ai.sh`, so keeping it current is a one-line-per-model PR (explicitly invited in the README).

## Benefits for Users

- **Developers eyeing local AI** — a straight answer on which Ollama models fit their machine, model-by-model, before downloading gigabytes.
- **Hardware shoppers / upgraders** — a quick, plain-language read on whether a machine is comfortable for 7–9B daily use, tight at 14B, or needs more memory.
- **People who share their setup** — `--share` produces a publicly-safe Markdown report for issues, gists, and forums.
- **Privacy-conscious users** — zero network calls, read-only, no accounts, no telemetry.
- **Minimalists / sysadmins** — dependency-free Bash that runs on a stock Mac or Linux box with no installs and no root.
- **Tinkerers** — a tiny, modular codebase that's easy to extend with a new `mod_*.sh`.

## Value & Potential

SysScope turns a fuzzy, frequently-asked question ("can my machine run local AI, and which model?") into a concrete, shareable verdict — and does it as a clean, dependency-free, read-only Bash tool that distributes both via npm and `curl | bash`. As a portfolio piece it demonstrates disciplined shell engineering (bash 3.2 compatibility, modular architecture, a build step that bundles to a single file), thoughtful product judgment (privacy mode, honest estimate framing, the Metal-vs-Neural-Engine clarification), and pragmatic distribution (npx launcher + curl bundle + Gist mirror). Growth paths are obvious and low-risk: broader GPU/accelerator coverage, BSD support, an always-current model catalog, and more workload profiles beyond LLMs (containers, VMs, emulators).

## Resume / CV Bullets

- Built SysScope, a dependency-free, read-only system-audit CLI in pure Bash (bash 3.2-compatible) that detects real hardware and grades 15 Ollama models against a computed inference memory budget with a fits / tight / too-big verdict.
- Designed a modular shell architecture — one entry point sourcing per-subsystem modules (`mod_system`/`cpu`/`memory`/`gpu`/`storage`/`power`/`software`/`ai`/`recommend`) — plus a `build.sh` that flattens the tree into a single self-contained `audit-bundle.sh`.
- Shipped dual distribution: an npm package with a Node launcher (`npx sysscope`) and a `curl | bash` single-file bundle, with args and exit codes passed straight through.
- Implemented an AI-capability engine that adapts the memory budget per backend (unified RAM on Apple Silicon, ~92% VRAM on NVIDIA, CPU-only fallback) and outputs a 🟢🟡🟥 health scorecard with concurrency guidance.
- Made privacy a feature: a `--share` mode redacts serials, UUIDs, and hostname for publicly-safe reports, with the tool guaranteed read-only and network-free.
- Authored colorized terminal output plus mirrored GitHub-Flavored-Markdown and JSON report generation from the same code path.

## LinkedIn / Portfolio Paragraph

SysScope is a small, read-only command-line tool I built to answer a question every developer hits before installing local AI: "what will actually run well on this machine?" Run it instantly with `npx sysscope` and it detects your real hardware — Apple Silicon core layout, GPU cores and Metal version, NVIDIA VRAM, RAM, disk, battery, thermals — computes the memory budget that actually governs inference, and grades 15 popular Ollama models with a clear fits / tight / too-big verdict. It prints a colorized terminal report and writes a shareable Markdown report (plus optional JSON), with a `--share` mode that redacts serials and hostnames so the output is safe to post publicly. It's pure Bash compatible with the bash 3.2 on macOS, has zero dependencies, makes no network calls, and never modifies the system it audits — distributed both as an npm package and a `curl | bash` single-file bundle.

## Social Content Angles (for ChatGPT content project)

- "Can my Mac run local AI?" — building a CLI that gives a model-by-model fits/tight/too-big verdict.
- Why I targeted bash 3.2 on purpose (and what that costs you: no associative arrays, no `${var,,}`).
- The Apple Silicon myth: Ollama uses the GPU via Metal, not the Neural Engine — and why that matters for your memory budget.
- How the memory budget is computed differently for unified RAM vs NVIDIA VRAM vs CPU-only.
- Shipping one Bash tool two ways: `npx sysscope` and `curl | bash` from a single `build.sh` bundle.
- Privacy as a feature: a `--share` flag that redacts serials/UUIDs/hostname so audits are safe to post.
- Read-only by contract: a system tool that never modifies, uploads, or phones home.
- Modular shell design — one job per file — and how to extend it with a new `mod_*.sh`.
- Honest estimates over false precision: qualitative tok/s ranges because inference is memory-bandwidth-bound.
- A health scorecard in your terminal: 🟢🟡🟥 for disk, memory, AI, and battery with one-line reasons.

## Top 20 Hashtags

#SysScope #LocalAI #Ollama #CLI #BashScripting #AppleSilicon #MacOS #LLM #AIReadiness #DeveloperTools #SystemAudit #OpenSource #Shell #Hardware #GPU #NeuralEngine #npx #DevOps #BuildInPublic #ZeroDependencies

## SEO / AEO Metadata

- Meta description (150–160 chars): SysScope is a read-only Bash CLI — run via `npx sysscope` — that audits your Mac/Linux machine and grades 15 Ollama models by what your memory can actually run.
- Primary keywords: local AI readiness tool, which Ollama model can I run, system audit CLI, Apple Silicon LLM memory, GPU VRAM model fit, mac system capability checker, bash hardware audit, npx system audit, local LLM machine check, read-only system inspector.
- Long-tail / GEO keywords (AI-search): "which local AI model can my Mac run", "check if my machine can run Ollama models", "Apple Silicon unified memory budget for LLMs", "bash CLI to audit hardware for local AI", "npx tool to see what AI models fit my RAM".
- Suggested og:title: SysScope — System Capability & AI-Readiness Audit
- Suggested og:description: Run `npx sysscope` to see which local AI models your machine can actually run — a read-only Bash audit with a health scorecard and shareable report.

## Known Constraints (honest framing)

- **Single release reviewed** — version `1.0.0` in `package.json` and `audit.sh`; no later versions are evidenced in the repo.
- **Best-effort on Linux** — hardware/RAM/disk/AI-budget/software detection work, but battery and thermal probes are limited; Windows is supported only via WSL (Linux path).
- **Estimates, not guarantees** — model sizes, speeds, and memory budgets are approximate (they depend on quantization, context length, and other running apps); the README disclaims this explicitly.
- **Model catalog is point-in-time** — the 15-model Ollama list with Q4 sizes in `mod_ai.sh` is hand-maintained data and needs periodic PRs to stay current.
- **No automated test suite** — verification is via `bash -n` syntax checks and a `--quick --yes --no-report` smoke run, as documented in `CLAUDE.md`.
- **No web/mobile/extension surface** — this is a terminal CLI only; there is no hosted live URL.

## Generic Hashtags (always include in posts)

#Aoneahsan #AhsanMahmood #Zaions #BestOpenSourceCommunityProject #TopFree #SaaSApp

---

## File Usage Rule

Refresh at least once per week (MANDATORY). Do not refresh more than once per 3 days. Keep only the 10 most recent history records. Filename always carries the last-updated date. Final destination: `/Users/pc/Documents/ahsan-work/ahsan-notebook/static/assets/personal/projects-info-as-portfolio-item/apps/SYSSCOPE_portfolio-info_<YYYY-MM-DD>.md`.
