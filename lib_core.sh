#!/usr/bin/env bash
# =============================================================================
# SysScope — lib_core.sh
# Core library: output formatting, OS/arch detection, prompts, small helpers.
# bash 3.2+ compatible (no associative arrays, no ${var,,}).
# This file only DEFINES functions/vars; it runs nothing on its own.
# =============================================================================

# ---- Global config defaults (audit.sh may override before calling) ---------
: "${USE_COLOR:=1}"        # 1=color when on a TTY, 0=never
: "${INTERACTIVE:=0}"      # 1=ask questions, 0=use defaults
: "${REDACT:=0}"           # 1=hide serials/UUIDs/hostnames for sharing
: "${REPORT_FILE:=}"       # markdown report path ("" = none)
: "${JSON_FILE:=}"         # json output path ("" = none)
: "${EMIT_JSON:=0}"        # 1=write JSON
: "${DEEP:=0}"             # 1=run slower deep probes (e.g. du of home)
: "${_JSON_FIRST:=1}"      # internal: comma tracking for JSON

# ---- Colors -----------------------------------------------------------------
setup_colors() {
  if [ "$USE_COLOR" = "1" ] && [ -t 1 ]; then
    RST=$'\033[0m';  BOLD=$'\033[1m'; DIM=$'\033[2m'
    RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'
    BLU=$'\033[34m'; MAG=$'\033[35m'; CYN=$'\033[36m'
  else
    RST=''; BOLD=''; DIM=''; RED=''; GRN=''; YLW=''; BLU=''; MAG=''; CYN=''
  fi
}

# ---- Small helpers ----------------------------------------------------------
have()  { command -v "$1" >/dev/null 2>&1; }
lc()    { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
trim()  { printf '%s' "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }

os_type() {
  case "$(uname -s 2>/dev/null)" in
    Darwin) printf 'macos' ;;
    Linux)  printf 'linux' ;;
    *)      printf 'other' ;;
  esac
}

# Redact a value when REDACT=1 (used for serials, UUIDs, hostnames, user paths)
rd() {
  if [ "$REDACT" = "1" ] && [ -n "$1" ]; then printf '‹redacted›'; else printf '%s' "$1"; fi
}

# bytes -> "12.3 GB"
bytes_to_gb() { awk -v b="${1:-0}" 'BEGIN{printf "%.1f", b/1073741824}'; }
# 1K-blocks -> integer GB
kb_to_gb()    { awk -v k="${1:-0}" 'BEGIN{printf "%.0f", k/1048576}'; }

# ---- Report sink (append a raw line to the markdown report) -----------------
r() { [ -n "$REPORT_FILE" ] && printf '%s\n' "$1" >> "$REPORT_FILE"; return 0; }

# ---- JSON sink (scalar key/values only) -------------------------------------
j() {
  [ "$EMIT_JSON" = "1" ] || return 0
  [ -n "$JSON_FILE" ] || return 0
  local k v
  k="$1"; v="$2"
  v=$(printf '%s' "$v" | sed 's/\\/\\\\/g; s/"/\\"/g')
  if [ "$_JSON_FIRST" = "1" ]; then _JSON_FIRST=0; else printf ',\n' >> "$JSON_FILE"; fi
  printf '  "%s": "%s"' "$k" "$v" >> "$JSON_FILE"
}

# ---- Pretty output (terminal) + mirrored markdown (report) ------------------
section() {                      # H2 / major section
  printf '\n%s%s== %s ==%s\n' "$BOLD" "$CYN" "$1" "$RST"
  r ""; r "## $1"; r ""
}
subsection() {                   # H3 / minor heading
  printf '\n%s  %s%s\n' "$BOLD" "$1" "$RST"
  r ""; r "### $1"; r ""
}
field() {                        # key/value: terminal + "- **key:** value"
  printf '  %s%-22s%s %s\n' "$BOLD" "$1" "$RST" "$2"
  r "- **$1:** $2"
}
bullet() {                       # list item
  printf '    %s-%s %s\n' "$DIM" "$RST" "$1"
  r "- $1"
}
note() {                         # dim aside / blockquote
  printf '  %s%s%s\n' "$DIM" "$1" "$RST"
  r ""; r "> $1"; r ""
}
status() {                       # level in {ok,warn,err,info}
  local lvl icon col rep
  lvl="$1"
  case "$lvl" in
    ok)   icon='OK '; col="$GRN"; rep='✅' ;;
    warn) icon='!! '; col="$YLW"; rep='⚠️' ;;
    err)  icon='XX '; col="$RED"; rep='🟥' ;;
    info) icon='.. '; col="$BLU"; rep='ℹ️' ;;
    *)    icon='-- '; col="$RST"; rep='' ;;
  esac
  printf '  %s[%s]%s %s\n' "$col" "$icon" "$RST" "$2"
  r "- $rep $2"
}
hr() { printf '%s%s%s\n' "$DIM" "------------------------------------------------------------" "$RST"; }

# ---- Interactive prompts (read from /dev/tty so redirected stdout is OK) ----
ask_yn() {                       # ask_yn "Question?" [y|n]  -> exit 0 = yes
  local q def hint ans
  q="$1"; def="${2:-y}"
  if [ "$INTERACTIVE" != "1" ]; then [ "$def" = "y" ]; return; fi
  hint='[Y/n]'; [ "$def" = "n" ] && hint='[y/N]'
  printf '%s? %s %s%s ' "$CYN" "$q" "$hint" "$RST" > /dev/tty
  read -r ans < /dev/tty || ans=''
  ans=$(lc "$ans"); [ -z "$ans" ] && ans="$def"
  [ "$ans" = "y" ] || [ "$ans" = "yes" ]
}
ask_str() {                      # ask_str "Prompt" "default" -> echoes value
  local q def ans
  q="$1"; def="$2"
  if [ "$INTERACTIVE" != "1" ]; then printf '%s' "$def"; return; fi
  printf '%s> %s%s [%s]: ' "$CYN" "$q" "$RST" "$def" > /dev/tty
  read -r ans < /dev/tty || ans=''
  [ -z "$ans" ] && ans="$def"
  printf '%s' "$ans"
}
ask_menu() {                     # ask_menu "Title" "opt1" "opt2" ... -> echoes chosen index (1-based)
  local title n i choice
  title="$1"; shift
  if [ "$INTERACTIVE" != "1" ]; then printf '1'; return; fi
  printf '\n%s%s%s\n' "$BOLD" "$title" "$RST" > /dev/tty
  i=1
  for o in "$@"; do printf '   %s%d)%s %s\n' "$CYN" "$i" "$RST" "$o" > /dev/tty; i=$((i+1)); done
  n=$#
  printf '%sChoose [1-%d] (default 1): %s' "$CYN" "$n" "$RST" > /dev/tty
  read -r choice < /dev/tty || choice=''
  case "$choice" in (''|*[!0-9]*) choice=1 ;; esac
  [ "$choice" -ge 1 ] 2>/dev/null && [ "$choice" -le "$n" ] 2>/dev/null || choice=1
  printf '%s' "$choice"
}
