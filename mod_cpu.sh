#!/usr/bin/env bash
# =============================================================================
# SysScope — mod_cpu.sh : processor topology
# Sets globals: CPU_BRAND CPU_PHYS CPU_LOGICAL CPU_P CPU_E
# =============================================================================

mod_cpu() {
  section "CPU"
  CPU_BRAND=""; CPU_PHYS=""; CPU_LOGICAL=""; CPU_P=""; CPU_E=""

  if [ "$SYS_OS" = "macos" ]; then
    CPU_BRAND=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
    CPU_PHYS=$(sysctl -n hw.physicalcpu 2>/dev/null)
    CPU_LOGICAL=$(sysctl -n hw.logicalcpu 2>/dev/null)
    CPU_P=$(sysctl -n hw.perflevel0.physicalcpu 2>/dev/null)
    CPU_E=$(sysctl -n hw.perflevel1.physicalcpu 2>/dev/null)
  elif [ "$SYS_OS" = "linux" ]; then
    CPU_BRAND=$(awk -F': ' '/model name/{print $2; exit}' /proc/cpuinfo 2>/dev/null)
    CPU_LOGICAL=$(nproc 2>/dev/null)
    CPU_PHYS=$(awk -F': ' '/^cpu cores/{print $2; exit}' /proc/cpuinfo 2>/dev/null)
  fi

  [ -n "$CPU_BRAND" ]   && field "Processor" "$CPU_BRAND"
  [ -n "$CPU_PHYS" ]    && field "Physical cores" "$CPU_PHYS"
  [ -n "$CPU_LOGICAL" ] && field "Logical cores" "$CPU_LOGICAL"
  if [ -n "$CPU_P" ] && [ -n "$CPU_E" ] && [ "${CPU_P:-0}" -gt 0 ] 2>/dev/null; then
    field "Core layout" "$CPU_P performance + $CPU_E efficiency"
    bullet "Performance cores handle foreground builds/inference; efficiency cores absorb background work."
  fi

  j cpu_brand "$CPU_BRAND"
  j cpu_logical "${CPU_LOGICAL:-}"
  j cpu_physical "${CPU_PHYS:-}"
}
