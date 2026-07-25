# Contributing to SysScope

Thanks for looking. SysScope is deliberately small — a few hundred lines of Bash with no dependencies — so a
useful contribution is usually a short one. Updating the model catalog is pure data and is the single most
valuable thing anyone can send.

## Table of contents

- [How this repository is governed](#how-this-repository-is-governed)
- [Ways to contribute](#ways-to-contribute)
- [Becoming a contributor](#becoming-a-contributor)
- [Development setup](#development-setup)
- [The build step you must not skip](#the-build-step-you-must-not-skip)
- [Coding standards](#coding-standards)
- [Adding a module](#adding-a-module)
- [Updating the model catalog](#updating-the-model-catalog)
- [Never commit machine-specific data](#never-commit-machine-specific-data)
- [Commit messages](#commit-messages)
- [Opening a pull request](#opening-a-pull-request)
- [Reporting a bug](#reporting-a-bug)
- [Supporting the project](#supporting-the-project)

## How this repository is governed

`main` is protected. Every change — including the maintainer's own, in normal use — lands through a pull
request that has:

- at least one approving review,
- a green build,
- no force-push and no branch deletion.

Only the repository admin can bypass this, and that exists for maintenance, not for routine work. **Write
access does not let you push to `main`**; review is always required. Nothing here is a barrier to
contributing — fork-and-pull-request needs no access at all.

## Ways to contribute

| Contribution | Effort | Notes |
|---|---|---|
| Update model sizes in `mod_ai.sh` | Low | Pure data. Sizes drift as upstream re-quantises. |
| Add a tool to the software inventory | Low | One `sw_check` line in `mod_software.sh`. |
| Improve Linux hardware detection | Medium | The weakest area — see the limitations in the README. |
| Add AMD or Intel VRAM detection | Medium | Currently NVIDIA-only, which is a real gap. |
| Add a new `mod_*.sh` subsystem | Medium | Follow the module contract below. |
| Fix a wrong reading on your machine | Any | Include your OS and chip in the PR description. |

## Becoming a contributor

**You do not need any access to contribute.** Fork the repository, push a branch to your fork, and open a
pull request. That is the normal path and it is open to everyone.

If you expect to contribute repeatedly and would rather work from a branch in this repository, you can
request collaborator access by opening an issue titled *"Contributor access request"* that says what you plan
to work on, or by emailing [aoneahsan@gmail.com](mailto:aoneahsan@gmail.com). Access is granted at the
maintainer's discretion, and as noted above it still does not allow pushing directly to `main`.

## Development setup

There is nothing to install. Clone it and run it:

```bash
git clone https://github.com/aoneahsan/sysscope.git
cd sysscope
./audit.sh --quick --yes --no-report
```

Node is needed only if you want to exercise the `npx` launcher.

Before pushing, run the gate:

```bash
npm run lint
```

That syntax-checks every `*.sh` with `bash -n` and `bin/sysscope.js` with `node --check`. It must exit `0`.
There is no automated test suite; verification is the linter plus running the tool on a real machine and
reading the output.

## The build step you must not skip

`audit-bundle.sh` is **generated**. It is the single-file distributable that `npx` and the curl-and-run path
actually execute, and it is committed to the repository.

```bash
bash build.sh
```

**Edit the modules, never `audit-bundle.sh`** — the next build overwrites it. After changing any `lib_*.sh`,
`mod_*.sh`, or `audit.sh`, re-run `build.sh` and commit the regenerated bundle alongside your change. A pull
request whose bundle is out of sync with its modules ships broken code to every `npx` user, because they run
the bundle and never see your module edit.

`npm pack` and `npm publish` run `build.sh` automatically, so a released tarball cannot carry a stale bundle.
Committing it yourself is still required, so that the repository and the bundle agree.

## Coding standards

- **Bash 3.2.** macOS still ships 3.2, so no associative arrays, no `${var,,}`, no `mapfile`, no `&>>`.
- **Read-only, always.** SysScope must never modify, install, upload, or phone home. It writes only the
  report and JSON paths the user asked for. A contribution that changes the host will not be merged.
- **No dependencies.** Only `bash` and the core utilities present on every macOS and Linux install. Where an
  optional tool deepens the report, guard it with `have <tool>` and degrade quietly.
- **Quote every expansion** — `"$var"`, not `$var`. Paths contain spaces.
- **Use the output helpers**, never bare `echo`: `section`, `subsection`, `field`, `bullet`, `note`,
  `status`, `table_begin` / `table_row`, and `j` for JSON. They mirror terminal output into the Markdown
  report; a bare `echo` appears on screen and vanishes from the report.
- **Redact identifying values** by passing them through `rd` before printing.
- **Honest output.** No invented numbers. If a value cannot be read on a platform, say so rather than
  guessing — the tool's whole value is that its numbers can be trusted.

## Adding a module

A module is one file defining one function of the same name.

1. Create `mod_yours.sh` defining `mod_yours()`.
2. Add `mod_yours` to `_SS_MODULES` in `audit.sh`.
3. Add it to the presets it belongs in, in `modules_for_preset`.
4. Emit any machine-readable values with `j <key> <value>`, and document the key in the README's API
   Reference table — including which presets emit it, since a key absent under one preset is a real
   compatibility concern for scripts.
5. Run `bash build.sh`, then `npm run lint`.

Modules run in list order and may read globals set by earlier ones (`mod_ai` depends on `MEM_TOTAL_GB`,
`GPU_VRAM_GB`, and `IS_UNIFIED`). If your module needs a value, make sure it runs after the module that sets
it, in every preset that includes both.

## Updating the model catalog

The catalog lives in `_ai_catalog()` in `mod_ai.sh`, one model per line:

```text
name|params|approx Q4_K_M size in GB
```

Sizes should be the actual Ollama Q4_K_M download size. Please say in the pull request how you checked —
`ollama pull` output or the model's registry page is fine. Keep the list ordered by size, and keep it short:
it is a representative sample for calibration, not a mirror of the registry.

## Never commit machine-specific data

This repository is public and permanent. Generated reports embed serial numbers, hostnames, home-folder
names, and user paths, and they are gitignored for that reason.

**Never `git add -f` a `sysscope-report-*.md` or a metrics JSON.** When you need example output in a
document, redact it by hand or generate it with `--share` and check every line — and note that `--share` does
not redact `--deep` output.

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```text
feat(ai): add gemma3 models to the catalog
fix(gpu): read VRAM on AMD via rocm-smi
docs(readme): document the --json key set per preset
chore(build): regenerate audit-bundle.sh
```

Common types here: `feat`, `fix`, `docs`, `chore`, `refactor`. A change to the CLI surface — a renamed flag,
a removed exit code, a renamed JSON key — is a breaking change; say so in the body with a
`BREAKING CHANGE:` footer.

## Opening a pull request

1. Fork, and branch from `main`.
2. Make the change, then `bash build.sh` if you touched any shell source.
3. `npm run lint` — must exit `0`.
4. Run the tool and paste the relevant output into the PR, redacted.
5. Add a `CHANGELOG.md` entry under `Unreleased`.
6. Open the PR against `main` describing what changed, why, and the machine you verified it on.

Do not bump the version in a pull request; the maintainer handles releases.

## Reporting a bug

[Open an issue](https://github.com/aoneahsan/sysscope/issues) with your OS and version, your chip, the
command you ran, and the line that looked wrong. `--share` redacts the hostname and serial for you — please
read the output before posting anyway.

A wrong reading is a genuinely useful report: the tool is calibrated against a small number of machines, and
the only way it improves is people saying what it got wrong on theirs.

## Supporting the project

If SysScope saved you time, you can support its maintenance at
[aoneahsan.com/payment](https://aoneahsan.com/payment?project-id=sysscope&project-identifier=sysscope).
Contributions of code, bug reports, and corrected model sizes are worth just as much.
