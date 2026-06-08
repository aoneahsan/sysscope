#!/usr/bin/env bash
# =============================================================================
# SysScope — lib_report.sh
# Markdown report + JSON document lifecycle (header/footer, tables).
# Depends on lib_core.sh (r, j, REDACT, REPORT_FILE, JSON_FILE, EMIT_JSON).
# =============================================================================

SYSSCOPE_GIST_URL="${SYSSCOPE_GIST_URL:-https://github.com/aoneahsan/sysscope}"

report_init() {
  [ -n "$REPORT_FILE" ] || return 0
  : > "$REPORT_FILE" 2>/dev/null || { printf 'Cannot write report to %s\n' "$REPORT_FILE" >&2; REPORT_FILE=''; return 1; }
  r "# 🔭 SysScope — System Audit & AI-Readiness Report"
  r ""
  r "_Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')_"
  r ""
  if [ "$REDACT" = "1" ]; then
    r "> 🔒 **Privacy mode on** — serial numbers, UUIDs and hostnames have been redacted so this report is safe to share publicly."
    r ""
  fi
  r "This report was produced by **SysScope**, a portable system-capability auditor."
  r "It summarizes your hardware, installed developer/AI software, and what kinds of"
  r "local AI models and CPU/GPU workloads this machine can realistically run."
  r ""
  r "---"
}

report_finalize() {
  [ -n "$REPORT_FILE" ] || return 0
  r ""
  r "---"
  r ""
  r "### 💬 Feedback & contributions"
  r ""
  r "SysScope is open and meant to improve from real-world machines."
  r "If a value looked wrong on your system, or you want a check added:"
  r ""
  r "- Leave a comment on the gist: $SYSSCOPE_GIST_URL"
  r "- Include your OS, chip, and the line that looked off (no need to share serials)."
  r ""
  r "_Re-run any time with \`./audit.sh\`. Generate a shareable copy with \`./audit.sh --share\`._"
}

# Begin/end a GitHub-Flavored-Markdown table. Header cells passed as args.
table_begin() {
  local header sep c
  header='|'; sep='|'
  for c in "$@"; do header="$header $c |"; sep="$sep --- |"; done
  r "$header"; r "$sep"
}
table_row() {                    # each arg = one cell
  local row c
  row='|'
  for c in "$@"; do row="$row $c |"; done
  r "$row"
}

# JSON lifecycle
json_init() {
  [ "$EMIT_JSON" = "1" ] || return 0
  [ -n "$JSON_FILE" ] || return 0
  : > "$JSON_FILE" 2>/dev/null || { EMIT_JSON=0; return 1; }
  printf '{\n' >> "$JSON_FILE"
  _JSON_FIRST=1
}
json_finalize() {
  [ "$EMIT_JSON" = "1" ] || return 0
  [ -n "$JSON_FILE" ] || return 0
  printf '\n}\n' >> "$JSON_FILE"
}
