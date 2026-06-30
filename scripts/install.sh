#!/usr/bin/env bash
# devstrata install.sh
# Usage: ./scripts/install.sh [--lite|--full|--pro]
# Default: --lite
#
# WARNING: This script installs third-party tools.
# Review each step before running. Commands may be outdated.
# Check upstream READMEs if anything fails.

set -e

# Parse args in any order. Accept --lite/--full/--pro (profile) and --yes/-y (non-interactive).
# --with-ecc swaps in ECC (affaan-m/ECC) as a replacement for the L4+L5 layer
#   (Superpowers + GSD Core + skills.sh). ECC is a 277-skill monolith, not a
#   composable tool — so it's an opt-in replacement, not part of the default stack.
# --force regenerates .mcp.json + AGENTS.md even if they exist (use on profile upgrade).
# Default profile is lite if no profile flag is given.
PROFILE="lite"
YES=false
FORCE=false
WITH_ECC=false
for arg in "$@"; do
  case "$arg" in
    --lite)  PROFILE="lite" ;;
    --full) PROFILE="full" ;;
    --pro)  PROFILE="pro" ;;
    --yes|-y) YES=true ;;
    --force) FORCE=true ;;
    --with-ecc) WITH_ECC=true ;;
    -h|--help)
      echo "Usage: $0 [--lite|--full|--pro] [--yes|-y] [--force] [--with-ecc]"
      echo "  --lite       8GB+ RAM, any machine (default)"
      echo "  --full       16GB+ RAM, adds Mem0 + HelixDB + Shannon"
      echo "  --pro        24GB+ RAM, adds Hermes + Obsidian"
      echo "  --yes        Non-interactive (skip prompts; for CI)"
      echo "  --force      Regenerate .mcp.json + AGENTS.md even if they exist (use on profile upgrade)"
      echo "  --with-ecc   Swap in ECC (affaan-m/ECC, 223k stars, MIT) for L4+L5 instead of"
      echo "               Superpowers + GSD Core + skills.sh. Batteries-included: 277 skills,"
      echo "               67 agents, hooks, 12-language rules. Official install path only."
      exit 0 ;;
    *) echo "Unknown arg: $arg (use --lite/--full/--pro/--yes/--force/--with-ecc)"; exit 1 ;;
  esac
done

# Validate profile
case "$PROFILE" in
  lite|full|pro) ;;
  *) echo "Invalid profile: $PROFILE (use --lite, --full, or --pro)"; exit 1 ;;
esac

# Output helpers (defined early so the upgrade-detection block can use them)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }
info() { echo -e "${BLUE}→${NC} $1"; }
step() { echo ""; echo -e "${BLUE}══ $1 ══${NC}"; }

# Auto-detect profile upgrade: if .mcp.json exists and was for a different profile,
# warn the user to use --force to regenerate configs.
if [ -f ".mcp.json" ] && [ "$FORCE" == "false" ]; then
  EXISTING_HAS_HELIX=$(jq -r '.mcpServers | has("helix")' .mcp.json 2>/dev/null || echo "false")
  case "$PROFILE" in
    lite)
      if [ "$EXISTING_HAS_HELIX" == "true" ]; then
        warn "Existing .mcp.json has helix/mem0 (from a --full/--pro install) but you're installing --lite."
        warn "Use --force to regenerate .mcp.json for lite (strips helix + mem0)."
      fi ;;
    full|pro)
      if [ "$EXISTING_HAS_HELIX" == "false" ]; then
        warn "Existing .mcp.json is the lite version (no helix/mem0) but you're installing --$PROFILE."
        warn "Run with --force to regenerate .mcp.json with all 6 servers."
      fi ;;
  esac
fi

echo ""
echo "devstrata installer — profile: $PROFILE"
echo "══════════════════════════════════════"
echo ""
echo "⚠  This installs third-party open-source tools."
echo "   Review INSTRUCTIONS.md for manual steps."
echo "   Some commands may have changed upstream."
echo ""
# Top-level prompt: --yes/-y flag skips the interactive prompt entirely.
REPLY=""
if [ "$YES" == "true" ]; then
  REPLY="y"
elif [ -t 0 ]; then
  read -p "Continue? (y/N) " -n 1 -r || true; echo
else
  echo "Non-interactive terminal. Re-run with --yes to proceed, or run in a TTY."
  exit 1
fi
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

# ── Verify prerequisites ──────────────────────────────────────────────────────

step "Checking prerequisites"

python3 --version &>/dev/null || fail "Python 3.10+ required"
ok "Python $(python3 --version 2>&1 | cut -d' ' -f2)"

# KI-009 mitigation: check Node version is 18+, not just present
if node --version &>/dev/null; then
  NODE_MAJOR=$(node --version 2>/dev/null | sed -E 's/v([0-9]+).*/\1/')
  if [ "$NODE_MAJOR" -ge 18 ]; then
    ok "Node.js $(node --version) (≥18 — skills.sh will work)"
  else
    fail "Node.js $(node --version) is < 18 — skills.sh (npx skillsadd) will fail silently. Upgrade: https://nodejs.org"
    exit 1
  fi
else
  fail "Node.js 18+ required — install from https://nodejs.org"
  exit 1
fi

# Optional but recommended
command -v jq &>/dev/null && ok "jq installed (clean .mcp.json generation)" || warn "jq not found — lite .mcp.json will need manual edit (brew install jq)"
command -v docker &>/dev/null && ok "Docker available" || warn "Docker not found — needed for --full/--pro (Mem0 + Shannon)"

# uv/uvx check — the git MCP server requires uvx. Offer to install if missing.
if command -v uvx &>/dev/null; then
  ok "uv/uvx installed (git MCP server will work)"
else
  warn "uv/uvx not found — the git MCP server needs it"
  # Robust read: if stdin is not a tty / exhausted, default to skipping
  REPLY="n"
  if [ -t 0 ]; then
    read -p "  Install uv now? (Y/n) " -n 1 -r || true
  else
    warn "Non-interactive terminal — skip uv install. Run later: curl -LsSf https://astral.sh/uv/install.sh | sh"
  fi
  echo
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null && ok "uv installed — restart shell or run: source ~/.cargo/env" || warn "uv install failed — run manually: curl -LsSf https://astral.sh/uv/install.sh | sh"
  fi
fi

# ── Step 1: Headroom (all profiles) ──────────────────────────────────────────

step "Step 1: Headroom (token compression)"

if command -v headroom &>/dev/null; then
  ok "Headroom already installed"
else
  info "Installing headroom-ai..."
  pip install "headroom-ai[all]" --break-system-packages || pip install "headroom-ai[all]"
  ok "Headroom installed"
fi

# Start proxy if not running
if ! pgrep -f "headroom proxy" > /dev/null; then
  headroom proxy --port 8787 &>/tmp/headroom.log &
  sleep 2
  ok "Headroom proxy started on :8787"
else
  ok "Headroom proxy already running"
fi

# ── Step 2: Graphify (all profiles) ──────────────────────────────────────────

step "Step 2: Graphify (codebase knowledge graph)"

if command -v graphify &>/dev/null; then
  ok "Graphify already installed"
else
  info "Installing graphify..."
  # Upstream canonical install (verified 2026-06-26, see docs/SOURCES.md):
  #   pip install graphifyy && graphify install
  # Package name is graphifyy (double-y) while CLI is graphify (name reclamation in progress).
  pip install graphifyy --break-system-packages 2>/dev/null || pip install graphifyy || {
    warn "pip install graphifyy failed — trying pipx fallback (macOS externally-managed)"
    pipx install graphifyy
  }
  # Register the skill with the agent
  graphify install 2>/dev/null || warn "graphify install (skill registration) failed — run manually"
  ok "Graphify installed"
fi

# ── Step 3: MCP Servers (all profiles) ───────────────────────────────────────

step "Step 3: MCP Servers"

# Verify fetch server available
npx -y @modelcontextprotocol/server-fetch --help &>/dev/null && ok "MCP fetch server available" || warn "MCP fetch server check failed"

# Generate profile-specific .mcp.json from the single canonical template.
# lite → strips helix + mem0 servers (they're not installed)
# full/pro → keeps all 6 servers
# Single source of truth: configs/.mcp.json.template  (addresses review: no 3 drift-prone copies)
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# Regenerate .mcp.json if missing, OR if --force (e.g. profile upgrade)
if [ ! -f ".mcp.json" ] || [ "$FORCE" == "true" ]; then
  # Back up existing file before --force clobbers it (prevent data loss)
  if [ "$FORCE" == "true" ] && [ -f ".mcp.json" ]; then
    cp .mcp.json ".mcp.json.bak.$(date +%s)"
    info "Backed up existing .mcp.json to .mcp.json.bak.* (edit was preserved)"
  fi
  if [ -f "$SCRIPT_DIR/configs/.mcp.json.template" ]; then
    if command -v jq &>/dev/null; then
      if [ "$PROFILE" == "lite" ]; then
        jq 'del(.mcpServers.helix, .mcpServers.mem0)' "$SCRIPT_DIR/configs/.mcp.json.template" > .mcp.json
        ok ".mcp.json generated (lite: 4 servers — filesystem, git, fetch, graphify)"
      else
        cp "$SCRIPT_DIR/configs/.mcp.json.template" .mcp.json
        ok ".mcp.json generated ($PROFILE: 6 servers — + helix, mem0)"
      fi
    else
      # jq not available — fall back to plain copy, warn lite users to edit
      cp "$SCRIPT_DIR/configs/.mcp.json.template" .mcp.json
      if [ "$PROFILE" == "lite" ]; then
        warn ".mcp.json copied with all 6 servers — install jq, or manually delete 'helix' + 'mem0' blocks for --lite"
      else
        ok ".mcp.json created from template"
      fi
    fi
  else
    warn ".mcp.json template not found — create manually (see docs/ARCHITECTURE.md)"
  fi
else
  ok ".mcp.json already exists"
fi

# ── Step 4: Skills (all profiles) ────────────────────────────────────────────

step "Step 4: skills.sh"

info "Installing core skills..."
npx skillsadd anthropics/skills 2>/dev/null || warn "anthropics/skills failed — retry manually"
npx skillsadd obra/superpowers  2>/dev/null || warn "obra/superpowers failed — retry manually"
npx skillsadd safishamsi/graphify 2>/dev/null || warn "safishamsi/graphify failed — retry manually"
ok "Core skills installed (check warnings above)"

# ── Step 5: Superpowers (all profiles) ───────────────────────────────────────

step "Step 5: Superpowers (methodology)"
info "Superpowers must be installed from inside your agent."
info "For OpenCode: tell it to fetch https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md"
info "For Claude Code: /plugin install superpowers@claude-plugins-official"
warn "Manual step required — see docs/INSTRUCTIONS.md Step 6"

# ── Step 6: GSD Core (all profiles) ──────────────────────────────────────────

step "Step 6: GSD Core (workflow engine)"

if command -v npx &>/dev/null; then
  info "Installing GSD Core..."
  npx @opengsd/gsd-core@latest 2>/dev/null || warn "GSD Core install failed — run manually: npx @opengsd/gsd-core@latest"
fi

# ── Optional: ECC (replaces L4+L5 if --with-ecc) ──────────────────────────────
# ECC (affaan-m/ECC, 223k stars, MIT) is a batteries-included agent harness pack:
# 277 skills, 67 agents, hooks, 12-language rules. It's a monolith, not a composable
# tool — so it's an opt-in REPLACEMENT for Superpowers + GSD Core + skills.sh (L4+L5),
# not part of the default composed stack. This preserves principle #1 (composition
# over creation): the default stack composes 11 independent tools; ECC is an explicit
# user choice to swap in a single-pack alternative.
if [ "$WITH_ECC" == "true" ]; then
  step "Optional: ECC (replaces L4+L5 — 277 skills, 67 agents, 12-language rules)"
  info "ECC is a monolithic harness pack from affaan-m/ECC (223k stars, MIT)."
  info "It replaces Superpowers + GSD Core + skills.sh with a single batteries-included pack."
  info "Official install path (verified 2026-06-30):"
  echo ""
  echo "  # In Claude Code:"
  echo "  /plugin marketplace add https://github.com/affaan-m/ECC"
  echo "  /plugin install ecc@ecc"
  echo ""
  echo "  # Or the CLI installer (any harness):"
  echo "  npx ecc-install --profile full --target claude   # or: codex, opencode, cursor"
  echo ""
  warn "ECC is NOT part of the default devstrata stack. It's an explicit opt-in (--with-ecc)."
  warn "Installing ECC supersedes the Superpowers + GSD + skills.sh skills you just installed."
  warn "Pick ONE path: the composed default stack, OR ECC. Don't layer both (causes skill conflicts)."
  warn "To install ECC, run the commands above in your agent. devstrata does not auto-install it"
  warn "(ECC is a plugin/marketplace install, not a CLI install — must be done inside the agent)."
  echo ""
  ok "ECC install path printed. Run the commands above in Claude Code / your agent."
fi

# ── Full profile additions ────────────────────────────────────────────────────

if [[ "$PROFILE" == "full" || "$PROFILE" == "pro" ]]; then

  step "Step 7: HelixDB (graph+vector database)"

  if command -v helix &>/dev/null; then
    ok "HelixDB CLI already installed"
  else
    info "Installing HelixDB CLI..."
    curl -sSL "https://install.helix-db.com" | bash || warn "HelixDB install failed — check https://github.com/helixdb/helix-db"
  fi

  if command -v helix &>/dev/null; then
    helix start dev --disk 2>/dev/null || warn "HelixDB could not start — check Docker"
    ok "HelixDB started on :6969"
  fi

  step "Step 8: Mem0 (persistent agent memory)"

  info "Installing Mem0 Python library..."
  pip install "mem0ai[nlp]" --break-system-packages 2>/dev/null || pip install "mem0ai[nlp]"
  python -m spacy download en_core_web_sm 2>/dev/null || warn "spacy model download failed"

  info "Installing Mem0 CLI..."
  npm install -g @mem0/cli 2>/dev/null || warn "Mem0 CLI install failed"

  info "Installing Mem0 skills..."
  npx skills add https://github.com/mem0ai/mem0 --skill mem0 2>/dev/null || warn "mem0 skill install failed"

  # KI-012 mitigation: pre-pull the Mem0 Docker image now so first run works
  # even on restricted networks (the image is already local by the time you need it).
  if command -v docker &>/dev/null && [ -f "$SCRIPT_DIR/configs/docker-compose.yml" ]; then
    info "Pre-pulling Mem0 Docker image (KI-012 mitigation — avoids first-run network dependency)..."
    docker compose -f "$SCRIPT_DIR/configs/docker-compose.yml" pull mem0 2>/dev/null \
      && ok "Mem0 image pre-pulled" \
      || warn "Pre-pull failed — first-run docker compose up will need network (KI-012)"
  fi

  warn "Mem0 self-hosted server: run 'cd /tmp/mem0/server && make bootstrap' manually"
  warn "Or: copy configs/docker-compose.yml to your project and run 'docker compose up -d'"
  warn "Then get your API key: mem0 init   (or: mem0 init --agent --agent-caller <name> for agent signup)"
  warn "Set it: export MEM0_API_KEY=<key-from-make-bootstrap-or-mem0-init>"
  warn "See docs/INSTRUCTIONS.md Step 3 for full Mem0 setup"

  step "Step 9: Shannon (AI pentester)"

  if command -v docker &>/dev/null; then
    info "Shannon available via npx — run: npx @keygraph/shannon setup"
    warn "Shannon Lite is AGPL-3.0 — review license for commercial use"
    warn "Run 'npx @keygraph/shannon setup' manually to configure credentials"
  else
    warn "Shannon requires Docker — install Docker first"
  fi

fi

# ── Pro profile additions ─────────────────────────────────────────────────────

if [[ "$PROFILE" == "pro" ]]; then

  step "Step 10: Hermes Agent (self-improving shell)"

  if command -v hermes &>/dev/null; then
    ok "Hermes already installed"
  else
    info "Installing Hermes..."
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash || warn "Hermes install failed"
    ok "Hermes installed — run 'hermes setup' to configure"
  fi

  step "Step 11: Obsidian"
  info "Download Obsidian from https://obsidian.md (free, no account required)"
  info "Create vault at ~/obsidian-vault/"
  info "Install plugins: Dataview, Kanban, Tasks, Git, Templater"
  warn "Manual step — Obsidian has no CLI installer"

  step "Step 12: Ollama 32b model (heavy tasks)"
  # The 32b model is ~20GB. Offer to pull it but don't force it (long download).
  if command -v ollama &>/dev/null; then
    if ollama list 2>/dev/null | grep -q "qwen2.5-coder:32b"; then
      ok "qwen2.5-coder:32b already pulled"
    else
      # Robust read: if stdin is not a tty / exhausted, default to "n"
      REPLY="n"
      if [ -t 0 ]; then
        read -p "  Pull qwen2.5-coder:32b now? (~20GB, Y/n) " -n 1 -r || true
      else
        warn "Non-interactive terminal — skipping 32b pull. Run later: ollama pull qwen2.5-coder:32b"
      fi
      echo
      if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        info "Pulling qwen2.5-coder:32b (this will take a while)..."
        ollama pull qwen2.5-coder:32b && ok "32b model pulled" || warn "Pull failed — run later: ollama pull qwen2.5-coder:32b"
      fi
    fi
  else
    warn "Ollama not installed — pull qwen2.5-coder:32b after installing Ollama"
  fi

fi

# ── Copy config templates ─────────────────────────────────────────────────────

step "Config templates"

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if ([ ! -f "AGENTS.md" ] || [ "$FORCE" == "true" ]) && [ -f "$SCRIPT_DIR/configs/AGENTS.md.template" ]; then
  # Back up existing AGENTS.md before --force clobbers it (prevent data loss)
  if [ "$FORCE" == "true" ] && [ -f "AGENTS.md" ]; then
    cp AGENTS.md "AGENTS.md.bak.$(date +%s)"
    info "Backed up existing AGENTS.md to AGENTS.md.bak.* (your edits are preserved)"
  fi
  cp "$SCRIPT_DIR/configs/AGENTS.md.template" AGENTS.md
  # Profile-aware trimming: lite users don't have Mem0 or HelixDB.
  # Strip those lines so the template doesn't reference tools they don't have.
  if [ "$PROFILE" == "lite" ]; then
    # Remove Mem0 + HelixDB references for lite (they're not installed)
    sed -i.bak '/Agent memory: Mem0/d' AGENTS.md
    sed -i.bak '/Entity store: HelixDB/d' AGENTS.md
    sed -i.bak '/Recall past decisions.*mem0 search/d' AGENTS.md
    rm -f AGENTS.md.bak
    # Add lite-specific note
    echo "" >> AGENTS.md
    echo "<!-- lite profile: Mem0 + HelixDB not installed. Upgrade to --full to enable agent memory. -->" >> AGENTS.md
    ok "AGENTS.md created (lite-trimmed — no Mem0/HelixDB references)"
  else
    ok "AGENTS.md created from template — edit with your project details"
  fi
fi

if [ ! -f ".graphifyignore" ] && [ -f "$SCRIPT_DIR/configs/.graphifyignore.template" ]; then
  cp "$SCRIPT_DIR/configs/.graphifyignore.template" .graphifyignore
  ok ".graphifyignore created from template"
fi

if [ ! -f "headroom.env" ] && [ -f "$SCRIPT_DIR/configs/headroom.env.template" ]; then
  cp "$SCRIPT_DIR/configs/headroom.env.template" headroom.env
  ok "headroom.env created from template — edit with your LLM backend + gitignore it"
fi

# .gitignore — protects secrets + backups from being committed
if [ ! -f ".gitignore" ] && [ -f "$SCRIPT_DIR/configs/.gitignore.template" ]; then
  cp "$SCRIPT_DIR/configs/.gitignore.template" .gitignore
  ok ".gitignore created (protects headroom.env, *.bak.*, graphify-out/, .shannon/)"
fi

# docker-compose for --full and --pro (process supervision, KI-003 fix)
if [[ "$PROFILE" == "full" || "$PROFILE" == "pro" ]]; then
  if ([ ! -f "docker-compose.yml" ] || [ "$FORCE" == "true" ]) && [ -f "$SCRIPT_DIR/configs/docker-compose.yml" ]; then
    [ "$FORCE" == "true" ] && [ -f "docker-compose.yml" ] && cp docker-compose.yml "docker-compose.yml.bak.$(date +%s)" 2>/dev/null
    cp "$SCRIPT_DIR/configs/docker-compose.yml" docker-compose.yml
    ok "docker-compose.yml created — run 'docker compose up -d' for Mem0 supervision"
  fi
else
  # Downgrade to --lite: remove docker-compose.yml (lite doesn't run Mem0)
  if [ -f "docker-compose.yml" ]; then
    warn "Removing docker-compose.yml (not needed for --lite — Mem0 not installed)"
    mv docker-compose.yml "docker-compose.yml.bak.$(date +%s)" 2>/dev/null || rm docker-compose.yml
  fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────

# Compute the absolute path to the devstrata scripts dir, so next-steps work
# regardless of where the user ran install.sh from (their project dir vs repo root).
DEVSTRATA_DIR="$SCRIPT_DIR"

echo ""
echo "══════════════════════════════════════"
echo -e "${GREEN}devstrata $PROFILE install complete${NC}"
echo ""
echo "Next steps (run from this project directory):"
echo "  1. Verify:        bash $DEVSTRATA_DIR/scripts/doctor.sh"
echo "  2. Edit headroom.env with your LLM backend (then: source headroom.env)"
echo "  3. Edit AGENTS.md with your project context"
echo "  4. Edit .mcp.json to match your ports and paths"
echo "  5. Build graph:   graphify ."
if [[ "$PROFILE" == "full" || "$PROFILE" == "pro" ]]; then
  echo "  6. Start Mem0:    docker compose up -d"
  echo "  7. Start services: bash $DEVSTRATA_DIR/scripts/morning-startup.sh"
fi
if [[ "$PROFILE" == "pro" ]]; then
  echo "  8. Setup Hermes:  hermes setup --portal   (or: hermes setup)"
  echo "  9. Obsidian vault: create ~/obsidian-vault/ + set GRAPHIFY_OBSIDIAN_PATH"
  echo "  10. Pull 32b model: ollama pull qwen2.5-coder:32b   (~20GB, heavy tasks)"
fi
if [ "$WITH_ECC" == "true" ]; then
  echo "  → ECC (--with-ecc): run these in your agent to complete the ECC install:"
  echo "      /plugin marketplace add https://github.com/affaan-m/ECC"
  echo "      /plugin install ecc@ecc"
  echo "    (ECC replaces Superpowers + GSD + skills.sh — don't layer both)"
fi
echo ""
echo "Daily workflow (run from this project directory):"
echo "  Morning:      bash $DEVSTRATA_DIR/scripts/morning-startup.sh"
echo "  Evening:      bash $DEVSTRATA_DIR/scripts/end-of-day.sh"
echo "  Drift check:  bash $DEVSTRATA_DIR/scripts/update.sh"
echo ""
# Profile-aware upgrade path (don't tell a pro user to "upgrade" to full)
echo "Profile: --$PROFILE"
case "$PROFILE" in
  lite)
    echo "  To upgrade: bash $DEVSTRATA_DIR/scripts/install.sh --full  (adds HelixDB, Mem0, Shannon)"
    echo "              bash $DEVSTRATA_DIR/scripts/install.sh --pro   (adds Hermes, Obsidian)" ;;
  full)
    echo "  To upgrade: bash $DEVSTRATA_DIR/scripts/install.sh --pro   (adds Hermes, Obsidian)" ;;
  pro)
    echo "  This is the top profile. Stay current with: bash $DEVSTRATA_DIR/scripts/update.sh" ;;
esac
echo ""
