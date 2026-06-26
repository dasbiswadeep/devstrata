#!/usr/bin/env bash
# end-of-day.sh — capture state and tear down optional services.
# Run at the end of your day. Keeps Mem0/HelixDB running (they auto-restart
# via docker compose) but stops the Headroom proxy if you want to free RAM.

set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }

echo ""
echo "devstrata end-of-day"
echo "──────────────────────────────────"

# 1. Refresh the Graphify graph so tomorrow's session has fresh codebase context
if command -v graphify &>/dev/null && [ -f "graphify-out/graph.json" ]; then
  info "Updating Graphify graph..."
  graphify . --update 2>/dev/null && ok "Graph updated" || warn "graphify . --update failed"
fi

# 2. Export to Obsidian (--pro only)
if [ -n "${GRAPHIFY_OBSIDIAN_PATH:-}" ] && [ -d "$GRAPHIFY_OBSIDIAN_PATH" ]; then
  info "Exporting graph to Obsidian..."
  graphify . --obsidian 2>/dev/null && ok "Obsidian export done" || warn "obsidian export failed"
fi

# 3. Headroom learning loop (if supported by installed version)
if command -v headroom &>/dev/null; then
  info "Headroom learn (best-effort)..."
  headroom learn 2>/dev/null && ok "Headroom learn done" || info "headroom learn not supported in this version — skip"
fi

# 4. Optionally stop Headroom to free ~200MB RAM overnight
if [ "${1:-}" == "--stop-proxy" ]; then
  if pgrep -f "headroom proxy" >/dev/null; then
    pkill -f "headroom proxy"
    ok "Headroom proxy stopped (RAM freed)"
  fi
else
  ok "Headroom proxy left running (use --stop-proxy to stop it)"
fi

# 5. Report Mem0 + HelixDB state accurately (don't claim they're running if they're not)
MEM0_UP=false; HELIX_UP=false
curl -s http://localhost:3000/health &>/dev/null && MEM0_UP=true
curl -s http://localhost:6969/health &>/dev/null && HELIX_UP=true
if [ "$MEM0_UP" == "true" ]; then
  ok "Mem0 running on :3000 (managed by docker compose — left up)"
else
  warn "Mem0 not running — start with: docker compose up -d   (or: not installed in --lite)"
fi
if [ "$HELIX_UP" == "true" ]; then
  ok "HelixDB running on :6969 (managed by launchd/systemd — left up)"
else
  warn "HelixDB not running — start with: helix start dev --disk   (or: not installed in --lite)"
fi

echo ""
echo "Remember to:"
echo "  - Capture decisions in your Obsidian daily note"
echo "  - Add confirmed architectural decisions to Mem0:"
echo "      mem0 add \"Decided to use X for Y because Z\" --user-id <project>"
echo ""
echo "──────────────────────────────────"
echo ""