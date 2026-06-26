#!/usr/bin/env bash
# test_headroom_env_key_warning.sh — verify headroom.env.template warns about
# the Graphify LLM key requirement (mock-drill friction #8).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ENV="$REPO/configs/headroom.env.template"
FAIL=0

# 1. must warn that Graphify needs an LLM key for non-code files
if grep -qi 'Graphify needs an LLM key\|no LLM API key found\|graphify.*LLM\|graphify.*api key' "$ENV"; then
  echo "PASS: headroom.env warns about Graphify LLM key requirement"
else
  echo "FAIL: headroom.env missing Graphify LLM key warning"
  FAIL=1
fi

# 2. must mention that a README counts as a doc file (so most projects need a key)
if grep -qi 'README.*doc\|README.*counts\|doc file' "$ENV"; then
  echo "PASS: headroom.env notes that README counts as a doc file"
else
  echo "FAIL: headroom.env missing README-as-doc note"
  FAIL=1
fi

# 3. must mention the Ollama-only workaround for Graphify
if grep -qi 'GRAPHIFY_OLLAMA\|graphify.*ollama' "$ENV"; then
  echo "PASS: headroom.env mentions Ollama workaround for Graphify"
else
  echo "FAIL: headroom.env missing Ollama workaround"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1