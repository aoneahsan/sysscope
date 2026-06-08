#!/usr/bin/env bash
# =============================================================================
# SysScope — mod_gpu.sh : GPU, unified vs discrete memory, accelerators
# Sets globals: GPU_NAME GPU_CORES GPU_VRAM_GB IS_UNIFIED
# =============================================================================

mod_gpu() {
  section "Graphics (GPU) & Accelerators"
  GPU_NAME=""; GPU_CORES=""; GPU_VRAM_GB="0"; IS_UNIFIED=0

  if [ "$SYS_OS" = "macos" ]; then
    GPU_NAME=$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F': ' '/Chipset Model/{print $2; exit}')
    GPU_CORES=$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F': ' '/Total Number of Cores/{print $2; exit}')
    local metal
    metal=$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F': ' '/Metal/{print $2; exit}')
    case "$SYS_ARCH" in arm64|aarch64) IS_UNIFIED=1 ;; esac

    [ -n "$GPU_NAME" ]  && field "GPU" "$GPU_NAME"
    [ -n "$GPU_CORES" ] && field "GPU cores" "$GPU_CORES"
    [ -n "$metal" ]     && field "Graphics API" "Metal ($metal)"

    if [ "$IS_UNIFIED" = "1" ]; then
      field "Memory model" "Unified — GPU shares the ${MEM_TOTAL_GB:-?} GB system RAM"
      status info "Apple Silicon: local LLMs run on the GPU via Metal. The Neural Engine (Core ML) is NOT used by Ollama/llama.cpp."
      bullet "There is no separate VRAM — the model lives in your single RAM pool, which is why total RAM is the AI ceiling."
    fi

  elif [ "$SYS_OS" = "linux" ]; then
    if have nvidia-smi; then
      GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
      local vram
      vram=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
      [ -n "$vram" ] && GPU_VRAM_GB=$(awk -v m="$vram" 'BEGIN{printf "%.1f", m/1024}')
      [ -n "$GPU_NAME" ] && field "GPU" "$GPU_NAME (NVIDIA)"
      [ "$GPU_VRAM_GB" != "0" ] && field "VRAM" "${GPU_VRAM_GB} GB"
      status ok "Discrete NVIDIA GPU — VRAM is the limiter for fast local inference."
    elif have rocminfo || have rocm-smi; then
      GPU_NAME=$(lspci 2>/dev/null | grep -iE 'vga|3d|display' | sed 's/.*: //' | head -1)
      field "GPU" "${GPU_NAME:-AMD ROCm device}"
      status info "AMD GPU detected — ROCm-capable runtimes can use it (setup varies)."
    else
      GPU_NAME=$(lspci 2>/dev/null | grep -iE 'vga|3d|display' | sed 's/.*: //' | head -1)
      field "GPU" "${GPU_NAME:-unknown (install nvidia-smi/lspci for detail)}"
      status info "No discrete-GPU VRAM detected — local models would run on CPU (much slower)."
    fi
  fi

  j gpu "${GPU_NAME:-}"
  j gpu_cores "${GPU_CORES:-}"
  j gpu_vram_gb "${GPU_VRAM_GB:-0}"
  j unified_memory "$IS_UNIFIED"
}
