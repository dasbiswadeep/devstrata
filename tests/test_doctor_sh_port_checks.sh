#!/usr/bin/env bash
# test_doctor_sh_port_checks.sh — verify doctor.sh checks all expected ports
# and gives the right fix command for each. Static analysis (no services needed).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DOCTOR="$REPO/scripts/doctor.sh"
FAIL=0

# doctor.sh must health-check these ports
check_port() {
  local port="$1"
  local label="$2"
  if grep -q "localhost:$port" "$DOCTOR"; then
    echo "PASS: doctor.sh checks $label on :$port"
  else
    echo "FAIL: doctor.sh does not check $label on :$port"
    FAIL=1
  fi
}

check_port 8787 "Headroom"
check_port 6969 "HelixDB"
check_port 3000 "Mem0"
check_port 11434 "Ollama"

# doctor.sh must have a fix command for each failing service
check_fix() {
  local pattern="$1"
  local label="$2"
  if grep -q "$pattern" "$DOCTOR"; then
    echo "PASS: doctor.sh has fix command for $label"
  else
    echo "FAIL: doctor.sh missing fix command for $label"
    FAIL=1
  fi
}

check_fix "headroom proxy"  "Headroom"
check_fix "helix start dev"  "HelixDB"
check_fix "docker compose"  "Mem0"
check_fix "ollama serve\|ollama pull" "Ollama"

# doctor.sh must check Graphify graph freshness (days-old calculation)
if grep -q "DAYS_OLD" "$DOCTOR"; then
  echo "PASS: doctor.sh checks Graphify graph freshness"
else
  echo "FAIL: doctor.sh does not check Graphify graph freshness"
  FAIL=1
fi

# doctor.sh must check for qwen2.5-coder:14b (recommended model)
if grep -q "qwen2.5-coder:14b" "$DOCTOR"; then
  echo "PASS: doctor.sh checks for recommended Ollama model"
else
  echo "FAIL: doctor.sh does not check for recommended model"
  FAIL=1
fi

# doctor.sh must check skills directories (opencode, claude, hermes)
for dir in "opencode/skills" "claude/skills" "hermes/skills"; do
  if grep -q "$dir" "$DOCTOR"; then
    echo "PASS: doctor.sh checks $dir"
  else
    echo "FAIL: doctor.sh does not check $dir"
    FAIL=1
  fi
done

# doctor.sh must reference the morning-startup + update scripts at the end
if grep -q "morning-startup.sh" "$DOCTOR"; then
  echo "PASS: doctor.sh points to morning-startup.sh"
else
  echo "FAIL: doctor.sh does not point to morning-startup.sh"
  FAIL=1
fi
if grep -q "update.sh" "$DOCTOR"; then
  echo "PASS: doctor.sh points to update.sh"
else
  echo "FAIL: doctor.sh does not point to update.sh"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1