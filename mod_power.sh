#!/usr/bin/env bash
# =============================================================================
# SysScope — mod_power.sh : battery health, charge, thermal throttling
# Sets globals: PWR_PCT PWR_SRC PWR_ONBATT
# =============================================================================

mod_power() {
  PWR_PCT=""; PWR_SRC=""; PWR_ONBATT=0

  if [ "$SYS_OS" = "macos" ]; then
    section "Power, Battery & Thermals"
    local batt
    batt=$(pmset -g batt 2>/dev/null)
    if printf '%s' "$batt" | grep -q "InternalBattery"; then
      PWR_PCT=$(printf '%s' "$batt" | sed -n 's/.*[^0-9]\([0-9][0-9]*\)%.*/\1/p' | head -1)
      PWR_SRC=$(printf '%s' "$batt" | awk -F"'" '/Now drawing/{print $2; exit}')
      printf '%s' "$PWR_SRC" | grep -qi "battery" && PWR_ONBATT=1
      local health cycles cond
      health=$(system_profiler SPPowerDataType 2>/dev/null | awk -F': ' '/Maximum Capacity/{print $2; exit}')
      cycles=$(system_profiler SPPowerDataType 2>/dev/null | awk -F': ' '/Cycle Count/{print $2; exit}')
      cond=$(system_profiler SPPowerDataType 2>/dev/null | awk -F': ' '/Condition/{print $2; exit}')
      field "Power source" "${PWR_SRC:-unknown}"
      field "Charge" "${PWR_PCT}%"
      [ -n "$health" ] && field "Battery max capacity" "$health"
      [ -n "$cycles" ] && field "Cycle count" "$cycles"
      [ -n "$cond" ]   && field "Battery condition" "$cond"
      if [ -n "$PWR_PCT" ] && [ "$PWR_ONBATT" = "1" ] && [ "$PWR_PCT" -le 20 ] 2>/dev/null; then
        status warn "Battery low (${PWR_PCT}%) and running on battery — plug in before heavy/sustained workloads."
      fi
    else
      field "Power" "AC / desktop (no internal battery)"
    fi

    # Thermal / CPU speed limit
    local lim
    lim=$(pmset -g therm 2>/dev/null | sed -n 's/.*CPU_Speed_Limit *= *\([0-9]*\).*/\1/p' | head -1)
    if [ -n "$lim" ] && [ "$lim" != "100" ] 2>/dev/null; then
      status warn "CPU speed currently limited to ${lim}% (thermal or power throttling active)."
    fi

    # Fanless note for MacBook Air
    if printf '%s' "$SYS_MODELNAME" | grep -qi "MacBook Air"; then
      status info "This is a fanless MacBook Air — sustained heavy loads (long builds, long inference, video encodes) will thermally throttle. Keep it on AC and well-ventilated."
    fi

  elif [ "$SYS_OS" = "linux" ]; then
    if [ -r /sys/class/power_supply/BAT0/capacity ]; then
      section "Power & Battery"
      PWR_PCT=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
      local stat
      stat=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
      field "Charge" "${PWR_PCT}%"
      [ -n "$stat" ] && field "Status" "$stat"
    fi
  fi

  j battery_pct "${PWR_PCT:-}"
}
