#!/usr/bin/env bash
# =============================================================================
# SysScope — mod_software.sh : developer & AI toolchain inventory
# =============================================================================

# sw_check <command> <label> <version-cmd-or-empty>
sw_check() {
  local cmd label vcmd ver
  cmd="$1"; label="$2"; vcmd="$3"
  if have "$cmd"; then
    if [ -n "$vcmd" ]; then
      ver=$($vcmd 2>&1 | head -1)
      ver=$(trim "$ver")
      status ok "$label — ${ver:-installed}"
    else
      status ok "$label — installed"
    fi
  else
    status info "$label — not installed"
  fi
}

# ls_app <AppName> (macOS .app presence)
ls_app() {
  [ "$SYS_OS" = "macos" ] || return 0
  local app="$1"
  if [ -d "/Applications/$app.app" ] || [ -d "$HOME/Applications/$app.app" ]; then
    status ok "$app — installed"
  else
    status info "$app — not installed"
  fi
}

# py_pkg <module> <label>  (report only if present)
py_pkg() {
  local mod label ver
  mod="$1"; label="$2"
  have python3 || return 0
  ver=$(python3 - "$mod" <<'PYEOF' 2>/dev/null
import importlib, sys
try:
    m = importlib.import_module(sys.argv[1])
    sys.stdout.write(getattr(m, "__version__", "installed"))
except Exception:
    pass
PYEOF
)
  [ -n "$ver" ] && status ok "$label (Python) — $ver"
}

mod_software() {
  section "Developer & AI Software"

  subsection "Languages & runtimes"
  sw_check node    "Node.js"  "node --version"
  sw_check python3 "Python"   "python3 --version"
  sw_check ruby    "Ruby"     "ruby --version"
  sw_check go      "Go"       "go version"
  sw_check rustc   "Rust"     "rustc --version"
  sw_check java    "Java"     "java -version"
  sw_check php     "PHP"      "php --version"

  subsection "Package managers"
  sw_check brew  "Homebrew" "brew --version"
  sw_check npm   "npm"      "npm --version"
  sw_check pnpm  "pnpm"     "pnpm --version"
  sw_check yarn  "yarn"     "yarn --version"
  sw_check pip3  "pip"      "pip3 --version"
  sw_check uv    "uv"       "uv --version"

  subsection "Containers & virtualization"
  sw_check docker  "Docker"   "docker --version"
  sw_check orb     "OrbStack" "orb version"
  sw_check vagrant "Vagrant"  "vagrant --version"
  ls_app "VMware Fusion"
  ls_app "Parallels Desktop"
  ls_app "UTM"

  subsection "AI / LLM tooling"
  sw_check ollama          "Ollama"     "ollama --version"
  sw_check llama-cli       "llama.cpp"  "llama-cli --version"
  sw_check mlx_lm.generate "MLX-LM"     ""
  py_pkg torch        "PyTorch"
  py_pkg tensorflow   "TensorFlow"
  py_pkg transformers "Transformers"
  py_pkg mlx          "MLX"
  if have ollama; then
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1{print $1}' | tr '\n' ' ')
    models=$(trim "$models")
    if [ -n "$models" ]; then
      subsection "Installed Ollama models"
      bullet "$models"
    fi
  fi

  subsection "Editors & build tools"
  sw_check git  "Git"            "git --version"
  sw_check code "VS Code (code)" ""
  if [ "$SYS_OS" = "macos" ]; then
    sw_check xcodebuild "Xcode" "xcodebuild -version"
    if have xcrun; then
      local rts
      rts=$(xcrun simctl list runtimes 2>/dev/null | grep -ci "iOS\|watchOS\|tvOS")
      if [ "${rts:-0}" -gt 0 ] 2>/dev/null; then
        status ok "iOS/Sim runtimes — ${rts} installed"
      else
        status info "iOS Simulator runtimes — none downloaded yet (each ~7–8 GB)"
      fi
    fi
  fi
}
