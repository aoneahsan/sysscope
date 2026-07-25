# Packages — sysscope

The dependency and published-file inventory for this package.

**Last Updated:** 2026-07-25

## Package units

One `package.json`, at the repository root, named `sysscope`. There is no workspace, no nested manifest, and
no build output directory that could produce a second one — `build.sh` emits a single shell file
(`audit-bundle.sh`), not a `dist/` tree.

Verify:

```bash
find . -name package.json -not -path './node_modules/*' -not -path './.git/*'
```

Must print exactly one path.

## Dependencies

**None — in any category.** No `dependencies`, no `devDependencies`, no `peerDependencies`, no
`optionalDependencies`. The tool is Bash; the npm package exists only to give it an `npx` entry point.

`yarn.lock` is present and effectively empty, and `.pnp.cjs` is a Yarn PnP artifact from a `yarn install` on
an empty dependency set. Neither is in `files`, so neither ships.

This is a deliberate constraint, not an accident. See `CONTRIBUTING.md` → Coding standards: a contribution
that adds a runtime dependency will not be merged.

## Runtime requirements

| Requirement | Version | Enforced by | Why |
|---|---|---|---|
| Bash | `3.2+` | Not enforced; it is what the code targets | macOS still ships 3.2 |
| Node.js | `>=14` | `engines.node` (a warning, not a hard block) | Only for the `npx` launcher |
| Platform | `darwin`, `linux` | `os` in `package.json` — npm **refuses** to install elsewhere | The probes are macOS and Linux specific |

`engines.node >= 14` is a judgement, not a tested floor: `bin/sysscope.js` uses only `require`,
`child_process.spawnSync`, `path`, and `fs`, all stable since well before Node 14. The launcher is exercised
on the current Node LTS. There is no `.nvmrc`; the package has no build toolchain to pin one for.

## Optional tools

Detected at runtime with `have <tool>`, and absent quietly when missing. None is required.

| Tool | Deepens |
|---|---|
| `nvidia-smi` | The only source of `gpu_vram_gb`, and therefore of the VRAM-based AI budget |
| `ollama` | Lists the models already installed |
| `python3` | Detects PyTorch, TensorFlow, Transformers, MLX |
| `system_profiler`, `pmset`, `sysctl` | macOS hardware, battery, and thermal detail (present by default) |
| `lspci`, `rocminfo` / `rocm-smi` | Names an AMD or generic GPU on Linux (never measures its memory) |
| `open` / `xdg-open` | Offers to open the report at the end of an interactive run |

## Published files

`files` is an allowlist — there is no `.npmignore`, and there must never be one.

| Entry | Why it ships |
|---|---|
| `bin/` | The `npx` launcher |
| `audit-bundle.sh` | What the launcher actually runs |
| `audit.sh` | The modular entry point, and the launcher's fallback |
| `lib_core.sh`, `lib_report.sh` | Sourced by `audit.sh` |
| `mod_*.sh` (9 files) | Sourced by `audit.sh` |
| `build.sh` | Lets a consumer regenerate the bundle after editing a module in place |
| `README.md`, `CHANGELOG.md`, `LICENSE` | Release documentation |

Deliberately **not** shipped: `CLAUDE.md`, `AGENTS.md`, `assets/`, `docs/`, `CONTRIBUTING.md`,
`SYSSCOPE_portfolio-info_*.md`, `.pnp.cjs`, `.yarn/`, `yarn.lock`, `.yarnrc.yml`.

Verify what a publish would contain:

```bash
npm pack --dry-run
```

## Scripts

| Script | What it does |
|---|---|
| `build` | `bash build.sh` — regenerates `audit-bundle.sh` from the modules |
| `audit` | `bash audit.sh` — runs the tool from the repository |
| `lint` | `bash -n` on every `*.sh` plus `node --check` on the launcher. The project's only gate |
| `prepack` | Runs `build.sh` before `npm pack` / `npm publish`, so a tarball cannot ship a stale bundle |

## Intentional pins

None. There is nothing to pin.
