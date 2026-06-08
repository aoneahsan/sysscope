# 🔭 SysScope — System Capability & AI-Readiness Audit

A small, **modular, read-only** shell tool that audits any Mac (and most Linux boxes) and tells you, in plain language:

- **What hardware you have** — CPU, GPU, Neural Engine, RAM, storage, battery, thermals
- **What dev & AI software is installed** — languages, package managers, containers, VMs, LLM tooling
- **Which local AI models you can actually run** — a model-by-model "fits / tight / too big" verdict tuned to *your* memory
- **What to run together** — a health scorecard and concurrency advice so you don't blow your RAM budget

It prints a colorized terminal report **and** writes a shareable Markdown report (plus optional JSON). It never changes your system — it only reads.

> Made for the common question: *"I want to run Ollama / Docker / emulators / VMs on this machine — what will actually run well, and what should I pick?"*

**▶ Try it now (no install):**

```bash
npx github:aoneahsan/sysscope
```

---

## ✨ Features

- 🧠 **AI capability engine** — computes a realistic memory budget (unified RAM on Apple Silicon, VRAM on NVIDIA, or CPU-only) and grades 15 popular Ollama models against it.
- 🖥️ **Real hardware detection** — Apple Silicon core layout, GPU cores, Metal version, NVIDIA VRAM, disk pressure, battery health, thermal throttling.
- 🩺 **Health scorecard** — disk / memory / AI / battery rated 🟢🟡🟥 with one-line reasons.
- 🧩 **Modular** — one job per file (`lib_*`, `mod_*`). Easy to read, extend, or trim.
- 📦 **Single-file bundle** — `build.sh` concatenates everything into `audit-bundle.sh` for `curl | bash` distribution.
- 🔒 **Privacy mode** — `--share` redacts serials, UUIDs, and hostname so you can post the report publicly.
- 🤝 **Interactive or unattended** — menu-driven by default, fully scriptable with flags.
- 📄 **Multiple outputs** — pretty terminal, Markdown report, and machine-readable JSON.
- 🐚 **Portable** — pure Bash, compatible with the **bash 3.2** that ships on macOS (no extra installs).

---

## 🚀 Quick start

### Option A — run it with `npx` (no install, no clone) ⭐

```bash
npx github:aoneahsan/sysscope
```

That's the whole thing. `npx` fetches and runs it; you get an interactive menu, then a saved `sysscope-report-*.md`. Pass any flag straight through:

```bash
npx github:aoneahsan/sysscope --ai-only      # "which models can I run?"
npx github:aoneahsan/sysscope --quick --yes  # fast, unattended
npx github:aoneahsan/sysscope --share        # redacted, shareable report
```

> Needs Node (for `npx`) and `bash` (built in on macOS/Linux; use WSL/Git Bash on Windows). The launcher only runs the local audit — it makes no network calls.

### Option B — clone the repo (modular version)

```bash
git clone https://github.com/aoneahsan/sysscope.git
cd sysscope
chmod +x audit.sh
./audit.sh
```

### Option C — single file, no Node

```bash
# Download just the self-contained bundle and run it
curl -fsSLO https://raw.githubusercontent.com/aoneahsan/sysscope/main/audit-bundle.sh
bash audit-bundle.sh

# …or pipe it (always review remote scripts first!):
curl -fsSL https://raw.githubusercontent.com/aoneahsan/sysscope/main/audit-bundle.sh | bash
```

---

## 🕹️ Usage

```text
./audit.sh [options]

PRESETS
  -f, --full         Full audit (default)
  -q, --quick        Faster: skips software inventory & deep disk scan
  -a, --ai-only      Just "what AI models can I run?"

OUTPUT
  -o, --output FILE  Markdown report path (default: ./sysscope-report-<timestamp>.md)
      --no-report    Terminal only
      --json [FILE]  Also write JSON metrics
      --deep         Include slow probes (largest items in home folder)

PRIVACY
      --share        Redact serials / UUIDs / hostname (safe to publish)

BEHAVIOR
  -y, --yes          Non-interactive (accept defaults)
      --no-color     Disable colors
      --gist-url URL Feedback URL printed in the report
  -V, --version      Print version
  -h, --help         Show help
```

### Examples

```bash
./audit.sh                       # interactive, full audit, saves a report
./audit.sh --quick --yes         # fast, unattended
./audit.sh --ai-only             # which models fit?
./audit.sh --share -o report.md  # redacted, shareable
./audit.sh --json metrics.json   # full audit + JSON metrics
```

---

## 📟 Sample output (excerpt, redacted)

```text
== Local AI / LLM Capability ==
  Inference backend      unified memory (Metal GPU shares 16 GB)
  Usable memory budget   ~11.5 GB for the model + context
  Capability tier        Comfortable — 7–9B daily (14B tight)
  [OK ] Hardware-accelerated local inference is available.

  Which models fit (Ollama, Q4 quantization)
  MODEL                  PARAMS  ~SIZE     FITS?
  llama3.1:8b            8B      4.7GB     ✅ yes
  qwen2.5-coder:7b       7B      4.7GB     ✅ yes
  gemma2:9b              9B      5.4GB     ✅ yes
  qwen2.5:14b            14B     9.0GB     🟡 tight
  gemma2:27b             27B     16.0GB    🔴 too big

== Health Scorecard & Recommendations ==
  Disk             🟥 critical  Only 19 GB free — reclaim before installing tools.
  Memory           🟢 good      16 GB — one very-heavy workload at a time.
  Local AI         🔭           Comfortable — 7–9B daily (14B tight) (~11.5 GB budget)
```

The Markdown report contains the same content as GFM tables, ready to paste into an issue, wiki, or gist comment.

---

## 🧠 How the AI capability engine works

1. **Find the memory budget** that matters for inference:
   - **NVIDIA GPU** → ~92% of VRAM (`nvidia-smi`).
   - **Apple Silicon** → `total RAM − 4.5 GB` (the GPU shares unified memory; the rest is for macOS + a couple of apps).
   - **CPU-only** → `total RAM − 3 GB`, with a "this will be slow" warning.
2. **Grade each model** in a built-in catalog: a model *comfortably fits* if `size × 1.3 ≤ budget` (the ×1.3 covers the KV cache / context), is *tight* if it merely fits, else *too big*.
3. **Pick a tier** (Minimal → Workstation) and print a tailored **starter set** plus install commands.

Generation speed is memory-bandwidth-bound, so the tool gives qualitative tok/s ranges rather than false precision.

> Note: on Apple Silicon, local LLM runtimes (Ollama, llama.cpp) use the **GPU via Metal**, *not* the Neural Engine. SysScope says so explicitly to clear up a common myth.

---

## 🧩 Project structure

Each file does one thing and is sourced by `audit.sh`:

| File | Responsibility |
|------|----------------|
| `audit.sh` | Entry point: arg parsing, interactive menu, orchestration |
| `lib_core.sh` | Output/formatting, OS detection, prompts, helpers |
| `lib_report.sh` | Markdown + JSON document lifecycle, tables |
| `mod_system.sh` | OS, model, chip, kernel identity |
| `mod_cpu.sh` | CPU topology (P/E cores) |
| `mod_memory.sh` | RAM, swap, pressure |
| `mod_gpu.sh` | GPU, unified vs discrete VRAM, accelerators |
| `mod_storage.sh` | Disk capacity, free space, biggest items |
| `mod_power.sh` | Battery health, charge, thermal throttling |
| `mod_software.sh` | Languages, package managers, containers, AI tooling |
| `mod_ai.sh` | **Local-AI capability assessment** |
| `mod_recommend.sh` | Health scorecard + workload guidance |
| `build.sh` | Bundles all of the above into `audit-bundle.sh` |

### Extending it

Add a `mod_yours.sh` that defines `mod_yours()` using the helpers (`section`, `field`, `status`, `bullet`, `table_begin`/`table_row`, `j`). Register it in `audit.sh` (the `_SS_MODULES` list and a preset in `modules_for_preset`), then `./build.sh` to refresh the bundle.

---

## 💻 Compatibility

| Platform | Support |
|----------|---------|
| macOS (Apple Silicon) | ✅ Full — the primary target |
| macOS (Intel) | ✅ Full |
| Linux (NVIDIA / generic) | 🟡 Best-effort — hardware, RAM, disk, AI budget, software; battery/thermals limited |
| Windows | ❌ Use WSL (Linux path) |

Requires only **Bash 3.2+** and standard Unix tools (`awk`, `sed`, `df`). No root, no installs.

---

## 🔒 Privacy

By default the report includes your serial number and hostname (handy for your own records). Run with `--share` (or answer "yes" to the redaction prompt) to replace those with `‹redacted›` and stamp a privacy banner — then the Markdown is safe to post publicly.

SysScope makes **no network connections** and **writes nothing outside** the report/JSON paths you choose.

---

## 💬 Feedback & contributing

Found a value that looked wrong on your machine, or want a check added (more GPUs, more models, BSD support)?

- Open an issue: https://github.com/aoneahsan/sysscope/issues — include your **OS + chip + the line that looked off** (no serials needed; `--share` redacts them for you).
- Or fork and tweak a `mod_*.sh` — it's deliberately small. After editing modules, run `./build.sh` to refresh `audit-bundle.sh`, then open a PR.

The built-in model catalog in `mod_ai.sh` is just data; PRs that keep model sizes current are very welcome.

---

## 📜 License

MIT — see [`LICENSE`](./LICENSE). Use it, fork it, ship it.

---

## ⚠️ Disclaimer

SysScope is **read-only** and reports estimates (model sizes, speeds, and budgets are approximate and depend on quantization, context length, and other running apps). Always sanity-check before making purchasing or production decisions.
