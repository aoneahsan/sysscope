#!/usr/bin/env bash
# =============================================================================
# SysScope — mod_ai.sh : Local AI / LLM capability assessment (the centerpiece)
# Uses MEM_TOTAL_GB, GPU_VRAM_GB, IS_UNIFIED, SYS_ARCH from earlier modules.
# Sets globals: AI_BUDGET_GB AI_TIER
# =============================================================================

# Model catalog: name|params|approx Q4 size(GB). One per line.
# (Sizes are approximate Ollama Q4_K_M download sizes.)
_ai_catalog() {
  cat <<'EOF'
llama3.2:1b|1B|1.3
qwen2.5:3b|3B|1.9
llama3.2:3b|3B|2.0
phi3.5|3.8B|2.2
mistral:7b|7B|4.1
llama3.1:8b|8B|4.7
qwen2.5:7b|7B|4.7
qwen2.5-coder:7b|7B|4.7
gemma2:9b|9B|5.4
phi4:14b|14B|9.1
qwen2.5:14b|14B|9.0
qwen2.5-coder:14b|14B|9.0
gemma2:27b|27B|16.0
qwen2.5:32b|32B|20.0
llama3.3:70b|70B|43.0
EOF
}

# Decide the memory budget available to a model (GB) and a tier label.
_ai_compute_budget() {
  local total vram
  total="${MEM_TOTAL_GB:-0}"
  vram="${GPU_VRAM_GB:-0}"

  if awk -v v="$vram" 'BEGIN{exit !(v>0.5)}'; then
    # Discrete GPU: VRAM is the practical limiter for fast inference.
    AI_BUDGET_GB=$(awk -v v="$vram" 'BEGIN{printf "%.1f", v*0.92}')
    AI_BACKEND="discrete GPU VRAM (${vram} GB)"
  elif [ "${IS_UNIFIED:-0}" = "1" ]; then
    # Apple Silicon unified memory: leave headroom for macOS + a couple apps.
    AI_BUDGET_GB=$(awk -v t="$total" 'BEGIN{b=t-4.5; if(b<1)b=1; printf "%.1f", b}')
    AI_BACKEND="unified memory (Metal GPU shares ${total} GB)"
  else
    # CPU-only path.
    AI_BUDGET_GB=$(awk -v t="$total" 'BEGIN{b=t-3; if(b<1)b=1; printf "%.1f", b}')
    AI_BACKEND="CPU only (no GPU acceleration detected — expect slow generation)"
  fi

  # Tier from budget. Thresholds use the same "size*1.3 comfortable-fit" rule as
  # the model table below, so the tier label and the per-model verdicts agree.
  if   awk -v b="$AI_BUDGET_GB" 'BEGIN{exit !(b>=55.9)}'; then AI_TIER_KEY="workstation"; AI_TIER="Workstation — 70B class"
  elif awk -v b="$AI_BUDGET_GB" 'BEGIN{exit !(b>=26.0)}'; then AI_TIER_KEY="high";        AI_TIER="High — up to ~32B Q4"
  elif awk -v b="$AI_BUDGET_GB" 'BEGIN{exit !(b>=20.8)}'; then AI_TIER_KEY="strong";      AI_TIER="Strong — up to ~27B Q4"
  elif awk -v b="$AI_BUDGET_GB" 'BEGIN{exit !(b>=11.7)}'; then AI_TIER_KEY="capable";     AI_TIER="Capable — up to ~14B Q4"
  elif awk -v b="$AI_BUDGET_GB" 'BEGIN{exit !(b>=6.0)}';  then AI_TIER_KEY="comfortable"; AI_TIER="Comfortable — 7–9B daily (14B tight)"
  elif awk -v b="$AI_BUDGET_GB" 'BEGIN{exit !(b>=3.0)}';  then AI_TIER_KEY="entry";       AI_TIER="Entry — up to ~7B (tight)"
  else AI_TIER_KEY="minimal"; AI_TIER="Minimal — 1–3B models"
  fi
}

# fit verdict for a model size vs budget: yes / tight / no
_ai_fit() {
  awk -v s="$1" -v b="$2" 'BEGIN{
    if (s*1.3 <= b)      print "yes";
    else if (s <= b)     print "tight";
    else                 print "no";
  }'
}

mod_ai() {
  section "Local AI / LLM Capability"
  _ai_compute_budget

  field "Inference backend" "$AI_BACKEND"
  field "Usable memory budget" "~${AI_BUDGET_GB} GB for the model + context"
  field "Capability tier" "$AI_TIER"

  case "$AI_BACKEND" in
    CPU*) status warn "No GPU acceleration detected. Models will run on CPU — usable for small models, but slow. A GPU or Apple Silicon is strongly recommended." ;;
    *)    status ok   "Hardware-accelerated local inference is available." ;;
  esac

  # ---- Model fit table -----------------------------------------------------
  subsection "Which models fit (Ollama, Q4 quantization)"
  printf '  %s%-22s %-7s %-9s %-7s%s\n' "$BOLD" "MODEL" "PARAMS" "~SIZE" "FITS?" "$RST"
  table_begin "Model" "Params" "~Size (Q4)" "Fits this machine?"

  _ai_catalog | while IFS='|' read -r name params size; do
    [ -n "$name" ] || continue
    verdict=$(_ai_fit "$size" "$AI_BUDGET_GB")
    case "$verdict" in
      yes)   mark="✅ yes";    col="$GRN" ;;
      tight) mark="🟡 tight";  col="$YLW" ;;
      no)    mark="🔴 too big"; col="$RED" ;;
    esac
    printf '  %-22s %-7s %-9s %s%s%s\n' "$name" "$params" "${size}GB" "$col" "$mark" "$RST"
    table_row "\`$name\`" "$params" "${size} GB" "$mark"
  done

  # ---- Recommended starter set (based on tier) -----------------------------
  subsection "Recommended starter set"
  case "$AI_TIER_KEY" in
    minimal)
      bullet "General: \`llama3.2:1b\` (1.3 GB) or \`qwen2.5:3b\` (1.9 GB)"
      bullet "Keep contexts short; expect small-model quality."
      ;;
    entry)
      bullet "General: \`llama3.1:8b\` (4.7 GB) — may be tight; fall back to \`llama3.2:3b\`"
      bullet "Coding:  \`qwen2.5-coder:7b\` (4.7 GB)"
      bullet "Embeddings (RAG/search): \`nomic-embed-text\` (0.3 GB)"
      ;;
    comfortable)
      bullet "General: \`llama3.1:8b\` (4.7 GB) — fast daily driver"
      bullet "Coding:  \`qwen2.5-coder:7b\` (4.7 GB) — pairs with the VS Code 'continue.dev' extension"
      bullet "Embeddings: \`nomic-embed-text\` (0.3 GB)"
      bullet "Step up for hard problems: \`qwen2.5:14b\` / \`phi4:14b\` (close other apps first)"
      ;;
    capable)
      bullet "General: \`qwen2.5:14b\` (9 GB) or \`phi4:14b\` (9 GB)"
      bullet "Coding:  \`qwen2.5-coder:14b\` (9 GB)"
      bullet "Fast daily option: \`llama3.1:8b\` (4.7 GB)"
      bullet "Embeddings: \`nomic-embed-text\` (0.3 GB)"
      ;;
    strong)
      bullet "General: \`gemma2:27b\` (16 GB); use \`qwen2.5:14b\` (9 GB) for speed"
      bullet "Coding:  \`qwen2.5-coder:14b\` (9 GB)"
      bullet "Embeddings: \`mxbai-embed-large\` (0.7 GB)"
      ;;
    high)
      bullet "General: \`qwen2.5:32b\` (20 GB)"
      bullet "Coding:  \`qwen2.5-coder:32b\` (20 GB)"
      bullet "Embeddings: \`mxbai-embed-large\` (0.7 GB)"
      ;;
    workstation)
      bullet "General: \`llama3.3:70b\` (43 GB) for top local quality"
      bullet "Coding:  \`qwen2.5-coder:32b\` for faster turnaround"
      bullet "You can keep multiple models loaded at once."
      ;;
  esac

  subsection "Install & first run"
  bullet "Install: \`brew install ollama\` then \`brew services start ollama\`  (or download from ollama.com)"
  bullet "Pull + chat: \`ollama run llama3.1:8b\`"
  bullet "List / remove: \`ollama list\` · \`ollama rm <model>\`  (each model is multiple GB — mind disk)"

  # Speed expectation (qualitative + arch-aware)
  subsection "Speed expectation"
  case "$AI_BACKEND" in
    CPU*)            note "CPU-only: small models a few tokens/sec; 7B may be ~1–4 tok/s. Fine for tinkering, not interactive." ;;
    *VRAM*)          note "On a discrete GPU, 7–8B models are very fast (often 40–100+ tok/s); larger models scale with VRAM + bandwidth." ;;
    *unified*)       note "On Apple Silicon, 7–8B≈10–25 tok/s, 14B≈6–12 tok/s (varies by chip tier). Generation speed is memory-bandwidth-bound." ;;
  esac

  if [ "$AI_TIER_KEY" = "comfortable" ] && [ "${IS_UNIFIED:-0}" = "1" ]; then
    note "Tip: to fit a 14B model, close other apps. On Apple Silicon you can also raise the GPU memory limit temporarily: \`sudo sysctl iogpu.wired_limit_mb=12288\` (reverts on reboot — don't starve macOS)."
  fi

  j ai_budget_gb "${AI_BUDGET_GB:-}"
  j ai_tier "${AI_TIER:-}"
}
