# devstrata — `--full` profile

> **16GB+ RAM · adds persistent memory + graph DB + security scanning**
> For developers who want agents that remember and code that's pentested.

---

## What this profile adds over `--lite`

| # | Tool | Purpose | Port | RAM |
|---|---|---|---|---|
| 7 | HelixDB | Graph + vector + relational DB (Rust, OLTP) | 6969 | ~800MB |
| 8 | Mem0 | Long-term agent memory (self-hosted Docker) | 3000 | ~1.5GB |
| 10 | Shannon | AI pentester, prompt-injection guard (per-PR) | ephemeral | on-demand |
| + | MCP servers | + helix, + mem0 (6 servers total) | via .mcp.json | on-demand |
| + | skills.sh | + mem0, mem0-integrate, mem0-cli | loaded into context | 0 |

**Total active RAM: ~12GB** (comfortable at 16GB; tight at 12GB with Ollama 14b loaded).

## What this profile does NOT install

- Hermes Agent (self-improving shell) → use `--pro`
- Obsidian vault sync → use `--pro`

---

## Prerequisites (in addition to --lite)

| Tool | Min version | Why | Install |
|---|---|---|---|
| Docker | any recent | Mem0 self-hosted stack, Shannon worker | Docker Desktop / `apt install docker.io` |
| Docker Compose | v2 | Mem0 process supervision | ships with Docker Desktop |
| jq | any | .mcp.json generation (keeps helix + mem0 for full) | `brew install jq` / `apt install jq` |
| HelixDB CLI | latest | `helix start dev --disk` | `curl -sSL "https://install.helix-db.com" \| bash` |
| Anthropic API key | — | Shannon (Claude models officially supported) | set `ANTHROPIC_API_KEY` |

```bash
docker --version && docker compose version
curl -sSL "https://install.helix-db.com" | bash
```

---

## Install (one command)

```bash
# Clone (replace dasbiswadeep with your fork if you forked it)
git clone https://github.com/dasbiswadeep/devstrata.git
cd devstrata
./scripts/install.sh --full
```

install.sh does everything in `--lite`, plus:
1. Installs HelixDB CLI (`curl -sSL "https://install.helix-db.com" | bash`)
2. Starts HelixDB local (`helix start dev --disk`) on :6969
3. Installs Mem0 Python library + CLI + skills
4. Checks Docker is available for Shannon
5. Generates `.mcp.json` with **6 servers** (+ helix, mem0)
6. Copies `docker-compose.yml` for Mem0 supervision

## Manual install (additions over lite)

```bash
# ── HelixDB ──────────────────────────────────────────────────────────────
curl -sSL "https://install.helix-db.com" | bash
helix start dev --disk                 # port 6969, persistent
helix init                             # scaffold helix.toml in your project
curl http://localhost:6969/health       # verify

# ── Mem0 ────────────────────────────────────────────────────────────────
# Option A: Self-hosted server (recommended — has dashboard + auth)
git clone https://github.com/mem0ai/mem0.git /tmp/mem0
cd /tmp/mem0/server && make bootstrap   # starts stack, creates admin, issues API key
# Dashboard: http://localhost:3000

# Option B: Python library (no Docker)
pip install "mem0ai[nlp]"
python -m spacy download en_core_web_sm

# Option C: CLI
npm install -g @mem0/cli
mem0 init --agent --agent-caller myproject

# Mem0 skills
npx skills add https://github.com/mem0ai/mem0 --skill mem0
npx skills add https://github.com/mem0ai/mem0 --skill mem0-cli
npx skills add https://github.com/mem0ai/mem0 --skill mem0-integrate

# ── Shannon ──────────────────────────────────────────────────────────────
# Requires Docker + Anthropic API key
export ANTHROPIC_API_KEY=sk-ant-...
npx @keygraph/shannon setup            # one-time wizard

# ── .mcp.json with 6 servers (keep helix + mem0) ─────────────────────────
cp /path/to/devstrata/configs/.mcp.json.template .mcp.json   # all 6 servers

# ── Process supervision for Mem0 ────────────────────────────────────────
cp /path/to/devstrata/configs/docker-compose.yml docker-compose.yml
docker compose up -d                   # Mem0 auto-restarts on crash
```

## Post-install setup

```bash
# 1. Start HelixDB (if not already running)
helix start dev --disk

# 2. Start Mem0 via docker compose (auto-restart)
docker compose up -d

# 3. Set Mem0 user-id (scope per-project — never mix)
export MEM0_USER_ID=myproject
mem0 init

# 4. Run Shannon on your first PR
npx @keygraph/shannon start -u http://localhost:8000 -r . -w first-scan

# 5. Verify the whole stack
./scripts/doctor.sh

# Expected output:
# ✓ Headroom proxy running on :8787
# ✓ HelixDB responding on :6969
# ✓ Mem0 server responding on :3000
# ✓ Ollama running — qwen2.5-coder:14b loaded
# ✓ Graphify graph exists
# ✓ MCP servers: filesystem ✓ git ✓ fetch ✓ helix ✓ mem0 ✓ graphify ✓
```

## Process supervision

| Process | Mechanism | Setup |
|---|---|---|
| Mem0 (:3000) | `docker-compose.yml` — `restart: unless-stopped` + healthcheck | `docker compose up -d` (auto) |
| HelixDB (:6969) | macOS launchd OR Linux systemd | See `docs/SUPERVISION.md` |
| Headroom (:8787) | `morning-startup.sh` or launchd | See `docs/SUPERVISION.md` |
| Ollama (:11434) | native service (macOS app / Linux systemd) | auto |

```bash
# macOS — HelixDB via launchd
cp configs/com.helixdb.dev.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.helixdb.dev.plist

# Linux — HelixDB via systemd
sudo cp configs/helixdb.service /etc/systemd/system/
sudo systemctl enable --now helixdb
```

## Shannon schedule

| When | Why |
|---|---|
| Every PR | Catch vulns before merge — non-negotiable for any code with PII |
| Pre-release | Full audit before shipping |
| New MCP server added | Attack surface changed |
| New external repo Graphified | Prompt-injection risk |
| Monthly | Baseline health check |

```bash
# Per-PR scan
npx @keygraph/shannon start \
  -u http://localhost:8000 \
  -r . \
  -w pr-$(git branch --show-current)

npx @keygraph/shannon logs pr-$(git branch --show-current)
# Report: ~/.shannon/workspaces/pr-*/deliverables/
```

> **Shannon is AGPL-3.0.** For internal dev use, AGPL has no practical impact.
> For commercial SaaS, review terms or contact shannon@keygraph.io for a commercial license.

## Daily workflow

```bash
# Morning — start Headroom + HelixDB + Ollama; check graph freshness
./scripts/morning-startup.sh

# Work — query codebase + recall decisions
graphify query "where is X configured?"
mem0 search "decision about X" --user-id myproject
helix query dev --file helix/schema/query.json

# Before PR — run Shannon
npx @keygraph/shannon start -u http://localhost:8000 -r . -w pr-...

# Evening — refresh graph, capture decisions to Mem0
./scripts/end-of-day.sh
mem0 add "Decided to use X for Y because Z" --user-id myproject

# Weekly — drift check
./scripts/update.sh
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| HelixDB won't start | `helix start dev --foreground` to see logs; check port 6969 not in use |
| Mem0 not responding on :3000 | `docker compose ps`, `docker compose logs mem0`; first-run pulls images (needs internet — KI-012) |
| Shannon fails to start | Docker must be running; `ANTHROPIC_API_KEY` must be set; ~1–1.5h per scan |
| Mem0 memories cross-contaminated | Always pass `--user-id <project>`; never use a shared user-id across projects |
| `helix: command not found` | `curl -sSL "https://install.helix-db.com" \| bash`, restart shell |
| HelixDB data lost after restart | You used `helix start dev` (in-memory). Use `helix start dev --disk` for persistence |

## Upgrade path

```bash
# Full → Pro (adds Hermes, Obsidian, mattpocock skills)
./scripts/install.sh --pro
```

## What you give up by choosing full (not pro)

- **No self-improving agent.** No Hermes, no learning loop, no Telegram dispatch.
- **No Obsidian sync.** Graphify can't export to a knowledge vault.
- **No 32b model headroom.** Full uses qwen2.5-coder:14b (~9GB). Pro uses 32b (~20GB) for heavy tasks.