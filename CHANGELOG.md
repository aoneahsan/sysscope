# Changelog

All notable changes to **sysscope** are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). The public surface for versioning purposes is the
CLI: its flags, its exit codes, and the key names in `--json` output.

> **Note on early history.** Entries for `1.0.0` and `1.0.1` were reconstructed on 2026-07-25 from the git
> history and the npm registry. The repository opens with a single squashed commit, so the `1.0.0` entry
> describes the shipped feature set rather than an incremental list of changes. Dates are npm publish dates.

## [1.0.4] - 2026-07-25

### Fixed

- **The README stated the previous version.** The at-a-glance `Version` row is a static duplicate of
  `package.json.version`, so it drifted the moment the version was bumped — it shipped stale in eight of the
  fleet's packages at once. The row, and any native version string, now move with the release.

## Unreleased

### Added

- `assets/logo.svg` — an SVG master for the project mark, used by the README header.
- `CHANGELOG.md` (this file) and a root `CONTRIBUTING.md`, both shipped in the npm tarball.
- `docs/PACKAGES.md` — the dependency and file inventory.
- `docs/REPORTED-ISSUES.md` — the open issue queue, opened with five findings from a documentation audit.
- `npm run lint` — a one-shot gate that syntax-checks every `*.sh` with `bash -n` and `bin/sysscope.js` with `node --check`.
- A `prepack` script that regenerates `audit-bundle.sh`, so a published tarball can never carry a bundle that is stale relative to the modules.
- `funding` metadata pointing at `aoneahsan.com/payment`.

### Changed

- **README rewritten** to the canonical package layout. It now documents the full command surface, including the `--redact` and `--non-interactive` aliases, the optional value on `--json`, the exit codes, and the complete list of `--json` keys with the presets that emit them.
- `package.json` `description` shortened to match the README tagline exactly.
- `package.json` `author` expanded to the full name, email, and website.

### Fixed

- `bin/sysscope.js` is now executable (mode `755`). It was mode `644` in the repository and in both published tarballs, so `./bin/sysscope.js` failed from a clone despite carrying a shebang. Installs were unaffected — npm sets the bit when it links a `bin`.

### Documented, not yet fixed

These behaviours are unchanged in code and are recorded in
[docs/REPORTED-ISSUES.md](./docs/REPORTED-ISSUES.md):

- `--share` writes unredacted home-folder names into the report when combined with `--deep`.
- The privacy banner claims UUIDs are redacted; none is collected, so none is redacted.
- `--deep` is silently ignored under `--ai-only`.

## 1.0.1 — 2026-07-10

### Changed

- MIT copyright attributed to Ahsan Mahmood (aoneahsan) and SysScope contributors.
- `SYSSCOPE_VERSION` and the package version bumped to `1.0.1`, and `audit-bundle.sh` rebuilt, so the license change could reach the registry.

No behavioural change — this release is documentation only.

## 1.0.0 — 2026-06-08

Initial public release.

### Added

- **Local AI capability engine** (`mod_ai.sh`) — computes a usable memory budget from the inference backend that actually applies (NVIDIA VRAM, Apple Silicon unified memory, or CPU-only), then grades a 15-model Ollama catalog as fits, tight, or too big. Prints a capability tier and a tier-specific starter set.
- **Hardware detection** — OS and chip identity, CPU topology including performance and efficiency core counts, RAM with swap and memory pressure, GPU with core count and Metal version, disk capacity and pressure, battery health, and thermal throttling.
- **Developer and AI toolchain inventory** (`mod_software.sh`) — languages, package managers, containers and VM apps, AI runtimes, Python ML packages, and installed Ollama models.
- **Health scorecard and concurrency guidance** (`mod_recommend.sh`) — disk, memory, AI, and battery ratings with a prioritised list of next actions.
- **Three presets** — `--full`, `--quick`, and `--ai-only`.
- **Three outputs** — a colorized terminal report, a Markdown report, and flat JSON via `--json`.
- **Privacy mode** — `--share` (alias `--redact`) redacts the hostname and serial number and stamps a banner on the report.
- **Interactive and unattended modes** — a menu when both ends are a terminal, fully flag-driven otherwise.
- **`npx sysscope` launcher** (`bin/sysscope.js`) — runs the audit with no install or clone, passing arguments and the exit code through.
- **Single-file bundle** — `build.sh` concatenates every module into `audit-bundle.sh` for curl-and-run distribution.
- Pure Bash 3.2 throughout, with no runtime dependencies.

---

Version headings carry no compare links because this repository has no release tags yet; see
[docs/REPORTED-ISSUES.md](https://github.com/aoneahsan/sysscope/blob/main/docs/REPORTED-ISSUES.md) → ISSUE-005.
Published releases are listed at
[npmjs.com/package/sysscope?activeTab=versions](https://www.npmjs.com/package/sysscope?activeTab=versions).
