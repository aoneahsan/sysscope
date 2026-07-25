#!/usr/bin/env bash
# =============================================================================
# SysScope — mod_storage.sh : disk capacity, free space, biggest items
# Sets globals: DISK_TOTAL_GB DISK_FREE_GB DISK_USED_PCT
# =============================================================================

mod_storage() {
  section "Storage"
  local target line tot used avail cap
  if [ "$SYS_OS" = "macos" ]; then
    target="/System/Volumes/Data"; [ -d "$target" ] || target="/"
  else
    target="/"
  fi

  # -P = POSIX one-line output (avoids wrapped device names); -k = 1024 blocks
  line=$(df -Pk "$target" 2>/dev/null | awk 'NR==2{print $2, $3, $4, $5}')
  tot=$(printf '%s'  "$line" | awk '{print $1}')
  used=$(printf '%s' "$line" | awk '{print $2}')
  avail=$(printf '%s' "$line" | awk '{print $3}')
  cap=$(printf '%s'  "$line" | awk '{print $4}')

  DISK_TOTAL_GB=$(kb_to_gb "${tot:-0}")
  DISK_FREE_GB=$(kb_to_gb "${avail:-0}")
  DISK_USED_PCT=$(printf '%s' "$cap" | tr -d '%')

  field "Volume" "$target"
  field "Total capacity" "${DISK_TOTAL_GB} GB"
  field "Free space" "${DISK_FREE_GB} GB"
  field "Used" "${cap}"

  if [ -n "$DISK_USED_PCT" ]; then
    if   [ "$DISK_USED_PCT" -ge 90 ] 2>/dev/null; then
      status err "Disk is ${DISK_USED_PCT}% full (only ${DISK_FREE_GB} GB free). Reclaim space BEFORE installing new tools/models."
    elif [ "$DISK_USED_PCT" -ge 75 ] 2>/dev/null; then
      status warn "Disk ${DISK_USED_PCT}% full (${DISK_FREE_GB} GB free) — getting tight; plan cleanup soon."
    else
      status ok "Healthy free space (${DISK_FREE_GB} GB free)."
    fi
  fi

  # Deep probe: biggest items in home (slow on large homes; opt-in)
  if [ "$DEEP" = "1" ]; then
    subsection "Largest items in your home folder"
    note "Scanning ~ — this can take a moment…"
    # Folder names in $HOME are personal data — they routinely carry employer,
    # client and project names. Under --share (REDACT=1) the report is presented
    # as safe to post publicly, so the NAME is withheld and only the size, which
    # is the diagnostic signal, is kept.
    [ "$REDACT" = "1" ] && note "Folder names are withheld in share mode; sizes only."
    ( cd "$HOME" 2>/dev/null && du -sh -- * .[!.]* 2>/dev/null | sort -rh | head -10 ) | \
      while IFS= read -r liney; do
        [ -n "$liney" ] || continue
        if [ "$REDACT" = "1" ]; then
          bullet "$(printf '%s' "$liney" | cut -f1)	$(rd "x")"
        else
          bullet "$liney"
        fi
      done
  fi

  j disk_total_gb "$DISK_TOTAL_GB"
  j disk_free_gb "$DISK_FREE_GB"
  j disk_used_pct "$DISK_USED_PCT"
}
