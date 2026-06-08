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

## 🔁 Workflow when changing the tool
1. Edit the relevant `mod_*.sh` / `lib_*.sh`.
2. `bash build.sh` to refresh `audit-bundle.sh` (the npx/curl distributable).
3. `bash -n *.sh` to syntax-check, and run `./audit.sh --quick --yes --no-report` to smoke-test.
4. Commit (after the sensitive-data scan above).

See also `AGENTS.md` (same rules, vendor-neutral).
