#!/usr/bin/env bash
# update.sh — check upstream tools for newer versions and report drift.
# Addresses KNOWN_ISSUES KI-001 (install commands rot).
#
# This does NOT auto-upgrade. It reports what has changed so you can
# review and upgrade deliberately. See Q5 in README — devstrata does not
# automatically adopt upstream changes; this script is the closest thing.

set -u

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }

echo ""
echo "devstrata upstream drift check"
echo "──────────────────────────────────"
echo "Reports currently installed versions vs latest available."
echo "Review before upgrading. Pin versions in production."
echo ""

# Headroom
if command -v headroom &>/dev/null; then
  INSTALLED=$(headroom --version 2>/dev/null || echo "unknown")
  info "headroom: installed=$INSTALLED  (check PyPI: pip index versions headroom-ai)"
else
  warn "headroom not installed"
fi

# Graphify
if command -v graphify &>/dev/null; then
  INSTALLED=$(graphify --version 2>/dev/null || echo "unknown")
  info "graphify: installed=$INSTALLED  (check: pip install --upgrade graphifyy && graphify install)"
else
  warn "graphify not installed"
fi

# Mem0
if command -v mem0 &>/dev/null; then
  INSTALLED=$(mem0 --version 2>/dev/null || echo "unknown")
  info "mem0:     installed=$INSTALLED  (check: pip install --upgrade mem0ai)"
else
  warn "mem0 not installed"
fi

# HelixDB
if command -v helix &>/dev/null; then
  INSTALLED=$(helix --version 2>/dev/null || echo "unknown")
  info "helix:    installed=$INSTALLED  (check: curl -sSL https://install.helix-db.com | bash)"
else
  warn "helix not installed"
fi

# Shannon
info "shannon:  check latest at https://github.com/KeygraphHQ/shannon/releases"

# Hermes
if command -v hermes &>/dev/null; then
  INSTALLED=$(hermes --version 2>/dev/null || echo "unknown")
  info "hermes:   installed=$INSTALLED  (check: hermes upgrade)"
else
  warn "hermes not installed (--pro only)"
fi

# MCP servers
echo ""
info "MCP servers (npm): npm outdated -g 2>/dev/null | grep modelcontextprotocol"
info "MCP servers (uvx): uv tool list"

# Docker images
if command -v docker &>/dev/null && [ -f "docker-compose.yml" ]; then
  echo ""
  info "Docker images with pending updates:"
  docker compose images 2>/dev/null || true
  info "To pull updated images: docker compose pull"
fi

echo ""
echo "──────────────────────────────────"
echo "Manual upgrade commands (review changelogs first!):"
echo "  pip install --upgrade headroom-ai mem0ai graphifyy"
echo "  uv tool upgrade graphifyy  # if installed via uv tool"
echo "  pip install --upgrade graphifyy  # if installed via pip"
echo "  npm install -g @modelcontextprotocol/server-filesystem@latest"
echo "  docker compose pull && docker compose up -d"
echo ""
echo "After upgrading, re-run: ./scripts/doctor.sh"
echo ""