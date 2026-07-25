<div align="center">

<img src="https://raw.githubusercontent.com/aoneahsan/sysscope/main/assets/logo.svg" alt="SysScope logo" width="120" />

<h1>sysscope</h1>

<p><strong>See which local AI models and dev workloads your Mac or Linux machine can actually run.</strong></p>

[![npm version](https://img.shields.io/npm/v/sysscope.svg)](https://www.npmjs.com/package/sysscope)
[![downloads](https://img.shields.io/npm/dm/sysscope.svg)](https://www.npmjs.com/package/sysscope)
[![license](https://img.shields.io/npm/l/sysscope.svg)](https://github.com/aoneahsan/sysscope/blob/main/LICENSE)
[![node](https://img.shields.io/node/v/sysscope.svg)](https://nodejs.org)

[npm](https://www.npmjs.com/package/sysscope) · [GitHub](https://github.com/aoneahsan/sysscope) · [Changelog](https://github.com/aoneahsan/sysscope/blob/main/CHANGELOG.md) · [Support](https://github.com/aoneahsan/sysscope/issues)

</div>

SysScope is a read-only Bash auditor that inspects a Mac or Linux machine and answers one question in plain
language: *what can this box actually run?* It grades a catalog of Ollama models against your real memory
budget, inventories your dev and AI toolchain, and prints a health scorecard with concurrency advice. It is a
diagnostic, not a benchmark — every number it prints comes from a system query or a stated arithmetic rule,
never from running a workload.

| | |
|---|---|
| **Version** | `1.0.1` |
| **License** | MIT |
| **Node** | `>=14` — only for `npx`; the tool itself is Bash |
| **Platforms** | macOS · Linux · Windows via WSL |
| **Runtime deps** | None — pure Bash 3.2, no installs |
| **Interface** | CLI only (no importable JavaScript API) |
| **Status** | Stable · maintained |

<a id="table-of-contents"></a>
## 🧭 Table of Contents&nbsp;[#](#table-of-contents)

- [💡 Why sysscope](#why-sysscope)
- [✨ Features](#features)
- [📱 Platform Support](#platform-support)
- [📋 Requirements](#requirements)
- [📦 Installation](#installation)
- [🚀 Quick Start](#quick-start)
- [🛠️ Usage](#usage)
- [🔧 API Reference](#api-reference)
- [💻 Command Line](#command-line)
- [🧪 Examples](#examples)
- [🎛️ Advanced Features](#advanced-features)
- [🚑 Recovery & Troubleshooting](#recovery-troubleshooting)
- [🚧 Limitations](#limitations)
- [❓ FAQ](#faq)
- [📚 Documentation](#documentation)
- [🔄 Changelog](#changelog)
- [🤝 Contributing](#contributing)
- [🗂️ Repository](#repository)
- [💬 Support](#support)
- [📄 License](#license)
- [👤 Author](#author)
- [🔗 Links](#links)
- [🏷️ Keywords](#keywords)

<a id="why-sysscope"></a>
## 💡 Why sysscope&nbsp;[#](#why-sysscope)

"Can my laptop run a 14B model?" is usually answered with a rule of thumb and a shrug. The real answer
depends on how much memory the inference backend can actually reach, and that differs between unified memory
on Apple Silicon, VRAM on a discrete NVIDIA card, and plain system RAM everywhere else. SysScope reads the
machine, applies one stated formula, and gives a per-model verdict you can check.

| | `sysscope` | `neofetch` / `system_profiler` | An online "can I run it" calculator |
|---|---|---|---|
| Reads your real hardware | ✅ | ✅ | ❌ you type the numbers in |
| Per-model fit verdict | ✅ 15 models | ❌ | ✅ |
| Uses the backend's actual memory ceiling | ✅ | ❌ | ⚠️ usually just total RAM |
| Inventories your installed toolchain | ✅ | ❌ | ❌ |
| Runs offline, makes no network calls | ✅ | ✅ | ❌ |
| Markdown report + JSON output | ✅ | ❌ | ❌ |

**Not the right tool when** — you want measured tokens-per-second (SysScope prints qualitative ranges and
never runs inference), you need Windows-native support, you are auditing a fleet rather than one machine, or
you want anything on the host changed. It only reads and reports.

<a id="features"></a>
## ✨ Features&nbsp;[#](#features)

- **Model-fit engine** — grades 15 popular Ollama models against a computed memory budget as fits, tight, or too big.
- **Backend-aware budgeting** — separate formulas for NVIDIA VRAM, Apple Silicon unified memory, and CPU-only.
- **Hardware detection** — chip, P/E core layout, GPU cores, Metal version, RAM, swap, disk pressure, battery health, thermal throttling.
- **Toolchain inventory** — languages, package managers, containers, VM apps, and AI runtimes, each reported present or absent.
- **Health scorecard** — disk, memory, AI, and battery rated with a one-line reason each.
- **Concurrency guidance** — what you can run at the same time without exhausting RAM, keyed to your actual capacity.
- **Three outputs** — colorized terminal, a Markdown report, and flat JSON for scripts.
- **Privacy mode** — redacts the hostname and serial number so a report can be posted publicly.
- **No dependencies** — pure Bash 3.2, compatible with the version macOS still ships.

<a id="platform-support"></a>
## 📱 Platform Support&nbsp;[#](#platform-support)

| Platform | Supported | Notes |
|---|---|---|
| macOS · Apple Silicon | ✅ | The primary target. Unified-memory budget, GPU cores, Metal, battery health, thermals. |
| macOS · Intel | ⚠️ | Everything reports, but a discrete GPU is never measured — the AI budget falls back to the CPU-only formula. |
| Linux · NVIDIA | ✅ | VRAM read from `nvidia-smi` and used as the AI budget. |
| Linux · AMD or integrated | ⚠️ | The GPU is named but not measured, so the AI budget falls back to CPU-only. |
| Linux · battery and thermals | ⚠️ | Charge and status only, read from `/sys/class/power_supply/BAT0`. No cycle count, health, or throttle detection. |
| Windows | ⚠️ | Through WSL or Git Bash only. `npm install` refuses on native Windows by design. |

<a id="requirements"></a>
## 📋 Requirements&nbsp;[#](#requirements)

| Requirement | Version | Why |
|---|---|---|
| Bash | `3.2+` | The whole tool is Bash. 3.2 is what macOS ships, so nothing newer is assumed. |
| Core utilities | any | `awk`, `sed`, `df`, `uname`, `tr` — present on every macOS and Linux install. |
| Node.js | `>=14` | Only to run `npx sysscope`. Cloning the repo or using the single-file bundle needs no Node at all. |

No root, no installs, no compiler. Optional tools deepen the report where present: `nvidia-smi` for VRAM,
`ollama` to list your installed models, `python3` to detect PyTorch, TensorFlow, Transformers, and MLX.

<a id="installation"></a>
## 📦 Installation&nbsp;[#](#installation)

There is nothing to install — `npx` fetches and runs it:

```bash
npx sysscope
```

To keep it on the machine:

```bash
npm install -g sysscope
```

Or take the single self-contained file and skip Node entirely:

```bash
curl -fsSLO https://raw.githubusercontent.com/aoneahsan/sysscope/main/audit-bundle.sh
bash audit-bundle.sh
```

<a id="quick-start"></a>
## 🚀 Quick Start&nbsp;[#](#quick-start)

Answer "which models can I run?" in one non-interactive command:

```bash
npx sysscope --ai-only --yes --no-report
```

```text
== Local AI / LLM Capability ==
  Inference backend      unified memory (Metal GPU shares 16 GB)
  Usable memory budget   ~11.5 GB for the model + context
  Capability tier        Comfortable — 7–9B daily (14B tight)
  [OK ] Hardware-accelerated local inference is available.

  MODEL                  PARAMS  ~SIZE     FITS?
  llama3.1:8b            8B      4.7GB     ✅ yes
  qwen2.5-coder:7b       7B      4.7GB     ✅ yes
  qwen2.5:14b            14B     9.0GB     🟡 tight
  gemma2:27b             27B     16.0GB    🔴 too big
```

Drop the flags (`npx sysscope`) for the interactive menu, which also writes a
`sysscope-report-<timestamp>.md` in the current directory.

<a id="usage"></a>
## 🛠️ Usage&nbsp;[#](#usage)

### Choose how much to run

```bash
npx sysscope --full     # everything (default)
npx sysscope --quick    # everything except the software inventory
npx sysscope --ai-only  # system, CPU, memory, GPU, AI verdict, scorecard
```

### Save a report

```bash
npx sysscope --yes -o audit.md
```

`-o` **overwrites the target file without asking.** Omit it and the report lands at
`./sysscope-report-YYYYMMDD-HHMMSS.md`; pass `--no-report` to print to the terminal only.

### Share a report

```bash
npx sysscope --yes --share -o public.md
```

`--share` replaces the hostname and serial number with `‹redacted›` and stamps a privacy banner. Read
[Limitations](#limitations) before publishing one — the redaction is narrower than the banner suggests.

### Feed a script

```bash
npx sysscope --ai-only --yes --no-report --json metrics.json
```

<a id="api-reference"></a>
## 🔧 API Reference&nbsp;[#](#api-reference)

SysScope has **no importable JavaScript API** — `require('sysscope')` is not supported. Its machine interface
is the JSON file written by `--json`, plus the process exit code.

### Exit codes

| Code | Meaning |
|---|---|
| `0` | The audit completed. Also returned by `--help` and `--version`. |
| `1` | Could not run: a `mod_*.sh` module is missing from the directory, `bash` was not found, or the launcher failed to start the script. |
| `2` | An option was not recognised. |

### JSON keys

Every value is a **JSON string**, including the numeric ones — `"ram_gb": "16"`, not `16`. Parse
accordingly.

| Key | Example | Emitted under |
|---|---|---|
| `os` | `"macOS 26.5.1"` | every preset |
| `arch` | `"arm64"` | every preset |
| `model` | `"MacBook Air"` | every preset |
| `chip` | `"Apple M3"` | every preset |
| `cpu_brand` | `"Apple M3"` | every preset |
| `cpu_logical` | `"8"` | every preset |
| `cpu_physical` | `"8"` | every preset |
| `ram_gb` | `"16"` | every preset |
| `gpu` | `"Apple M3"` | every preset |
| `gpu_cores` | `"10"` | every preset |
| `gpu_vram_gb` | `"0"` | every preset — see the caveat below |
| `unified_memory` | `"1"` | every preset |
| `ai_budget_gb` | `"11.5"` | every preset |
| `ai_tier` | `"Comfortable — 7–9B daily (14B tight)"` | every preset |
| `disk_total_gb` | `"460"` | `--full`, `--quick` |
| `disk_free_gb` | `"67"` | `--full`, `--quick` |
| `disk_used_pct` | `"85"` | `--full`, `--quick` |
| `battery_pct` | `"77"` | `--full`, `--quick` |

Keys are **omitted entirely**, not emitted empty, when their module does not run. Under `--ai-only` the four
storage and battery keys are absent, so read them with a default rather than assuming the key exists.
`battery_pct` is present but empty on a machine with no battery.

`gpu_vram_gb` has exactly one source: `nvidia-smi`. On Apple Silicon, on Intel Macs with a discrete AMD card,
and on Linux without NVIDIA it stays `"0"`, and the budget formula treats the machine as unified-memory or
CPU-only accordingly.

<a id="command-line"></a>
## 💻 Command Line&nbsp;[#](#command-line)

```bash
npx sysscope [options]
```

Presets are mutually exclusive; the last one on the command line wins.

| Preset | Modules it runs |
|---|---|
| `-f`, `--full` *(default)* | system · cpu · memory · gpu · storage · power · software · ai · recommend |
| `-q`, `--quick` | the same, minus the software inventory |
| `-a`, `--ai-only` | system · cpu · memory · gpu · ai · recommend |

| Flag | Default | What it does |
|---|---|---|
| `-o`, `--output FILE` | `./sysscope-report-<timestamp>.md` | Write the Markdown report to `FILE`. **Truncates an existing file without confirming.** |
| `--no-report` | off | Terminal output only; write no file. |
| `--json [FILE]` | off | Also write JSON metrics. The path is optional — with none, it uses the report path with a `.json` extension, or `./sysscope-metrics.json`. |
| `--deep` | off | Add the slowest probe: the ten largest items in your home folder. Can take several minutes. |
| `--share`, `--redact` | off | Redact the hostname and serial number. The two spellings are identical. |
| `-y`, `--yes`, `--non-interactive` | auto | Ask nothing, accept defaults. Already implied when stdin or stdout is not a terminal. |
| `--no-color` | auto | Disable ANSI colors. Already implied when stdout is not a terminal. |
| `--gist-url URL` | the repository URL | Change the feedback URL printed in the report footer. |
| `-V`, `--version` | — | Print the version and exit `0`. |
| `-h`, `--help` | — | Print help and exit `0`. |

**Short flags do not bundle.** Write `-q -y`; `-qy` is rejected as an unknown option with exit `2`.

**`--deep` only affects the storage module**, which `--ai-only` does not run — so `--ai-only --deep` accepts
the flag and silently does nothing. Pair `--deep` with `--full` or `--quick`.

<a id="examples"></a>
## 🧪 Examples&nbsp;[#](#examples)

| Goal | Command |
|---|---|
| Which models fit? | `npx sysscope --ai-only --yes --no-report` |
| Fast unattended check | `npx sysscope --quick --yes` |
| A report safe to paste into an issue | `npx sysscope --yes --share -o public.md` |
| Just the numbers, for a script | `npx sysscope --yes --no-report --json metrics.json` |
| Find what is eating the disk | `npx sysscope --full --yes --deep` |
| Run the newest unreleased code | `npx github:aoneahsan/sysscope` |

Reading one value out of the JSON, remembering that every value is a string:

```bash
npx sysscope --ai-only --yes --no-report --json m.json
node -e "console.log(require('./m.json').ai_tier)"
```

<a id="advanced-features"></a>
## 🎛️ Advanced Features&nbsp;[#](#advanced-features)

- **The budget formula is stated, not hidden.** NVIDIA → 92% of VRAM. Apple Silicon → total RAM − 4.5 GB. CPU-only → total RAM − 3 GB. A model comfortably fits when `size × 1.3 ≤ budget` (the ×1.3 covers the KV cache and context), is *tight* when it merely fits, and *too big* otherwise.
- **Single-file bundle.** `build.sh` concatenates every module into `audit-bundle.sh`, so the tool can ship as one file for curl-and-run. The launcher prefers the bundle when it is present.
- **Extensible modules.** Add a `mod_yours.sh` defining `mod_yours()`, register it in `audit.sh`, then re-run `build.sh` — see [CONTRIBUTING.md](https://github.com/aoneahsan/sysscope/blob/main/CONTRIBUTING.md).
- **Apple Silicon memory tip.** When a 14B model comes out tight, the AI section prints the temporary `iogpu.wired_limit_mb` adjustment that lets the GPU reach more of unified memory.

<a id="recovery-troubleshooting"></a>
## 🚑 Recovery & Troubleshooting&nbsp;[#](#recovery-troubleshooting)

| Symptom | Cause | Fix |
|---|---|---|
| `Unknown option: -qy (try --help)` | Short flags were bundled. | Separate them: `-q -y`. |
| `SysScope error: missing module "mod_system.sh"` | `audit.sh` was copied away from its siblings. | Run it from the folder holding all the `*.sh` files, or use `audit-bundle.sh`, which is self-contained. |
| `SysScope needs "bash"` | No `bash` on `PATH`. | Install it, or run under WSL or Git Bash on Windows. |
| `npm ERR! Unsupported platform` | The package declares `os: darwin, linux`. | Expected on native Windows. Install inside WSL. |
| `--deep` appears to hang | It is running `du` over your entire home folder. | Wait, or drop `--deep`. It is the slowest probe by a wide margin. |
| `--deep` printed nothing | It was combined with `--ai-only`, which skips the storage module. | Use `--full --deep` or `--quick --deep`. |
| The report file lost its previous contents | `-o` truncates its target. | Point `-o` at a new path, or let the default timestamped name be used. |
| `Cannot write report to …` | The path is not writable. | Choose a writable path. The audit still runs and prints to the terminal. |
| VRAM shows `0 GB` on a machine with a real GPU | VRAM is only read from `nvidia-smi`. | Expected on Apple Silicon, Intel Macs, and AMD. The budget falls back to unified-memory or CPU-only. |
| A JSON key your script reads is missing | Its module did not run under the chosen preset. | Use `--full`, or read the key with a default. |

<a id="limitations"></a>
## 🚧 Limitations&nbsp;[#](#limitations)

- **`--share` redacts two fields only** — the hostname and the serial number. The privacy banner it stamps says "serial numbers, UUIDs and hostnames", but no UUID is ever collected, so none is ever redacted. Treat the banner as narrower than it reads.
- **`--share` does not redact `--deep` output.** The deep probe lists the largest items in your home folder by name, and those names are written into the report unredacted even in share mode. Never publish a `--share --deep` report without reading it first.
- **The report is not otherwise anonymised.** Machine model, installed applications, and your Ollama model list all appear in it.
- **No measured performance.** Tokens-per-second figures are qualitative ranges from published expectations, not benchmarks run on your machine. Model sizes are approximate Q4_K_M download sizes and drift as upstream re-quantises.
- **The model catalog is a hardcoded list of 15** in `mod_ai.sh`. It does not query the Ollama registry, so newer models are absent until the list is updated.
- **VRAM detection is NVIDIA-only.** AMD and Intel discrete GPUs are named but never measured.
- **Linux support is narrower than macOS.** Battery reports charge and status only; thermal throttling, battery health, and cycle count are macOS-only, and only `BAT0` is read.
- **Not a library.** There is no `main` or `exports`; the package is a CLI, and its only machine interface is the JSON file.
- **No test suite.** Verification is `npm run lint` — a Bash and Node syntax check — plus running the tool.

<a id="faq"></a>
## ❓ FAQ&nbsp;[#](#faq)

**Does it change anything on my machine?**
No. It runs read-only queries and writes only the report and JSON paths you choose. It makes no network
calls — `npx` downloads the package, and after that everything is local.

**Does Ollama use the Neural Engine on Apple Silicon?**
No, and this is the misconception SysScope exists to correct. Ollama and llama.cpp run on the GPU via Metal.
The Neural Engine is not used, which is why total RAM — not a separate accelerator — sets the ceiling.

**Why does my 32 GB machine only get a ~27.5 GB budget?**
Apple Silicon shares one memory pool with macOS and your open apps, so the formula reserves 4.5 GB. The
remainder is what a model plus its context can realistically occupy.

**Can I run it without Node?**
Yes. Clone the repository and run `./audit.sh`, or download `audit-bundle.sh` and run that. Node is needed
only for the `npx` entry point.

**Why won't it install on Windows?**
`package.json` declares `os: ["darwin", "linux"]`, so npm refuses rather than installing something that
cannot work. WSL reports as Linux and installs normally.

<a id="documentation"></a>
## 📚 Documentation&nbsp;[#](#documentation)

| Document | Read it when |
|---|---|
| This README | you want the whole command surface in one place — it is the complete reference today |
| [CHANGELOG.md](https://github.com/aoneahsan/sysscope/blob/main/CHANGELOG.md) | you need to know what changed between versions |
| [CONTRIBUTING.md](https://github.com/aoneahsan/sysscope/blob/main/CONTRIBUTING.md) | you are adding a module, updating the model catalog, or requesting access |
| [`mod_ai.sh`](https://github.com/aoneahsan/sysscope/blob/main/mod_ai.sh) | you want to read the budget formula and the model catalog at the source |
| [`audit.sh`](https://github.com/aoneahsan/sysscope/blob/main/audit.sh) | you want to see exactly how a flag is parsed |

A dedicated documentation site is in progress; this README stays the canonical reference until it is live.

<a id="changelog"></a>
## 🔄 Changelog&nbsp;[#](#changelog)

Latest release: **`1.0.1`** — MIT copyright attributed to Ahsan Mahmood.
Full history: [CHANGELOG.md](https://github.com/aoneahsan/sysscope/blob/main/CHANGELOG.md).

<a id="contributing"></a>
## 🤝 Contributing&nbsp;[#](#contributing)

Fork and open a pull request — see
[CONTRIBUTING.md](https://github.com/aoneahsan/sysscope/blob/main/CONTRIBUTING.md) for setup, standards, and
how to request collaborator access. `main` is protected: every change lands through a reviewed PR.

Keeping the model catalog in `mod_ai.sh` current is the most useful contribution, and it is pure data.

<a id="repository"></a>
## 🗂️ Repository&nbsp;[#](#repository)

The modules sit flat at the repository root, because `audit.sh` sources its siblings by name and
`audit-bundle.sh` is generated by concatenating them in order.

```text
audit.sh           entry point: flag parsing, interactive menu, orchestration
audit-bundle.sh    GENERATED by build.sh — every file below, concatenated into one
build.sh           regenerates audit-bundle.sh; re-run after editing any module
bin/sysscope.js    Node launcher for npx; runs the bundle, passes args and exit code through
lib_core.sh        output formatting, OS detection, prompts, helpers
lib_report.sh      Markdown and JSON document lifecycle, tables
mod_system.sh      OS, model, chip, kernel
mod_cpu.sh         CPU topology (P/E cores)
mod_memory.sh      RAM, swap, pressure
mod_gpu.sh         GPU, unified versus discrete memory
mod_storage.sh     disk capacity, free space, the --deep probe
mod_power.sh       battery health, charge, thermal throttling
mod_software.sh    languages, package managers, containers, AI tooling
mod_ai.sh          the model-fit engine and the model catalog
mod_recommend.sh   health scorecard and workload guidance
assets/logo.svg    SVG master for the logo above
```

Edit the modules, never `audit-bundle.sh` — the next `build.sh` overwrites it.

<a id="support"></a>
## 💬 Support&nbsp;[#](#support)

Questions and bugs: [open an issue](https://github.com/aoneahsan/sysscope/issues). Include your OS, chip, and
the line that looked wrong — `--share` redacts the identifying fields for you.

If this package saves you time, you can support its maintenance at
[aoneahsan.com/payment](https://aoneahsan.com/payment?project-id=sysscope&project-identifier=sysscope).

<a id="license"></a>
## 📄 License&nbsp;[#](#license)

MIT © Ahsan Mahmood — see [LICENSE](https://github.com/aoneahsan/sysscope/blob/main/LICENSE).

<a id="author"></a>
## 👤 Author&nbsp;[#](#author)

**Ahsan Mahmood** — [aoneahsan.com](https://aoneahsan.com) · [GitHub](https://github.com/aoneahsan) ·
[LinkedIn](https://linkedin.com/in/aoneahsan) · [aoneahsan@gmail.com](mailto:aoneahsan@gmail.com)

<a id="links"></a>
## 🔗 Links&nbsp;[#](#links)

| | |
|---|---|
| npm | https://www.npmjs.com/package/sysscope |
| Repository | https://github.com/aoneahsan/sysscope |
| Issues | https://github.com/aoneahsan/sysscope/issues |
| Changelog | https://github.com/aoneahsan/sysscope/blob/main/CHANGELOG.md |
| Contributing | https://github.com/aoneahsan/sysscope/blob/main/CONTRIBUTING.md |
| Single-file bundle | https://raw.githubusercontent.com/aoneahsan/sysscope/main/audit-bundle.sh |
| Support the project | https://aoneahsan.com/payment |

<a id="keywords"></a>
## 🏷️ Keywords&nbsp;[#](#keywords)

*system-audit · hardware · ollama · llm · local-ai · apple-silicon · macos · gpu · cli · diagnostics · ai-readiness*
