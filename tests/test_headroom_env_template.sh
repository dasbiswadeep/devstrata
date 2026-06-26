#!/usr/bin/env bash
# test_headroom_env_template.sh — verify headroom.env.template has all
# required LLM backend options + Headroom-specific settings, and contains
# NO real API keys (only placeholders).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ENV="$REPO/configs/headroom.env.template"
FAIL=0

# Required sections / settings
check_present() {
  if grep -q "$1" "$ENV"; then
    echo "PASS: headroom.env has $2"
  else
    echo "FAIL: headroom.env missing $2 ($1)"
    FAIL=1
  fi
}

check_present "OLLAMA_BASE_URL"      "Ollama base URL"
check_present "OLLAMA_MODEL"         "Ollama model"
check_present "ANTHROPIC_API_KEY"   "Anthropic API key placeholder"
check_present "OPENAI_API_KEY"       "OpenAI API key placeholder"
check_present "GEMINI_API_KEY"       "Gemini API key placeholder"
check_present "DEEPSEEK_API_KEY"    "DeepSeek API key placeholder"
check_present "HEADROOM_PROXY_PORT"  "Headroom proxy port"
check_present "HEADROOM_OUTPUT_SHAPER" "Output shaper toggle"
check_present "HEADROOM_EMBEDDER_RUNTIME" "Embedder runtime (M-series)"

# Must NOT contain a real-looking API key (sk- followed by 20+ alphanumeric chars)
if grep -qE 'sk-[a-zA-Z0-9]{20,}' "$ENV"; then
  echo "FAIL: headroom.env contains a real-looking API key (not a placeholder)"
  grep -nE 'sk-[a-zA-Z0-9]{20,}' "$ENV" | head -3 | sed 's/^/    /'
  FAIL=1
else
  echo "PASS: headroom.env contains only placeholder keys (sk-ant-... etc.)"
fi

# All real-provider API key lines must be commented out (they're templates).
# OLLAMA_API_KEY=ollama is allowed active — it's a placeholder (Ollama accepts any string).
ACTIVE_REAL_KEYS=$(grep -E '^\s*export.*API_KEY=' "$ENV" | grep -vE '^\s*#' | grep -vE 'API_KEY=ollama' | wc -l | tr -d ' ')
if [ "$ACTIVE_REAL_KEYS" -eq 0 ]; then
  echo "PASS: all real-provider API key exports are commented out (OLLAMA_API_KEY=ollama placeholder is OK)"
else
  echo "FAIL: $ACTIVE_REAL_KEYS real-provider API key lines are active (not commented)"
  FAIL=1
fi

# Must have an audit log setting (SECURITY.md T2 mitigation)
if grep -q "AUDIT_LOG" "$ENV"; then
  echo "PASS: headroom.env has audit log setting"
else
  echo "FAIL: headroom.env missing audit log setting"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1