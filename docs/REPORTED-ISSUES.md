# Reported issues — sysscope

Open issues only. Fixed entries move to `RESOLVED-ISSUES.md` with the date and the fixing version; nothing is
deleted.

**Last Updated:** 2026-07-25

All five entries below were found on 2026-07-25 during a documentation audit that read every module and
verified each behaviour against the running tool on macOS 26.5.1 / Apple M3 / bash 3.2. All are present in
the published `1.0.1`. None is fixed; each is documented honestly in the README so users are not misled while
they wait.

---

### ISSUE-001 — `--share` does not redact `--deep` output, so a "safe to share" report can leak home-folder names

**Severity:** High — a privacy failure in the feature whose entire purpose is privacy.
**Affected:** `1.0.0`, `1.0.1`. `mod_storage.sh` (the `DEEP` block), `lib_core.sh` (`rd`).
**Reported by:** documentation audit, 2026-07-25.

**Symptom.** A report generated with `--share --deep` carries the privacy banner *"serial numbers, UUIDs and
hostnames have been redacted so this report is safe to share publicly"* and, further down, a plain list of
the ten largest items in the user's home folder — by name.

**Repro.**

```bash
mkdir -p /tmp/demo-home/My-Employer-NDA-Contracts && echo x > /tmp/demo-home/My-Employer-NDA-Contracts/a
HOME=/tmp/demo-home bash audit.sh --quick --deep --yes --share -o out.md
grep 'My-Employer-NDA-Contracts' out.md
```

Observed: the folder name is present in `out.md`.

**Root cause.** `rd()` is the redaction helper and it has exactly two call sites, both in `mod_system.sh`
(hostname, serial number). The deep block in `mod_storage.sh` prints `du` output straight through `bullet`,
never through `rd`. Folder names in a home directory are routinely identifying — employer names, client
names, unreleased project code names.

**Suggested fix.** Either skip the deep probe entirely when `REDACT=1`, or print the sizes with the names
replaced by `rd`. Skipping is the safer default and needs one guard on the existing `[ "$DEEP" = "1" ]`
condition. A note in the report explaining the omission would keep it honest.

---

### ISSUE-002 — The privacy banner and `--help` claim UUIDs are redacted; none is ever collected

**Severity:** Medium — it overstates a privacy guarantee, which is the kind of claim that must be exact.
**Affected:** `1.0.0`, `1.0.1`. `lib_report.sh:18`, `lib_core.sh:12,43`, `audit.sh:64`.
**Reported by:** documentation audit, 2026-07-25.

**Symptom.** `--help` describes `--share` as *"Redact serial numbers, UUIDs and hostname"*, and the report
banner repeats it. SysScope never reads a hardware UUID, a provisioning UDID, or a MAC address, so no UUID is
ever present and none is ever redacted. Verified: `rd` has two call sites and neither handles a UUID.

**Why it matters.** A user who reads "UUIDs are redacted" may reasonably infer the tool collects and then
scrubs them, and may trust the output more broadly than a two-field redaction warrants.

**Suggested fix.** Change both strings to name exactly what is redacted: *"Redact the hostname and serial
number"*. One line in `audit.sh`, one in `lib_report.sh`, then `bash build.sh`.

---

### ISSUE-003 — `--deep` is silently ignored under `--ai-only`

**Severity:** Low — no wrong output, but the flag is accepted and does nothing.
**Affected:** `1.0.0`, `1.0.1`. `audit.sh` (`modules_for_preset`), `mod_storage.sh`.
**Reported by:** documentation audit, 2026-07-25.

**Symptom.** `--ai-only --deep` is accepted, exits `0`, and never runs the deep probe.

**Repro.**

```bash
bash audit.sh --ai-only --deep --yes --no-report | grep -c 'Largest items in your home folder'   # 0
bash audit.sh --quick   --deep --yes --no-report | grep -c 'Largest items in your home folder'   # 1
```

**Root cause.** `DEEP` is read only by `mod_storage`, and the `ai` preset does not include `mod_storage`.
The two options are independent by construction, and nothing tells the user they do not compose.

**Suggested fix.** Print a one-line notice when `DEEP=1` and the selected preset excludes `mod_storage`
("`--deep` has no effect with `--ai-only`"). Rejecting the combination outright would be unhelpfully strict
for scripts that always pass `--deep`.

---

### ISSUE-004 — The report footer says "leave a comment on the gist" while pointing at the GitHub repository

**Severity:** Low — a copy inconsistency in every generated report.
**Affected:** `1.0.0`, `1.0.1`. `lib_report.sh` (`report_finalize`), `audit.sh` (`SYSSCOPE_GIST_URL` default).
**Reported by:** documentation audit, 2026-07-25.

**Symptom.** Every report ends with `- Leave a comment on the gist: https://github.com/aoneahsan/sysscope`.
The default value of `SYSSCOPE_GIST_URL` is the repository, not a gist, so the sentence and the URL disagree.
A reader who follows it lands on a repository and finds no comment box.

**Root cause.** The variable name and its footer copy predate the move to GitHub as the primary home; the
default URL was updated and the wording was not.

**Suggested fix.** Reword to *"Open an issue: <url>"*, and rename `SYSSCOPE_GIST_URL` / `--gist-url` to
`SYSSCOPE_FEEDBACK_URL` / `--feedback-url`. **`--gist-url` must keep working as an alias** — it is a shipped
flag, and removing it would be a breaking change.

---

### ISSUE-005 — No git tags for published releases

**Severity:** Low — tooling and documentation friction.
**Affected:** the repository, not the shipped code. Both `1.0.0` and `1.0.1` are on npm; neither is tagged.
**Reported by:** documentation audit, 2026-07-25.

**Symptom.** `git tag -l` and `git ls-remote --tags` are both empty, so `CHANGELOG.md` cannot carry the
standard Keep-a-Changelog compare links — `.../releases/tag/v1.0.0` and `.../compare/v1.0.0...v1.0.1` both
return **404** (probed 2026-07-25). There is also no way to check out the exact tree a published version was
built from.

**Suggested fix.** Create annotated tags for the two published releases from the commits that bumped their
versions (`1.0.0` → the initial commit `0ba86b9`; `1.0.1` → `2783f57`), push them, and tag every release from
then on. Once tagged, restore the compare links at the bottom of `CHANGELOG.md`.

---

## Notes for whoever fixes these

ISSUE-001 through ISSUE-004 all touch shell sources, so each fix must be followed by `bash build.sh` to
regenerate `audit-bundle.sh` — the file `npx` actually runs. A fix that lands in a module but not in the
bundle changes nothing for users. Gate with `npm run lint`, then bump the version and add a `CHANGELOG.md`
entry.
