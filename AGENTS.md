# AGENTS.md — Guidance for AI coding agents working on SysScope

> ⚠️ **THIS IS A PUBLIC REPOSITORY.** SysScope is published to GitHub, mirrored as a public Gist, and runnable by anyone via `npx github:aoneahsan/sysscope`. Treat every file here as world-readable, permanently.

## 🔒 Rule #1 — Never commit sensitive or personal information

This project must contain **only generic, reusable code and docs**. Do **NOT** add, commit, hardcode, or paste into any file:

- **Machine identifiers:** serial numbers, hardware UUIDs, provisioning UDIDs, MAC addresses
- **Identity:** hostnames, usernames, real email addresses, and user-specific paths (e.g. `/Users/<name>/…`)
- **Real audit output** from a specific machine — it commonly embeds the identifiers above
- **Secrets:** API keys, tokens, passwords, private IPs / network details
- **Anything from the parent `system-audit/` report** — a PRIVATE, machine-specific document that must never enter this repo

Generated outputs (`sysscope-report-*.md`, `*-metrics.json`) are git-ignored. **Never force-add them.**

When adding example output to docs, use **redacted / generic placeholders only** (`--share` mode shows the style: `‹redacted›`).

## ✅ Before every commit
1. Scan the staged diff (`git diff --cached`) for the patterns above.
2. Confirm no new file embeds host-specific data.
3. Keep the tool **read-only** — it must never modify, upload, or phone home from the host it audits.
4. Keep it **dependency-free** and **Bash 3.2-compatible** (no associative arrays, no `${var,,}`).

## 🧱 Project layout & workflow
- Entry point `audit.sh` sources `lib_*.sh` + `mod_*.sh`; each `mod_*.sh` covers one subsystem.
- The local-AI fit engine and model catalog live in `mod_ai.sh`.
- After editing any module, run `bash build.sh` to regenerate the single-file `audit-bundle.sh` (the npx/curl distributable), then `bash -n *.sh` and a quick `./audit.sh --quick --yes --no-report` smoke test.

This file mirrors `CLAUDE.md`; keep both in sync if you change the rules.
