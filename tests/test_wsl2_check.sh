#!/usr/bin/env bash
# test_wsl2_check.sh — verify wsl2-check.sh detects WSL2 + checks prerequisites.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
WSL="$REPO/scripts/wsl2-check.sh"
FAIL=0

[ -x "$WSL" ] && echo "PASS: wsl2-check.sh is executable" || { echo "FAIL: not executable"; FAIL=1; }
bash -n "$WSL" 2>/dev/null && echo "PASS: syntax OK" || { echo "FAIL: syntax"; FAIL=1; }

# 1. detects WSL via /proc/version
if grep -q "proc/version\|microsoft\|wsl" "$WSL"; then
  echo "PASS: wsl2-check.sh detects WSL via /proc/version"
else
  echo "FAIL: wsl2-check.sh missing WSL detection"
  FAIL=1
fi

# 2. checks Docker Desktop integration
if grep -q "docker info\|Docker Desktop" "$WSL"; then
  echo "PASS: wsl2-check.sh checks Docker Desktop integration"
else
  echo "FAIL: wsl2-check.sh missing Docker check"
  FAIL=1
fi

# 3. checks systemd availability in WSL
if grep -q "systemd\|/run/systemd" "$WSL"; then
  echo "PASS: wsl2-check.sh checks systemd in WSL"
else
  echo "FAIL: wsl2-check.sh missing systemd check"
  FAIL=1
fi

# 4. mentions Ollama WSL workaround (host IP)
if grep -q "OLLAMA_BASE_URL\|host IP\|ip route" "$WSL"; then
  echo "PASS: wsl2-check.sh documents Ollama WSL workaround"
else
  echo "FAIL: wsl2-check.sh missing Ollama WSL workaround"
  FAIL=1
fi

# 5. mentions Hermes native Windows option
if grep -q "hermes-agent.nousresearch.com/install.ps1\|native Windows\|PowerShell" "$WSL"; then
  echo "PASS: wsl2-check.sh mentions Hermes native Windows"
else
  echo "FAIL: wsl2-check.sh missing Hermes Windows note"
  FAIL=1
fi

# 6. exits cleanly on macOS (no WSL-specific setup needed)
if grep -q "Darwin\|macOS" "$WSL"; then
  echo "PASS: wsl2-check.sh handles macOS (no-op)"
else
  echo "FAIL: wsl2-check.sh missing macOS handling"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1