#!/usr/bin/env bash
# =============================================================================
# SysScope — mod_memory.sh : RAM, swap, memory pressure
# Sets globals: MEM_TOTAL_GB (int) MEM_BYTES MEM_FREE_PCT SWAP_USED
# =============================================================================

mod_memory() {
  section "Memory (RAM)"
  MEM_BYTES=0; MEM_FREE_PCT=""; SWAP_USED=""

  if [ "$SYS_OS" = "macos" ]; then
    MEM_BYTES=$(sysctl -n hw.memsize 2>/dev/null)
    SWAP_USED=$(sysctl -n vm.swapusage 2>/dev/null | sed -n 's/.*used = \([0-9.]*[A-Za-z]*\).*/\1/p')
    MEM_FREE_PCT=$(memory_pressure 2>/dev/null | awk -F': ' '/free percentage/{gsub(/%/,"",$2); print $2; exit}')
  elif [ "$SYS_OS" = "linux" ]; then
    MEM_BYTES=$(awk '/MemTotal/{print $2*1024; exit}' /proc/meminfo 2>/dev/null)
    local avail tot
    avail=$(awk '/MemAvailable/{print $2; exit}' /proc/meminfo 2>/dev/null)
    tot=$(awk '/MemTotal/{print $2; exit}' /proc/meminfo 2>/dev/null)
    [ -n "$avail" ] && [ -n "$tot" ] && MEM_FREE_PCT=$(awk -v a="$avail" -v t="$tot" 'BEGIN{printf "%.0f", a/t*100}')
    SWAP_USED=$(awk '/SwapTotal/{t=$2} /SwapFree/{f=$2} END{printf "%.0f MB", (t-f)/1024}' /proc/meminfo 2>/dev/null)
  fi

  MEM_TOTAL_GB=$(awk -v b="${MEM_BYTES:-0}" 'BEGIN{printf "%.0f", b/1073741824}')
  field "Total RAM" "${MEM_TOTAL_GB} GB"
  [ -n "$MEM_FREE_PCT" ] && field "Free (approx)" "${MEM_FREE_PCT}%"
  [ -n "$SWAP_USED" ]    && field "Swap in use" "$SWAP_USED"

  # RAM class verdict
  if   [ "${MEM_TOTAL_GB:-0}" -ge 32 ] 2>/dev/null; then status ok   "Plenty of RAM — comfortable for parallel heavy workloads and larger local models."
  elif [ "${MEM_TOTAL_GB:-0}" -ge 16 ] 2>/dev/null; then status ok   "Solid RAM — great for dev; run ONE very-heavy workload (big model / VM / emulator) at a time."
  elif [ "${MEM_TOTAL_GB:-0}" -ge 8  ] 2>/dev/null; then status warn "Limited RAM — fine for light dev and 3–8B models; avoid stacking heavy apps."
  else status err "Low RAM — only small models (1–3B) and light tasks will run smoothly."
  fi

  # swap pressure hint (macOS value has a unit suffix)
  case "$SWAP_USED" in
    0.00M|0M|0\ MB|"") : ;;
    *) note "Some swap is in use — the system is spilling RAM to disk. Close apps before launching a model/VM." ;;
  esac

  j ram_gb "$MEM_TOTAL_GB"
}
