#!/usr/bin/env bash
# =============================================================================
# SysScope — mod_system.sh : system identity (OS, model, chip, kernel)
# Sets globals: SYS_OS SYS_ARCH SYS_OSNAME SYS_OSVER SYS_MODELNAME SYS_MODELID
#               SYS_CHIP SYS_SERIAL SYS_HOST
# =============================================================================

mod_system() {
  section "System Identity"
  SYS_OS=$(os_type)
  SYS_ARCH=$(uname -m 2>/dev/null)
  local build kernel
  kernel=$(uname -sr 2>/dev/null)
  SYS_HOST=$(hostname 2>/dev/null)

  if [ "$SYS_OS" = "macos" ]; then
    SYS_OSNAME="macOS"
    SYS_OSVER=$(sw_vers -productVersion 2>/dev/null)
    build=$(sw_vers -buildVersion 2>/dev/null)
    SYS_MODELID=$(sysctl -n hw.model 2>/dev/null)
    SYS_MODELNAME=$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Model Name/{print $2; exit}')
    SYS_CHIP=$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Chip/{print $2; exit}')
    [ -z "$SYS_CHIP" ] && SYS_CHIP=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
    SYS_SERIAL=$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Serial Number/{print $2; exit}')
  elif [ "$SYS_OS" = "linux" ]; then
    SYS_OSNAME=$( ( . /etc/os-release 2>/dev/null; printf '%s' "$PRETTY_NAME" ) )
    [ -z "$SYS_OSNAME" ] && SYS_OSNAME="Linux"
    SYS_OSVER=$(uname -r 2>/dev/null)
    SYS_MODELNAME=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null)
    SYS_MODELID=$(cat /sys/devices/virtual/dmi/id/product_version 2>/dev/null)
    SYS_CHIP=$(awk -F': ' '/model name/{print $2; exit}' /proc/cpuinfo 2>/dev/null)
    SYS_SERIAL=""
  else
    SYS_OSNAME=$(uname -s 2>/dev/null); SYS_OSVER=$(uname -r 2>/dev/null)
    SYS_MODELNAME=""; SYS_MODELID=""; SYS_CHIP=""; SYS_SERIAL=""
  fi

  field "Operating system" "$SYS_OSNAME $SYS_OSVER"
  [ -n "$build" ] && field "Build" "$build"
  field "Kernel" "$kernel"
  field "Architecture" "$SYS_ARCH"
  if [ -n "$SYS_MODELNAME" ]; then
    if [ -n "$SYS_MODELID" ]; then field "Model" "$SYS_MODELNAME ($SYS_MODELID)"; else field "Model" "$SYS_MODELNAME"; fi
  fi
  [ -n "$SYS_CHIP" ] && field "Chip / CPU" "$SYS_CHIP"
  field "Hostname" "$(rd "$SYS_HOST")"
  [ -n "$SYS_SERIAL" ] && field "Serial number" "$(rd "$SYS_SERIAL")"

  case "$SYS_ARCH" in
    arm64|aarch64) status info "ARM (Apple Silicon / aarch64) — note: virtualization runs ARM guest OSes only." ;;
  esac

  j os "$SYS_OSNAME $SYS_OSVER"
  j arch "$SYS_ARCH"
  j model "$SYS_MODELNAME"
  j chip "$SYS_CHIP"
}
