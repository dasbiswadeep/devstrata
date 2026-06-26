# Process Supervision — devstrata --full and --pro

> How to keep Headroom, HelixDB, Mem0, and Ollama running across reboots
> and crashes. Addresses KNOWN_ISSUES KI-003 (no process supervision).

---

## What's already supervised

| Process | Mechanism | Status |
|---|---|---|
| Mem0 (:3000) | `docker-compose.yml` — `restart: unless-stopped` + healthcheck | ✅ supervised |
| Headroom (:8787) | `morning-startup.sh` checks + starts | manual (per-day) |
| Ollama (:11434) | `morning-startup.sh` checks + starts | manual (per-day) |
| HelixDB (:6969) | `morning-startup.sh` checks + starts | manual (per-day) |

If you want true always-on supervision (survives reboot, auto-restart on crash),
wire each into your OS service manager using the templates in `configs/`.

---

## HelixDB (no official Docker image yet)

HelixDB does not ship a Docker image for the local dev server
(verified 2026-06-26 — see `docs/SOURCES.md`). It runs on the host via
`helix start dev --disk`. Use one of the templates below for supervision.

### macOS — launchd

```bash
# 1. Copy the plist into LaunchAgents
cp configs/com.helixdb.dev.plist ~/Library/LaunchAgents/

# 2. Edit the plist if your helix binary lives elsewhere (e.g. /opt/homebrew/bin)
#    Check: which helix

# 3. Load it
launchctl load ~/Library/LaunchAgents/com.helixdb.dev.plist

# 4. Verify
launchctl list | grep helixdb
curl http://localhost:6969/health

# 5. Stop / unload
launchctl unload ~/Library/LaunchAgents/com.helixdb.dev.plist
```

`KeepAlive: true` restarts HelixDB if it crashes. `RunAtLoad: true` starts it
at login. Logs go to `/tmp/helix-launchd.log`.

### Linux — systemd

```bash
# 1. Copy the unit file (requires root)
sudo cp configs/helixdb.service /etc/systemd/system/

# 2. Reload systemd
sudo systemctl daemon-reload

# 3. Enable + start
sudo systemctl enable --now helixdb

# 4. Verify
systemctl status helixdb
curl http://localhost:6969/health

# 5. Stop / disable
sudo systemctl disable --now helixdb
```

`Restart=always` with `RestartSec=5` restarts HelixDB 5s after any crash.

---

## Headroom proxy — launchd / systemd

Same pattern. Replace `ExecStart` with:
```
headroom proxy --port 8787
```

On macOS, create `~/Library/LaunchAgents/com.headroom.proxy.plist` with
`KeepAlive: true`. On Linux, copy the helixdb.service pattern and swap the
`ExecStart` line.

---

## Mem0 — already supervised via docker-compose

```bash
docker compose up -d        # starts Mem0 with restart: unless-stopped
docker compose ps           # verify
docker compose logs -f mem0 # tail
```

The healthcheck in `configs/docker-compose.yml` marks Mem0 unhealthy after 3
failed `/health` curls (30s interval). Docker restarts it automatically.

---

## Ollama — use the official service

Ollama ships its own service installer:
- macOS: the Ollama app auto-starts at login. No extra config needed.
- Linux: `systemctl status ollama` — the official install script registers it.

If `morning-startup.sh` reports Ollama down on macOS, just open the Ollama app.

---

## Why not put everything in docker-compose.yml?

HelixDB has no official Docker image yet. When one ships upstream, we'll add a
`helix` service block to `configs/docker-compose.yml` and this file shrinks.
Tracked in `docs/KNOWN_ISSUES.md` KI-003.