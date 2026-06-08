#!/usr/bin/env bash
# =============================================================================
# SysScope — mod_recommend.sh : health scorecard + workload guidance
# Reads globals set by earlier modules.
# =============================================================================

mod_recommend() {
  section "Health Scorecard & Recommendations"

  subsection "Health scorecard"
  printf '  %s%-16s %-8s %s%s\n' "$BOLD" "AREA" "RATING" "NOTE" "$RST"
  table_begin "Area" "Rating" "Note"

  # --- Disk ---
  local d_rate d_note
  if   [ "${DISK_USED_PCT:-0}" -ge 90 ] 2>/dev/null; then d_rate="🟥 critical"; d_note="Only ${DISK_FREE_GB} GB free — reclaim space before installing tools/models."
  elif [ "${DISK_USED_PCT:-0}" -ge 75 ] 2>/dev/null; then d_rate="🟡 tight";    d_note="${DISK_FREE_GB} GB free — plan cleanup."
  else d_rate="🟢 good"; d_note="${DISK_FREE_GB} GB free."
  fi
  printf '  %-16s %-8s %s\n' "Disk" "$d_rate" "$d_note"; table_row "Disk" "$d_rate" "$d_note"

  # --- Memory ---
  local m_rate m_note
  if   [ "${MEM_TOTAL_GB:-0}" -ge 32 ] 2>/dev/null; then m_rate="🟢 great"; m_note="${MEM_TOTAL_GB} GB — multitask heavy workloads."
  elif [ "${MEM_TOTAL_GB:-0}" -ge 16 ] 2>/dev/null; then m_rate="🟢 good";  m_note="${MEM_TOTAL_GB} GB — one very-heavy workload at a time."
  elif [ "${MEM_TOTAL_GB:-0}" -ge 8  ] 2>/dev/null; then m_rate="🟡 limited"; m_note="${MEM_TOTAL_GB} GB — light dev + small models."
  else m_rate="🟥 low"; m_note="${MEM_TOTAL_GB} GB — small tasks only."
  fi
  printf '  %-16s %-8s %s\n' "Memory" "$m_rate" "$m_note"; table_row "Memory" "$m_rate" "$m_note"

  # --- Local AI ---
  local a_note="${AI_TIER:-unknown} (~${AI_BUDGET_GB:-?} GB budget)"
  printf '  %-16s %-8s %s\n' "Local AI" "🔭" "$a_note"; table_row "Local AI" "ℹ️" "$a_note"

  # --- Battery (if laptop) ---
  if [ -n "${PWR_PCT:-}" ]; then
    local b_rate="🟢 ok"
    [ "${PWR_ONBATT:-0}" = "1" ] && [ "${PWR_PCT:-100}" -le 20 ] 2>/dev/null && b_rate="🟡 low"
    printf '  %-16s %-8s %s\n' "Battery" "$b_rate" "${PWR_PCT}% (${PWR_SRC:-?})"
    table_row "Battery" "$b_rate" "${PWR_PCT}% (${PWR_SRC:-?})"
  fi

  # --- Concurrency guidance keyed off RAM ---
  subsection "What you can run — and how to combine it"
  if [ "${MEM_TOTAL_GB:-0}" -ge 32 ] 2>/dev/null; then
    bullet "You can comfortably run a local model + a container stack + an editor together."
    bullet "A VM or emulator alongside a 7–8B model is fine."
  elif [ "${MEM_TOTAL_GB:-0}" -ge 16 ] 2>/dev/null; then
    bullet "Golden rule: run ONE very-heavy workload at a time (big model OR VM OR mobile emulator), surrounded by light tools."
    bullet "🟢 Fine together: editor + dev server + 1 browser + a 7–8B model (≈12 GB)."
    bullet "🟢 Fine together: editor + 1 mobile emulator + 1 browser."
    bullet "🔴 Avoid: VM (≈8 GB) + 7B model; or Android + iOS emulators + a model at once."
    bullet "Cap Docker/OrbStack RAM to 3–4 GB; suspend VMs when idle; prefer real devices over emulators."
  elif [ "${MEM_TOTAL_GB:-0}" -ge 8 ] 2>/dev/null; then
    bullet "Stick to one heavy thing: a 3–7B model OR a light VM OR one emulator — not combinations."
    bullet "Keep browser tabs minimal; close apps before launching a model."
  else
    bullet "Run a single lightweight task at a time; 1–3B models only; avoid VMs/emulators."
  fi

  # --- Arch-specific virtualization note ---
  case "$SYS_ARCH" in
    arm64|aarch64) bullet "Virtualization is ARM-only here: run Windows 11 ARM / ARM Linux guests (x86 ISOs won't boot).";;
  esac

  # --- Top actions, prioritized ---
  subsection "Top next actions"
  local n=1
  if [ "${DISK_USED_PCT:-0}" -ge 85 ] 2>/dev/null; then
    bullet "$n. 🟥 Free disk space first (Downloads, caches, old VM snapshots, build dirs)."; n=$((n+1))
  fi
  if ! have brew && [ "$SYS_OS" = "macos" ]; then
    bullet "$n. Install Homebrew (package manager) — most tools below install through it."; n=$((n+1))
  fi
  if ! have ollama; then
    bullet "$n. Install Ollama and pull a starter model (see Local AI section above)."; n=$((n+1))
  fi
  if ! have docker && ! have orb; then
    bullet "$n. For containers, install OrbStack (lighter than Docker Desktop on laptops) and cap its RAM."; n=$((n+1))
  fi
  if have node && ! have pnpm; then
    bullet "$n. Many JS projects? Enable pnpm (\`corepack enable\`) — one shared package store saves lots of disk."; n=$((n+1))
  fi
  bullet "$n. Keep the machine on AC power for heavy or sustained sessions."
}
