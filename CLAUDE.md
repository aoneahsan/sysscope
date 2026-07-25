# CLAUDE.md — Guidance for Claude & AI agents working on SysScope

> ⚠️ **THIS IS A PUBLIC REPOSITORY.** SysScope is published to GitHub, mirrored as a public Gist, and runnable by anyone via `npx github:aoneahsan/sysscope`. Treat every file here as world-readable, permanently.

## 🔒 Rule #1 — Never commit sensitive or personal information

This project must contain **only generic, reusable code and docs**. Do **NOT** add, commit, hardcode, or paste into any file:

- **Machine identifiers:** serial numbers, hardware UUIDs, provisioning UDIDs, MAC addresses
- **Identity:** hostnames, usernames, real email addresses, and user-specific paths (e.g. `/Users/<name>/…`)
- **Real audit output** captured from a specific machine — it commonly embeds the identifiers above
- **Secrets:** API keys, tokens, passwords, private IPs/network details
- **Anything from the parent `system-audit/` report** — that is a PRIVATE, machine-specific document and must never enter this repo

Generated outputs (`sysscope-report-*.md`, `*-metrics.json`) are git-ignored. **Never `git add -f` them.**

When adding example output to docs, use **redacted / generic placeholders only**. The tool's `--share` mode demonstrates the expected style (`‹redacted›`).

## ✅ Before every commit
1. Scan the staged diff for the patterns above (`git diff --cached`).
2. Confirm no new file embeds host-specific data.
3. Keep the tool **read-only** — it must never modify, upload, or phone home from the host it audits.
4. Keep it **dependency-free** and **Bash 3.2-compatible** (no associative arrays, no `${var,,}`).

## 🧱 Project layout
- `audit.sh` — entry point; parses args, sources `lib_*.sh` + `mod_*.sh`, orchestrates.
- `lib_core.sh` / `lib_report.sh` — output, prompts, detection; Markdown/JSON lifecycle.
- `mod_*.sh` — one subsystem each (system, cpu, memory, gpu, storage, power, software, **ai**, recommend).
- `mod_ai.sh` — the local-AI model-fit engine; the model catalog/sizes live here.
- `build.sh` — regenerates the single-file `audit-bundle.sh`. **Run it after editing any module.**
- `bin/sysscope.js` — Node launcher so `npx` runs the bundled script (passes args + exit code through).
- `docs/PACKAGES.md` — dependency + published-file inventory. `docs/REPORTED-ISSUES.md` — **open issue queue; read it before starting work** (5 open as of 2026-07-25, ISSUE-001 is a privacy leak).

## 🔁 Workflow when changing the tool
1. Edit the relevant `mod_*.sh` / `lib_*.sh`.
2. `bash build.sh` to refresh `audit-bundle.sh` (the npx/curl distributable).
3. `npm run lint` (bash -n on every `*.sh` + `node --check` on the launcher), then run `./audit.sh --quick --yes --no-report` to smoke-test.
4. Add a `CHANGELOG.md` entry under `Unreleased`.
5. Commit (after the sensitive-data scan above).

See also `AGENTS.md` (same rules, vendor-neutral).

## Sub-agents & Skills — Main-Context-First (IRON-SOLID)
Default/built-in sub-agents (`general-purpose`, `Explore`, `Plan`, `claude`, `fork`, …) do NOT have
access to `/skills`, so delegating to them silently SKIPS the skills RULE #0 requires. So: **do all
skill-relevant work in the MAIN context**; use a sub-agent ONLY when a **custom** agent exists in
`.claude/agents/` for that job; a default `Explore`/`Plan` agent is allowed ONLY for read-only,
no-skill search/exploration; and when a relevant skill is missing, **install/enable it** rather than
proceeding skill-less. (Owner directive 2026-07-11; full text in `~/.claude/CLAUDE.md`.)

## Source maps — disabled by default — RULE
Never generate source maps for this project unless the owner (aoneahsan) explicitly requests them.
Production / build / published output must ship WITHOUT source maps — no `.map` files and no
`//# sourceMappingURL` in shipped assets.

- **Vite**: `build.sourcemap: false` in `vite.config.*`.
- **Rollup**: `output.sourcemap: false` on every output.
- **Webpack**: production `devtool: false` (dev-only inline maps for local debugging are allowed).
- **tsup**: `sourcemap: false`.
- **tsconfig** (library / `tsc` builds): `"sourceMap": false`, `"inlineSourceMap": false`, `"declarationMap": false`.

Dev-only inline source maps for local debugging are fine; never emit source maps in production / published
output. Do NOT re-enable production source maps or delete these settings. Only the owner, by an explicit
request, may turn production source maps on (e.g. a one-off Sentry upload).

<!-- RULE:main-context-model-workflow v2026-07-16 -->
## Main-Context + Skills + Model Workflow (IRON-SOLID — CRITICAL)
1. **NO default/built-in sub-agents** (`general-purpose`, `Explore`, `Plan`, `claude`, `fork`, …) for ANY work in
   this project — they cannot invoke /skills, which RULE #0 makes mandatory. Do ALL work (planning, implementation,
   review, exploration) in the MAIN context. A sub-agent is allowed ONLY when a CUSTOM agent exists in
   `.claude/agents/` for that exact job.
2. **Skills always:** before any task, scan the available-skills list and invoke EVERY relevant skill; if a needed
   skill is missing, download/enable/install it (or use the nearest installed equivalent and say so) — never
   proceed skill-less.
3. **Model workflow:** PLAN and REVIEW on **Fable 5**; EXECUTE the approved plan on **Opus 4.8**. Plans in
   `~/.claude/plans/`; multi-phase features keep a resumable tracker (`docs/features/<slug>/00-tracker.json`),
   resumed rather than re-planned from zero.

Global records (rules, policy, audit reports) live in the `ahsan-notebook` repo at
`static/assets/claude-code/`; the `~/.claude/…` paths are symlinks into it. Full text: `~/.claude/CLAUDE.md`.
(Owner directives 2026-07-11 / 2026-07-14; fleet-rolled 2026-07-16.)

<!-- RULE:orcid-bibtex v2026-07-25 -->
## ORCID / BibTeX record

This project is published as a work on ORCID **0009-0006-2311-8687** (Ahsan Mahmood). Its BibTeX entry lives at
`~/Documents/ahsan-work/ahsan-notebook/static/assets/personal/orcid-project-projects-files/sysscope.bib`, beside a
combined `aoneahsan-all-works.bib` used for a single import.

On **"update ORCID profile info"**: regenerate that file from this project's portfolio-info file and its
**probe-verified** live URLs, refresh the combined file in the same edit, and invoke
`aoneahsan-cccs-orcid-profile` + `aoneahsan-cccs-bibtex` (agent: `aoneahsan-ccca-orcid`). Never invent a URL, a
DOI or a release year — an unreachable channel is omitted, never claimed. Importing, and the work-type retype
that BibTeX cannot perform, are owner-only steps recorded in that folder's `MANUAL-TASKS.md`.
