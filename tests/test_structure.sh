#!/usr/bin/env bash
# test_structure.sh — verify all expected files and directories exist.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

check() {
  if [ -e "$REPO/$1" ]; then
    echo "PASS: exists $1"
  else
    echo "FAIL: missing $1"
    FAIL=1
  fi
}

# Top-level
check "README.md"
check "CLAUDE.md"
check "LICENSE"

# docs/ — the 8 core docs + SOURCES + SUPERVISION
for d in ARCHITECTURE SKILLS GUIDING_PRINCIPLES INSTRUCTIONS SECURITY BACKENDS \
         KNOWN_ISSUES MEMORY_DOMAINS SOURCES SUPERVISION; do
  check "docs/$d.md"
done

# scripts/ — 12 scripts (5 original + 7 mitigation scripts)
for s in install.sh doctor.sh morning-startup.sh end-of-day.sh update.sh test.sh \
         sync-memory.sh recommend-profile.sh version-check.sh headroom-watchdog.sh \
         validate-mcp.sh agent-isolate.sh wsl2-check.sh; do
  check "scripts/$s"
done

# configs/ — 9 templates (original + Headroom supervision + watchdog + gitignore)
check "configs/AGENTS.md.template"
check "configs/.mcp.json.template"
check "configs/.graphifyignore.template"
check "configs/headroom.env.template"
check "configs/.gitignore.template"
check "configs/docker-compose.yml"
check "configs/com.helixdb.dev.plist"
check "configs/helixdb.service"
check "configs/com.devstrata.headroom.proxy.plist"
check "configs/com.devstrata.headroom-watchdog.plist"
check "configs/headroom-proxy.service"
check "configs/headroom-watchdog.timer"

# Top-level .gitignore (protects the devstrata repo itself)
check ".gitignore"

# profiles/ — 3 PROFILE.md (no per-profile .mcp.json anymore — generated)
for p in lite full pro; do
  check "profiles/$p/PROFILE.md"
done

# tests/
check "tests/README.md"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1