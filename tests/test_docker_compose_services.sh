#!/usr/bin/env bash
# test_docker_compose_services.sh — verify docker-compose.yml has the expected
# service, ports, restart policy, and healthcheck.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE="$REPO/configs/docker-compose.yml"
FAIL=0

if ! python3 -c "import yaml" 2>/dev/null; then
  echo "SKIP: pyyaml not installed — cannot parse docker-compose.yml"
  exit 0
fi

# Parse and check
python3 - <<'EOF' >&/dev/null
import yaml, sys
with open("$COMPOSE") as f:
    d = yaml.safe_load(f)
EOF

# 1. mem0 service must exist
if python3 -c "import yaml; d=yaml.safe_load(open('$COMPOSE')); assert 'mem0' in d['services']" 2>/dev/null; then
  echo "PASS: docker-compose.yml has mem0 service"
else
  echo "FAIL: docker-compose.yml missing mem0 service"
  FAIL=1
fi

# 2. mem0 must expose port 3000
if python3 -c "import yaml; d=yaml.safe_load(open('$COMPOSE')); assert '3000' in str(d['services']['mem0']['ports'])" 2>/dev/null; then
  echo "PASS: mem0 exposes port 3000"
else
  echo "FAIL: mem0 does not expose port 3000"
  FAIL=1
fi

# 3. mem0 must have restart: unless-stopped (or restart: always)
RESTART=$(python3 -c "import yaml; d=yaml.safe_load(open('$COMPOSE')); print(d['services']['mem0'].get('restart',''))" 2>/dev/null)
if [ "$RESTART" == "unless-stopped" ] || [ "$RESTART" == "always" ]; then
  echo "PASS: mem0 has restart policy: $RESTART"
else
  echo "FAIL: mem0 missing restart policy (got: '$RESTART')"
  FAIL=1
fi

# 4. mem0 must have a healthcheck
if python3 -c "import yaml; d=yaml.safe_load(open('$COMPOSE')); assert 'healthcheck' in d['services']['mem0']" 2>/dev/null; then
  echo "PASS: mem0 has a healthcheck"
else
  echo "FAIL: mem0 missing healthcheck"
  FAIL=1
fi

# 5. healthcheck must hit /health endpoint
if grep -q "/health" "$COMPOSE"; then
  echo "PASS: healthcheck hits /health"
else
  echo "FAIL: healthcheck does not hit /health"
  FAIL=1
fi

# 6. mem0 must have a named volume (data persistence)
if python3 -c "import yaml; d=yaml.safe_load(open('$COMPOSE')); assert 'volumes' in d and len(d['volumes']) > 0" 2>/dev/null; then
  echo "PASS: docker-compose.yml defines named volumes"
else
  echo "FAIL: docker-compose.yml missing named volumes"
  FAIL=1
fi

# 7. compose file must reference host.docker.internal (so Mem0 can reach Ollama on host)
if grep -q "host.docker.internal" "$COMPOSE"; then
  echo "PASS: mem0 can reach host services via host.docker.internal"
else
  echo "FAIL: mem0 cannot reach host (missing host.docker.internal)"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1