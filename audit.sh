#!/usr/bin/env bash
# =============================================================================
#  🔭 SysScope — System Capability & AI-Readiness Audit
#  Portable, modular, read-only auditor for macOS (Linux best-effort).
#  Repo: https://github.com/aoneahsan/sysscope   ·   License: MIT
#  Run without install:  npx sysscope   (or latest from source: npx github:aoneahsan/sysscope)
#
#  Usage:   ./audit.sh [options]
#  Quick:   ./audit.sh --quick
#  Share:   ./audit.sh --share          (redacts serials/hostname)
#  Help:    ./audit.sh --help
# =============================================================================

SYSSCOPE_VERSION="1.0.4"

# ---- Locate & load modules (this block is stripped in the bundled build) ----
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
# >>> SYSSCOPE_SOURCE_START
_SS_MODULES="lib_core lib_report mod_system mod_cpu mod_memory mod_gpu mod_storage mod_power mod_software mod_ai mod_recommend"
for _m in $_SS_MODULES; do
  if [ -f "$SCRIPT_DIR/$_m.sh" ]; then
    # shellcheck disable=SC1090
    . "$SCRIPT_DIR/$_m.sh"
  else
    printf 'SysScope error: missing module "%s.sh" in %s\n' "$_m" "$SCRIPT_DIR" >&2
    printf 'Run from the folder containing all sysscope files, or use the bundled audit-bundle.sh.\n' >&2
    exit 1
  fi
done
# >>> SYSSCOPE_SOURCE_END

# ---- Defaults ---------------------------------------------------------------
PRESET=""                 # full|quick|ai  ("" => ask if interactive, else full)
USE_COLOR=1
REDACT=0
DEEP=0
EMIT_JSON=0
JSON_FILE=""
WANT_REPORT=1
FORCE_NONINTERACTIVE=0
REPORT_FILE=""
SYSSCOPE_GIST_URL="https://github.com/aoneahsan/sysscope"

usage() {
  cat <<EOF
🔭 SysScope v$SYSSCOPE_VERSION — System Capability & AI-Readiness Audit

USAGE:
  ./audit.sh [options]

PRESETS:
  -f, --full         Full audit (default): hardware + software + AI + advice
  -q, --quick        Faster: skips software inventory & deep disk scan
  -a, --ai-only      Just the local-AI / LLM capability assessment

OUTPUT:
  -o, --output FILE  Write the markdown report to FILE
                     (default: ./sysscope-report-YYYYMMDD-HHMMSS.md)
      --no-report    Terminal only; don't write a file
      --json [FILE]  Also emit machine-readable JSON of key metrics
      --deep         Include slow probes (largest items in home folder)

PRIVACY:
      --share        Redact serial numbers, UUIDs and hostname (safe to post)
      --redact       Alias for --share

BEHAVIOR:
  -y, --yes          Non-interactive: accept defaults, ask nothing
      --no-color     Disable ANSI colors
      --gist-url URL Set the feedback URL printed in the report
  -V, --version      Print version and exit
  -h, --help         Show this help and exit

EXAMPLES:
  ./audit.sh                       # interactive, full audit, saves a report
  ./audit.sh --quick --yes         # fast, unattended
  ./audit.sh --ai-only             # "what models can I run?"
  ./audit.sh --share -o report.md  # redacted, shareable report
  ./audit.sh --json metrics.json   # full audit + JSON metrics

SysScope is read-only: it inspects, it never changes your system.
EOF
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -f|--full)    PRESET="full" ;;
      -q|--quick)   PRESET="quick" ;;
      -a|--ai-only) PRESET="ai" ;;
      -o|--output)  shift; REPORT_FILE="$1" ;;
      --no-report)  WANT_REPORT=0 ;;
      --json)
        EMIT_JSON=1
        case "$2" in -*|"") : ;; *) JSON_FILE="$2"; shift ;; esac
        ;;
      --deep)       DEEP=1 ;;
      --share|--redact) REDACT=1 ;;
      -y|--yes|--non-interactive) FORCE_NONINTERACTIVE=1 ;;
      --no-color)   USE_COLOR=0 ;;
      --gist-url)   shift; SYSSCOPE_GIST_URL="$1" ;;
      -V|--version) printf 'SysScope %s\n' "$SYSSCOPE_VERSION"; exit 0 ;;
      -h|--help)    usage; exit 0 ;;
      *) printf 'Unknown option: %s (try --help)\n' "$1" >&2; exit 2 ;;
    esac
    shift
  done
}

banner() {
  [ "$USE_COLOR" = "1" ] && [ -t 1 ] || { printf 'SysScope v%s — system capability & AI-readiness audit\n' "$SYSSCOPE_VERSION"; return; }
  printf '%s%s' "$BOLD" "$CYN"
  printf '  ┌─────────────────────────────────────────────┐\n'
  printf '  │   🔭  S Y S S C O P E   v%-7s            │\n' "$SYSSCOPE_VERSION"
  printf '  │   System Capability & AI-Readiness Audit    │\n'
  printf '  └─────────────────────────────────────────────┘%s\n' "$RST"
}

modules_for_preset() {
  case "$1" in
    ai)    printf 'mod_system mod_cpu mod_memory mod_gpu mod_ai mod_recommend' ;;
    quick) printf 'mod_system mod_cpu mod_memory mod_gpu mod_storage mod_power mod_ai mod_recommend' ;;
    *)     printf 'mod_system mod_cpu mod_memory mod_gpu mod_storage mod_power mod_software mod_ai mod_recommend' ;;
  esac
}

main() {
  parse_args "$@"

  # Interactivity: only when both ends are a TTY and not forced off.
  if [ "$FORCE_NONINTERACTIVE" != "1" ] && [ -t 0 ] && [ -t 1 ]; then INTERACTIVE=1; else INTERACTIVE=0; fi

  setup_colors
  banner

  # Interactive choices (only when nothing explicit was requested)
  if [ "$INTERACTIVE" = "1" ] && [ -z "$PRESET" ]; then
    sel=$(ask_menu "What would you like to run?" \
      "Full audit (recommended)" \
      "Quick audit (faster)" \
      "AI-only — what models can I run?")
    case "$sel" in 1) PRESET="full";; 2) PRESET="quick";; 3) PRESET="ai";; esac
  fi
  [ -z "$PRESET" ] && PRESET="full"

  # Report path
  if [ "$WANT_REPORT" = "1" ]; then
    if [ -z "$REPORT_FILE" ]; then
      default_report="./sysscope-report-$(date +%Y%m%d-%H%M%S).md"
      REPORT_FILE=$(ask_str "Save report to" "$default_report")
    fi
  else
    REPORT_FILE=""
  fi

  # Redaction prompt (interactive only, if not already set)
  if [ "$INTERACTIVE" = "1" ] && [ "$REDACT" = "0" ]; then
    if ask_yn "Redact serials/hostname so the report is safe to share publicly" "n"; then REDACT=1; fi
  fi

  # JSON default path
  if [ "$EMIT_JSON" = "1" ] && [ -z "$JSON_FILE" ]; then
    if [ -n "$REPORT_FILE" ]; then JSON_FILE="${REPORT_FILE%.md}.json"; else JSON_FILE="./sysscope-metrics.json"; fi
  fi

  # Go
  report_init
  json_init
  run_list=$(modules_for_preset "$PRESET")
  for fn in $run_list; do
    "$fn"
  done
  report_finalize
  json_finalize

  # Summary
  printf '\n'; hr
  if [ -n "$REPORT_FILE" ] && [ -f "$REPORT_FILE" ]; then
    printf '%s✓%s Markdown report saved: %s%s%s\n' "$GRN" "$RST" "$BOLD" "$REPORT_FILE" "$RST"
  fi
  if [ "$EMIT_JSON" = "1" ] && [ -n "$JSON_FILE" ] && [ -f "$JSON_FILE" ]; then
    printf '%s✓%s JSON metrics saved:    %s%s%s\n' "$GRN" "$RST" "$BOLD" "$JSON_FILE" "$RST"
  fi
  printf '%sFeedback / improvements:%s %s\n' "$DIM" "$RST" "$SYSSCOPE_GIST_URL"

  # Offer to open the report
  if [ "$INTERACTIVE" = "1" ] && [ -n "$REPORT_FILE" ] && [ -f "$REPORT_FILE" ]; then
    if [ "$SYS_OS" = "macos" ] && have open; then
      ask_yn "Open the report now" "n" && open "$REPORT_FILE"
    elif [ "$SYS_OS" = "linux" ] && have xdg-open; then
      ask_yn "Open the report now" "n" && xdg-open "$REPORT_FILE" >/dev/null 2>&1
    fi
  fi
}

main "$@"
