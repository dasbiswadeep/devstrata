#!/usr/bin/env bash
# headroom-watchdog.sh — restart Headroom proxy if it died, or restart both
# Headroom + Ollama if Ollama went offline (Headroom loses its backend).
# Mitigates KI-010 (Headroom kills itself if Ollama goes offline).
#
# Run via cron / launchd / systemd every 2 minutes.
# Usage: ./scripts/headroom-watchdog.sh
# Or wire into launchd/systemd with the templates in configs/.
set -u

LOG="/tmp/devstrata-watchdog.log"
ts() { date "+%Y-%m-%d %H:%M:%S"; }

log() { echo "[$(ts)] $1" >> "$LOG"; echo "[$(ts)] $1"; }

# 1. Is Ollama up?
OLLAMA_UP=false
if curl -s http://localhost:11434/api/tags &>/dev/null; then
  OLLAMA_UP=true
fi

# 2. Is Headroom up?
HEADROOM_UP=false
if curl -s http://localhost:8787/health &>/dev/null; then
  HEADROOM_UP=true
fi

# 3. Decision matrix
if [ "$OLLAMA_UP" == "true" ] && [ "$HEADROOM_UP" == "true" ]; then
  # Both healthy — nothing to do
  exit 0
fi

if [ "$OLLAMA_UP" == "false" ]; then
  log "Ollama down — restarting Ollama"
  if command -v ollama &>/dev/null; then
    ollama serve &>/tmp/ollama.log &
    sleep 3
    if curl -s http://localhost:11434/api/tags &>/dev/null; then
      log "Ollama restarted OK"
      # Headroom needs restart too — it lost its backend
      if pgrep -f "headroom proxy" >/dev/null; then
        log "Restarting Headroom (lost its Ollama backend)"
        pkill -f "headroom proxy"
        sleep 1
      fi
    else
      log "Ollama failed to restart — check /tmp/ollama.log"
      exit 1
    fi
  else
    log "ollama command missing — cannot restart"
    exit 1
  fi
fi

if [ "$HEADROOM_UP" == "false" ] || [ "$OLLAMA_UP" == "false" ]; then
  log "Headroom down (or was restarted above) — starting Headroom proxy"
  if command -v headroom &>/dev/null; then
    headroom proxy --port 8787 &>/tmp/headroom.log &
    sleep 2
    if curl -s http://localhost:8787/health &>/dev/null; then
      log "Headroom restarted OK on :8787"
    else
      log "Headroom failed to restart — check /tmp/headroom.log"
      exit 1
    fi
  else
    log "headroom command missing — cannot restart"
    exit 1
  fi
fi

log "Watchdog recovery complete"
exit 0