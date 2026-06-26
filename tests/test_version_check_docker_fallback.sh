#!/usr/bin/env bash
# test_version_check_docker_fallback.sh — verify version-check.sh shows running
# containers when no docker-compose.yml is in cwd (round 4 friction R4-1).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
VC="$REPO/scripts/version-check.sh"
FAIL=0

# 1. must not require docker-compose.yml to show docker info
if ! grep -q 'docker-compose.yml.*&&.*docker compose images' "$VC"; then
  echo "PASS: version-check.sh doesn't hard-require docker-compose.yml"
else
  echo "FAIL: version-check.sh requires docker-compose.yml (breaks when run from repo root)"
  FAIL=1
fi

# 2. must have a fallback to `docker ps` when no compose file
if grep -q 'docker ps.*format\|Running containers' "$VC"; then
  echo "PASS: version-check.sh falls back to docker ps when no compose file"
else
  echo "FAIL: version-check.sh has no docker ps fallback"
  FAIL=1
fi

# 3. must say "docker not installed" (not "not available") when docker is missing
if grep -q 'docker not installed' "$VC"; then
  echo "PASS: version-check.sh says 'docker not installed' (accurate)"
else
  echo "FAIL: version-check.sh says 'docker not available' (wrong — it IS available, just no compose file)"
  FAIL=1
fi

# 4. must tell user how to check a project's images
if grep -q 'cd your-project.*docker compose images\|To check a project' "$VC"; then
  echo "PASS: version-check.sh tells user how to check project images"
else
  echo "FAIL: version-check.sh doesn't guide user to project images"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1