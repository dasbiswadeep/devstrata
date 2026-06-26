#!/usr/bin/env bash
# test_yaml_valid.sh — docker-compose.yml + shannon YAML are valid YAML.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

validate() {
  local f="$1"
  if python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$f" 2>/dev/null; then
    echo "PASS: yaml $(basename "$f")"
  else
    echo "FAIL: yaml $(basename "$f") — invalid (pyyaml not installed? install: pip install pyyaml)"
    FAIL=1
  fi
}

validate "$REPO/configs/docker-compose.yml"

# Shannon config (if present in configs/) — not required for the core stack.
if [ -f "$REPO/configs/shannon-config.yaml" ]; then
  validate "$REPO/configs/shannon-config.yaml"
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1