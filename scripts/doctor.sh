#!/usr/bin/env bash
# devstrata doctor — check all services and dependencies
# Run this when something seems wrong, or on morning startup

set -e

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
echo "devstrata doctor"
echo "──────────────────────────────────"

# Prerequisites
echo ""
echo "Prerequisites"
command -v python3 &>/dev/null && ok "Python $(python3 --version 2>&1 | cut -d' ' -f2)" || fail "Python not found — install 3.10+"
command -v node &>/dev/null   && ok "Node.js $(node --version)" || fail "Node.js not found — install 18+"
command -v docker &>/dev/null && ok "Docker available" || warn "Docker not found — needed for Mem0 self-hosted and Shannon"
command -v ollama &>/dev/null && ok "Ollama installed" || warn "Ollama not found — needed for local LLM"
command -v uv &>/dev/null     && ok "uv installed" || warn "uv not found — run: curl -LsSf https://astral.sh/uv/install.sh | sh"

# Services
echo ""
echo "Services"

# Headroom
if curl -s http://localhost:8787/health &>/dev/null; then
  ok "Headroom proxy running on :8787"
else
  fail "Headroom proxy not running — run: headroom proxy --port 8787 &"
fi

# HelixDB
if curl -s http://localhost:6969/health &>/dev/null; then
  ok "HelixDB running on :6969"
else
  warn "HelixDB not running (needed for --full/--pro) — run: helix start dev --disk"
fi

# Mem0
if curl -s http://localhost:3000/health &>/dev/null; then
  ok "Mem0 server running on :3000"
else
  warn "Mem0 not running (needed for --full/--pro) — run: docker compose up -d mem0"
fi

# Ollama
if curl -s http://localhost:11434/api/tags &>/dev/null; then
  ok "Ollama running"
  # Check for recommended model
  if curl -s http://localhost:11434/api/tags | grep -q "qwen2.5-coder:14b"; then
    ok "  qwen2.5-coder:14b loaded"
  else
    warn "  qwen2.5-coder:14b not found — run: ollama pull qwen2.5-coder:14b"
  fi
else
  warn "Ollama not running (if using local LLM) — run: ollama serve"
fi

# Graphify
echo ""
echo "Graphify"
if command -v graphify &>/dev/null; then
  ok "Graphify installed"
  if [ -f "graphify-out/graph.json" ]; then
    DAYS_OLD=$(( ($(date +%s) - $(date -r graphify-out/graph.json +%s)) / 86400 ))
    if [ "$DAYS_OLD" -gt 3 ]; then
      warn "Knowledge graph is ${DAYS_OLD} days old — run: graphify . --update"
    else
      ok "Knowledge graph exists (${DAYS_OLD} days old)"
    fi
  else
    warn "No graph.json found — run: graphify . (from your project root)"
  fi
else
  warn "Graphify not installed — run: pip install graphifyy && graphify install"
fi

# MCP
echo ""
echo "MCP Servers"
if [ -f ".mcp.json" ]; then
  ok ".mcp.json found"
  command -v npx &>/dev/null && ok "  filesystem server (npx available)" || fail "  filesystem server needs npx"
  command -v uvx &>/dev/null && ok "  git server (uvx available)" || warn "  git server needs uvx"
else
  warn ".mcp.json not found — run: ./scripts/install.sh --lite   (or --full / --pro)"
fi

# Skills
echo ""
echo "Skills"
SKILLS_DIRS=(
  "$HOME/.config/opencode/skills"
  "$HOME/.claude/skills"
  "$HOME/.hermes/skills"
)
FOUND_SKILLS=false
for dir in "${SKILLS_DIRS[@]}"; do
  if [ -d "$dir" ] && [ "$(ls -A "$dir" 2>/dev/null)" ]; then
    ok "Skills found in $dir"
    FOUND_SKILLS=true
  fi
done
$FOUND_SKILLS || warn "No skills installed — run: npx skillsadd anthropics/skills obra/superpowers"

# Hermes
echo ""
echo "Hermes"
if command -v hermes &>/dev/null; then
  ok "Hermes installed ($(hermes --version 2>/dev/null || echo 'version unknown'))"
else
  warn "Hermes not installed (--pro only) — run: curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
fi

# Shannon
echo ""
echo "Shannon"
if command -v npx &>/dev/null && npx @keygraph/shannon --version &>/dev/null 2>&1; then
  ok "Shannon available via npx"
elif command -v docker &>/dev/null; then
  ok "Docker available — Shannon can run via npx @keygraph/shannon"
else
  warn "Shannon needs Docker — install Docker to enable security scanning"
fi

# Config files
echo ""
echo "Config Files"
[ -f "AGENTS.md" ]   && ok "AGENTS.md found" || warn "AGENTS.md missing — copy from configs/AGENTS.md.template"
[ -f "CLAUDE.md" ]   && ok "CLAUDE.md found" || info "CLAUDE.md optional (Claude Code specific)"
[ -f ".mcp.json" ]   && ok ".mcp.json found" || warn ".mcp.json missing — run: ./scripts/install.sh --lite"
[ -f "helix.toml" ]  && ok "helix.toml found" || info "helix.toml optional (HelixDB projects)"

# Summary — detect pre-install state and give the right next step
echo ""
echo "──────────────────────────────────"
# Count how many of the core tools are NOT installed (pre-install state detection)
NOT_INSTALLED=0
command -v headroom &>/dev/null || NOT_INSTALLED=$((NOT_INSTALLED+1))
command -v graphify &>/dev/null || NOT_INSTALLED=$((NOT_INSTALLED+1))
[ -f ".mcp.json" ] || NOT_INSTALLED=$((NOT_INSTALLED+1))
[ -f "AGENTS.md" ] || NOT_INSTALLED=$((NOT_INSTALLED+1))

# Resolve the devstrata scripts dir (doctor.sh is at scripts/doctor.sh → repo is one level up)
DEVSTRATA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ "$NOT_INSTALLED" -ge 3 ]; then
  echo "Looks like devstrata isn't installed yet. Run:"
  echo "  bash $DEVSTRATA_DIR/scripts/recommend-profile.sh   # find your profile"
  echo "  bash $DEVSTRATA_DIR/scripts/install.sh --lite       # safest start (or --full / --pro)"
else
  echo "Run 'bash $DEVSTRATA_DIR/scripts/morning-startup.sh' to start all services"
  echo "Run 'bash $DEVSTRATA_DIR/scripts/update.sh' to check for upstream version drift"
  echo "Run 'bash $DEVSTRATA_DIR/scripts/version-check.sh' to compare installed vs latest (queries PyPI/GitHub)"
fi
echo ""
