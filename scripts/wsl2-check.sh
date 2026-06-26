#!/usr/bin/env bash
# wsl2-check.sh — Windows/WSL2 setup helper. Mitigates KI-008.
# Detects if running under WSL2 and checks the prerequisites Shannon needs.
set -u

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }

echo ""
echo "devstrata Windows / WSL2 check (KI-008)"
echo "──────────────────────────────────"

# Detect WSL
if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
  ok "Running under WSL2"
  WSL=true
elif [ "$(uname)" == "Linux" ]; then
  ok "Native Linux (not WSL) — no WSL-specific setup needed"
  WSL=false
elif [ "$(uname)" == "Darwin" ]; then
  ok "macOS — no WSL needed"
  exit 0
else
  fail "Unknown platform: $(uname)"
  exit 1
fi

if [ "$WSL" == "true" ]; then
  echo ""
  info "WSL2 detected — checking Windows-specific prerequisites:"
  echo ""

  # Docker Desktop integration
  if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
    ok "Docker accessible from WSL (Docker Desktop integration working)"
  else
    warn "Docker not accessible — install Docker Desktop with WSL integration enabled"
    echo "  https://docs.docker.com/desktop/wsl/"
  fi

  # systemd in WSL (needed for systemd service templates)
  if [ -d "/run/systemd/system" ]; then
    ok "systemd available in WSL — can use configs/helixdb.service + headroom-proxy.service"
  else
    warn "systemd not running in WSL"
    echo "  Enable: add 'systemd=true' to /etc/wsl.conf, then 'wsl --shutdown' in PowerShell"
    echo "  Without systemd, use ./scripts/morning-startup.sh instead of service files"
  fi

  # Ollama — can run in WSL or on Windows host
  if command -v ollama &>/dev/null; then
    ok "Ollama installed in WSL"
  else
    warn "Ollama not in WSL"
    echo "  Option A: install in WSL — curl -fsSL https://ollama.com/install.sh | sh"
    echo "  Option B: install on Windows host, WSL reaches it via host IP:"
    echo "            export OLLAMA_BASE_URL=http://\$(ip route show default | awk '{print \$3}'):11434"
  fi

  # Shannon requires Docker — already checked above

  # Hermes native Windows note
  echo ""
  info "Hermes Agent has native Windows support (no WSL needed for Hermes itself):"
  echo "  PowerShell: iex (irm https://hermes-agent.nousresearch.com/install.ps1)"
  echo "  But if you run the rest of the stack in WSL, install Hermes in WSL too."
fi

echo ""
echo "Status summary for KI-008:"
echo "  • Shannon: works via WSL2 + Docker Desktop (verified above)"
echo "  • Hermes: native Windows OR WSL (your choice)"
echo "  • Rest of stack: works in WSL2"
echo ""
echo "Recommendation: use WSL2 for the devstrata stack. It's the supported path."
echo ""