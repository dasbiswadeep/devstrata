#!/usr/bin/env bash
# agent-isolate.sh — isolate Hermes and OpenCode config dirs so running both
# doesn't cause skill config conflicts. Mitigates KI-006.
#
# The problem: both agents read skills from overlapping default dirs, and
# installing Superpowers into both can cause version/skill-list conflicts.
#
# The fix: give each agent its own skills + config dir, and symlink only the
# skills you actually want shared. This script sets that up.
#
# Usage: ./scripts/agent-isolate.sh
set -u

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }

OPENCODE_DIR="$HOME/.config/opencode"
CLAUDE_DIR="$HOME/.claude"
HERMES_DIR="$HOME/.hermes"

echo ""
echo "devstrata agent isolation (KI-006 mitigation)"
echo "──────────────────────────────────"
echo "Prevents Hermes + OpenCode skill conflicts by keeping skills separate."
echo ""

# 1. Ensure each agent has its own skills dir
for d in "$OPENCODE_DIR/skills" "$CLAUDE_DIR/skills" "$HERMES_DIR/skills"; do
  if [ -d "$d" ] || mkdir -p "$d" 2>/dev/null; then
    ok "skills dir exists: $d"
  else
    warn "could not create $d (agent not installed?)"
  fi
done

# 2. Detect if skills are shared (same inode = symlinked or same dir)
if [ -L "$OPENCODE_DIR/skills" ] && [ "$(readlink "$OPENCODE_DIR/skills")" == "$HERMES_DIR/skills" ]; then
  warn "OpenCode skills is a symlink to Hermes skills — this is the conflict source"
  echo "  Unlinking so they're independent..."
  rm "$OPENCODE_DIR/skills"
  mkdir -p "$OPENCODE_DIR/skills"
  ok "OpenCode skills now independent"
fi

# 3. Create a shared-skill registry file listing which skills each agent has
REGISTRY="$HOME/.config/devstrata/agent-skills-registry.md"
mkdir -p "$(dirname "$REGISTRY")"
{
  echo "# devstrata agent skills registry"
  echo ""
  echo "> Which skills are installed in which agent. Maintained by agent-isolate.sh."
  echo "> To share a skill across agents, install it in each separately."
  echo ""
  echo "| Skill | OpenCode | Claude Code | Hermes |"
  echo "|---|---|---|---|"
  for agent_dir in "$OPENCODE_DIR/skills" "$CLAUDE_DIR/skills" "$HERMES_DIR/skills"; do
    [ -d "$agent_dir" ] || continue
    for skill_dir in "$agent_dir"/*/; do
      [ -d "$skill_dir" ] || continue
      skill=$(basename "$skill_dir")
      echo "| $skill | $([ -d "$OPENCODE_DIR/skills/$skill" ] && echo ✓ || echo —) | $([ -d "$CLAUDE_DIR/skills/$skill" ] && echo ✓ || echo —) | $([ -d "$HERMES_DIR/skills/$skill" ] && echo ✓ || echo —) |"
    done
  done | sort -u
} > "$REGISTRY"
ok "Registry written: $REGISTRY"

echo ""
echo "Recommendation (pick ONE primary):"
echo "  • Hermes   — self-improvement, Telegram, scheduling, cron"
echo "  • OpenCode — fast, lightweight, skills.sh-native coding"
echo "  • Claude Code — Anthropic-ecosystem plugin marketplace"
echo ""
echo "Keep the other(s) as occasional alternatives. Don't run both simultaneously"
echo "in the same project — they'll fight over .gsd/STATE.md."
echo ""
info "See registry: $REGISTRY"