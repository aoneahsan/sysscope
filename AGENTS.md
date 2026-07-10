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
