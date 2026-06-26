#!/usr/bin/env bash
# morning-startup.sh — start all devstrata services for the day.
# Addresses KNOWN_ISSUES KI-003 (no process supervision) for manual workflows.
# Run this at the start of your day, or add to launchd / systemd.

set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }

echo ""
echo "devstrata morning startup"
echo "──────────────────────────────────"

# 1. Headroom proxy (:8787)
if curl -s http://localhost:8787/health &>/dev/null; then
  ok "Headroom already running on :8787"
else
  if command -v headroom &>/dev/null; then
    headroom proxy --port 8787 &>/tmp/headroom.log &
    sleep 2
    if curl -s http://localhost:8787/health &>/dev/null; then
      ok "Headroom started on :8787"
    else
      fail "Headroom failed to start — check /tmp/headroom.log"
    fi
  else
    warn "headroom not installed — run ./scripts/install.sh --lite"
  fi
fi

# 2. Ollama (if using local LLM)
if command -v ollama &>/dev/null; then
  if curl -s http://localhost:11434/api/tags &>/dev/null; then
    ok "Ollama already running"
  else
    ollama serve &>/tmp/ollama.log &
    sleep 2
    if curl -s http://localhost:11434/api/tags &>/dev/null; then
      ok "Ollama started"
    else
      fail "Ollama failed to start — check /tmp/ollama.log"
    fi
  fi
else
  warn "ollama not installed (using cloud backend?)"
fi

# 3. HelixDB (:6969) — --full and --pro only
if command -v helix &>/dev/null; then
  if curl -s http://localhost:6969/health &>/dev/null; then
    ok "HelixDB already running on :6969"
  else
    helix start dev --disk &>/tmp/helix.log &
    sleep 3
    if curl -s http://localhost:6969/health &>/dev/null; then
      ok "HelixDB started on :6969"
    else
      warn "HelixDB could not start — check /tmp/helix.log"
    fi
  fi
fi

# 4. Mem0 (:3000) — prefer docker compose, fall back to manual note
if command -v docker &>/dev/null && docker compose version &>/dev/null; then
  if [ -f "docker-compose.yml" ]; then
    if curl -s http://localhost:3000/health &>/dev/null; then
      ok "Mem0 already running on :3000"
    else
      info "Starting Mem0 via docker compose..."
      docker compose up -d mem0 2>/dev/null
      sleep 5
      if curl -s http://localhost:3000/health &>/dev/null; then
        ok "Mem0 started on :3000"
      else
        warn "Mem0 still warming up — check: docker compose logs mem0"
      fi
    fi
  else
    warn "No docker-compose.yml — copy from configs/docker-compose.yml"
  fi
else
  warn "Docker not available — Mem0 must be started manually"
fi

# 5. Graphify graph freshness check
if [ -f "graphify-out/graph.json" ]; then
  DAYS_OLD=$(( ($(date +%s) - $(date -r graphify-out/graph.json +%s)) / 86400 ))
  if [ "$DAYS_OLD" -gt 3 ]; then
    warn "Knowledge graph is ${DAYS_OLD} days old — run: graphify . --update"
  else
    ok "Knowledge graph fresh (${DAYS_OLD} days old)"
  fi
else
  warn "No graphify-out/graph.json — run: graphify ."
fi

echo ""
echo "──────────────────────────────────"
echo "Run 'bash $(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/doctor.sh' for a full health check"
echo ""