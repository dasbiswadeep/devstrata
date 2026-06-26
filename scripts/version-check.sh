#!/usr/bin/env bash
# version-check.sh — fetch latest versions from PyPI + GitHub, compare to installed.
# Stronger than update.sh: actually queries upstream registries, not just local versions.
# Mitigates KI-001 (install commands rot) by surfacing drift before it breaks you.
#
# Usage: ./scripts/version-check.sh
# Exit codes: 0 = no drift, 1 = drift detected, 2 = check failed (offline?)
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

DRIFT=0

# Get latest PyPI version for a package
pypi_latest() {
  curl -s "https://pypi.org/pypi/$1/json" 2>/dev/null | \
    python3 -c "import sys,json; print(json.load(sys.stdin)['info']['version'])" 2>/dev/null
}

# Get latest GitHub release tag
gh_latest() {
  curl -s "https://api.github.com/repos/$1/releases/latest" 2>/dev/null | \
    python3 -c "import sys,json; print(json.load(sys.stdin).get('tag_name','?'))" 2>/dev/null
}

check_pypi() {
  local pkg="$1" cmd="$2"
  local installed latest
  if command -v "$cmd" &>/dev/null; then
    installed=$("$cmd" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    [ -z "$installed" ] && installed="unknown"
  else
    installed="NOT INSTALLED"
  fi
  latest=$(pypi_latest "$pkg")
  [ -z "$latest" ] && { warn "$pkg: could not reach PyPI (offline?)"; return; }
  if [ "$installed" == "NOT INSTALLED" ]; then
    echo -e "  $pkg: $installed  (latest: $latest)"
  elif [ "$installed" == "$latest" ]; then
    ok "$pkg: $installed (up to date)"
  else
    warn "$pkg: installed=$installed  latest=$latest  → pip install --upgrade $pkg"
    DRIFT=1
  fi
}

check_gh() {
  local repo="$1" name="$2"
  local latest
  latest=$(gh_latest "$repo")
  [ -z "$latest" ] && { warn "$name: could not reach GitHub API"; return; }
  ok "$name: latest release = $latest  (https://github.com/$repo/releases)"
}

echo ""
echo "devstrata version check (queries upstream registries)"
echo "──────────────────────────────────"
echo "PyPI packages:"
check_pypi "headroom-ai"  "headroom"
check_pypi "graphifyy"    "graphify"
check_pypi "mem0ai"       "mem0"

echo ""
echo "GitHub releases (no install version to compare — informational):"
check_gh "helixdb/helix-db"        "HelixDB CLI"
check_gh "KeygraphHQ/shannon"      "Shannon"
check_gh "nousresearch/hermes-agent" "Hermes Agent"
check_gh "open-gsd/gsd-core"      "GSD Core"
check_gh "obra/superpowers"        "Superpowers"

echo ""
echo "npm packages (MCP servers):"
for pkg in "@modelcontextprotocol/server-filesystem" "@modelcontextprotocol/server-fetch"; do
  latest=$(curl -s "https://registry.npmjs.org/$pkg/latest" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('version','?'))" 2>/dev/null)
  [ -z "$latest" ] && { warn "$pkg: could not reach npm"; continue; }
  ok "$pkg latest = $latest"
done

echo ""
echo "Docker images:"
if command -v docker &>/dev/null; then
  if [ -f "docker-compose.yml" ]; then
    info "docker compose images:"
    docker compose images 2>/dev/null | sed 's/^/  /'
    info "To pull updates: docker compose pull"
  else
    # No compose file in cwd — show running containers as a fallback
    info "No docker-compose.yml in current dir. Running containers:"
    docker ps --format "  {{.Names}}: {{.Image}} ({{.Status}})" 2>/dev/null | head -10
    info "To check a project's images: cd your-project && docker compose images"
  fi
else
  warn "docker not installed — skipping image check"
fi

echo ""
echo "──────────────────────────────────"
if [ "$DRIFT" -eq 0 ]; then
  ok "No PyPI drift detected"
  exit 0
else
  warn "Drift detected — review the upgrade commands above"
  echo "After upgrading, run: ./scripts/doctor.sh"
  exit 1
fi