#!/usr/bin/env bash
# recommend-profile.sh — detect hardware and recommend the right profile.
# Mitigates KI-004 (hardware ceiling) by guiding users BEFORE install.
#
# Usage: ./scripts/recommend-profile.sh
# Output: recommended profile + RAM analysis + fallback suggestions
set -u

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }

# Detect RAM (bytes → GB)
detect_ram_gb() {
  if [ "$(uname)" == "Darwin" ]; then
    echo $(( $(sysctl -n hw.memsize) / 1073741824 ))
  else
    # Linux: sum MemTotal from /proc/meminfo (kB → GB)
    echo $(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1048576 ))
  fi
}

RAM_GB=$(detect_ram_gb)
echo ""
echo "devstrata profile recommender"
echo "──────────────────────────────────"
info "Detected RAM: ${RAM_GB}GB"

# Check for cloud backend availability (means user can run higher profile on less RAM)
CLOUD_AVAILABLE=false
[ -n "${ANTHROPIC_API_KEY:-}" ] && { info "ANTHROPIC_API_KEY set (cloud fallback available)"; CLOUD_AVAILABLE=true; }
[ -n "${OPENAI_API_KEY:-}" ]    && { info "OPENAI_API_KEY set (cloud fallback available)"; CLOUD_AVAILABLE=true; }
[ -n "${GEMINI_API_KEY:-}" ]   && { info "GEMINI_API_KEY set (cloud fallback available)"; CLOUD_AVAILABLE=true; }

# Check for Apple Silicon (better GPU offload for Ollama)
APPLE_SILICON=false
if [ "$(uname)" == "Darwin" ] && sysctl -n machdep.cpu.brand_string 2>/dev/null | grep -qi "Apple M[0-9]"; then
  APPLE_SILICON=true
  info "Apple Silicon detected (better Ollama GPU offload)"
fi

echo ""

# Recommendation logic
# --lite is always a safe starting point, even on bigger hardware.
# We recommend the highest profile your RAM supports, but always tell the user
# that --lite is the safe default if they're unsure.
if [ "$RAM_GB" -ge 24 ]; then
  RECO="pro"
  ok "Recommended profile: --pro (24GB+ RAM)"
  echo "  → Full stack + Hermes + Obsidian + 32b model headroom"
  if [ "$APPLE_SILICON" == "true" ]; then
    ok "  Apple Silicon: 32b model runs with GPU offload"
  fi
elif [ "$RAM_GB" -ge 16 ]; then
  RECO="full"
  ok "Recommended profile: --full (16GB+ RAM)"
  echo "  → Mem0 + HelixDB + Shannon + 14b model"
  if [ "$CLOUD_AVAILABLE" == "true" ]; then
    echo ""
    warn "  You have 16GB + cloud keys — you CAN run --pro if you use cloud LLM"
    echo "  fallback for heavy tasks (don't load the 32b model locally)."
  fi
elif [ "$RAM_GB" -ge 8 ]; then
  RECO="lite"
  ok "Recommended profile: --lite (8GB+ RAM)"
  echo "  → Headroom + Graphify + MCP + 14b model"
  if [ "$CLOUD_AVAILABLE" == "true" ]; then
    echo ""
    warn "  You have 8GB + cloud keys — consider --full + cloud LLM (skip local Ollama)"
    echo "  Set in headroom.env: ANTHROPIC_API_KEY, unset OLLAMA_MODEL"
  fi
else
  RECO="lite"
  warn "RAM is ${RAM_GB}GB — below --lite minimum (8GB)."
  echo ""
  if [ "$CLOUD_AVAILABLE" == "true" ]; then
    ok "Cloud LLM detected — you CAN use --lite with cloud backend (no local Ollama)."
    echo "  Set in headroom.env: ANTHROPIC_API_KEY or OPENAI_API_KEY"
    echo "  Comment out: OLLAMA_MODEL, OPENAI_BASE_URL"
    echo "  This skips the ~9GB Ollama footprint entirely."
  else
    fail "Below 8GB with no cloud LLM. devstrata requires either 8GB+ RAM OR a cloud API key."
    echo "  Get one: https://console.anthropic.com or https://platform.openai.com"
    exit 1
  fi
fi

echo ""
echo "Not sure? Start with --lite. It's the safe default and upgrades in one command."
echo "Install:"
echo "  ./scripts/install.sh --$RECO"
echo ""
echo "Verify after install:"
echo "  ./scripts/doctor.sh"
echo ""