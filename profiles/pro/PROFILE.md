# devstrata — `--pro` profile

> **24GB+ RAM · M-series Mac recommended · full stack + self-improving agent + PKM**
> For developers who want the agent to learn, dispatch from Telegram, and sync to Obsidian.

---

## What this profile adds over `--full`

| # | Tool | Purpose | Port | RAM |
|---|---|---|---|---|
| 11 | Hermes Agent | Self-improving shell, 200+ models, Telegram/Slack gateway | TUI + gateway | ~300MB |
| + | Obsidian | Local-first knowledge vault, graph view | desktop app | 0 |
| + | skills.sh | + mattpocock/skills (triage, to-prd, diagnose, prototype, teach) | loaded into context | 0 |
| + | Graphify --obsidian | Export codebase graph to vault | on-demand | 0 |
| + | LLM | Mix of Ollama local (32b heavy) + cloud fallback | 11434 | ~20GB |

**Total active RAM: ~23GB** (comfortable at 24GB+; the 32b model is the bulk).

## Hardware recommendation

- **Minimum:** 24GB unified RAM
- **Recommended:** M-series Mac (Apple Silicon) — Hermes + Obsidian run best on macOS
- **LLM:** qwen2.5-coder:32b for heavy tasks (~20GB), qwen2.5-coder:14b for daily (~9GB)
- **Cloud fallback:** Set `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` in `headroom.env` for when local model can't fit

> On 16GB, the 32b model will swap to disk and HelixDB may OOM. Use `--full` instead, or use cloud LLM backends.

---

## Prerequisites (in addition to --full)

| Tool | Min version | Why | Install |
|---|---|---|---|
| Hermes | latest | Self-improving agent shell | `curl -fsSL https://hermes-agent.nousresearch.com/install.sh \| bash` |
| Obsidian | any | Knowledge vault (free, no account) | download from https://obsidian.md |
| (optional) Nous Portal | — | 300+ models + tool gateway under one sub | `hermes setup --portal` |

```bash
# Hermes
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
source ~/.bashrc   # or ~/.zshrc
hermes             # verify it starts

# Obsidian — manual download from https://obsidian.md
```

---

## Install (one command)

```bash
# Clone (replace dasbiswadeep with your fork if you forked it)
git clone https://github.com/dasbiswadeep/devstrata.git
cd devstrata
./scripts/install.sh --pro
```

install.sh does everything in `--full`, plus:
1. Installs Hermes Agent (`curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash`)
2. Prints Obsidian setup instructions (manual download — no CLI installer)
3. Installs mattpocock/skills (triage, to-prd, diagnose, prototype, teach)
4. Pulls qwen2.5-coder:32b if Ollama is available (heavy model for pro workloads)

## Manual install (additions over full)

```bash
# ── Hermes Agent ─────────────────────────────────────────────────────────
# Linux / macOS / WSL2 / Termux:
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
source ~/.bashrc

# Windows native (PowerShell):
# iex (irm https://hermes-agent.nousresearch.com/install.ps1)

hermes setup               # guided wizard
# or
hermes setup --portal      # Nous Portal (300+ models + tool gateway)

hermes model               # pick a model interactively
# or explicit:
hermes model ollama:qwen2.5-coder:14b    # local, daily
hermes model ollama:qwen2.5-coder:32b    # local, heavy tasks

# Connect to Mem0 + HelixDB
hermes config set mem0.url http://localhost:3000
hermes config set helix.url http://localhost:6969

# Migrate from OpenClaw if coming from it
hermes claw migrate

# ── mattpocock skills ─────────────────────────────────────────────────────
npx skillsadd mattpocock/skills    # triage, to-prd, diagnose, prototype, teach

# ── Ollama 32b model (heavy tasks) ────────────────────────────────────────
ollama pull qwen2.5-coder:32b     # ~20GB

# ── Obsidian ─────────────────────────────────────────────────────────────
# 1. Download from https://obsidian.md (free, no account)
# 2. Create vault at ~/obsidian-vault/
# 3. Install plugins: Dataview, Kanban, Tasks, Git, Templater, Excalidraw
# 4. Link Graphify:
export GRAPHIFY_OBSIDIAN_PATH=~/obsidian-vault/codebase-graphs/
graphify . --obsidian
```

## Post-install setup

```bash
# 1. Pull the 32b model (heavy tasks)
ollama pull qwen2.5-coder:32b

# 2. Configure Hermes
hermes setup --portal      # or: hermes setup (BYO keys)
hermes model ollama:qwen2.5-coder:14b
hermes config set mem0.url http://localhost:3000
hermes config set helix.url http://localhost:6969

# 3. Optional: messaging gateway (Telegram, Discord, Slack, WhatsApp, Signal)
hermes gateway setup telegram
hermes gateway start

# 4. Create Obsidian vault
mkdir -p ~/obsidian-vault/codebase-graphs/
open -a Obsidian ~/obsidian-vault    # or open via Obsidian app

# 5. Link Graphify → Obsidian
export GRAPHIFY_OBSIDIAN_PATH=~/obsidian-vault/codebase-graphs/
graphify . --obsidian

# 6. Verify the whole stack
./scripts/doctor.sh
hermes doctor

# Expected output:
# ✓ Headroom proxy running on :8787
# ✓ HelixDB responding on :6969
# ✓ Mem0 server responding on :3000
# ✓ Ollama running — qwen2.5-coder:14b + 32b loaded
# ✓ Graphify graph exists + Obsidian export
# ✓ MCP servers: filesystem ✓ git ✓ fetch ✓ helix ✓ mem0 ✓ graphify ✓
# ✓ Hermes installed
```

## Hermes quick reference

```bash
hermes                    # start TUI
hermes model              # pick model interactively
hermes tools              # configure which tools are enabled
hermes config set         # set individual config values
hermes gateway            # start messaging gateway (Telegram/Discord/Slack/...)
hermes setup              # full setup wizard
hermes setup --portal     # Nous Portal (300+ models + tool gateway)
hermes update             # update to latest
hermes doctor             # diagnose issues
hermes claw migrate       # migrate from OpenClaw
```

| CLI | Messaging |
|---|---|
| `hermes` | `hermes gateway start` then message the bot |
| `/new` or `/reset` | `/new` or `/reset` |
| `/model [provider:model]` | `/model [provider:model]` |
| `Ctrl+C` to interrupt | `/stop` or send new message |

## Obsidian setup detail

1. Download from https://obsidian.md — free, no account required
2. Create vault at `~/obsidian-vault/`
3. Recommended plugins:
   - **Dataview** — query your notes like a database
   - **Kanban** — task boards
   - **Tasks** — todo tracking
   - **Git** — version your vault
   - **Templater** — note templates
   - **Excalidraw** — diagrams
4. Link Graphify for codebase graph export:
   ```bash
   export GRAPHIFY_OBSIDIAN_PATH=~/obsidian-vault/codebase-graphs/
   graphify . --obsidian
   ```
5. **Graphify export is one-directional** (graph is source of truth; Obsidian is a view — see KI-007)

### Memory domain discipline (critical in pro)

Three memory systems coexist. Do NOT blur them:

| System | Owns | Does NOT own |
|---|---|---|
| Mem0 | Long-term semantic facts ("user prefers X") | Conversation transcripts |
| Graphify | Codebase structure ("auth_handler calls validate_token") | User preferences |
| Hermes FTS5 | Conversation history ("last session I debugged Y") | Structured facts |
| Obsidian | Human-curated knowledge (research notes, design docs) | Auto-generated agent output |

> The MCP Memory server is **disabled by default** — it overlaps with Mem0 and
> creates a 4th memory domain nobody asked for. Do not enable it. See `docs/MEMORY_DOMAINS.md`.

## Daily workflow

```bash
# Morning — start everything
./scripts/morning-startup.sh
open -a Obsidian ~/obsidian-vault

# Work — use Hermes for long sessions, OpenCode for quick ones
hermes
# or
opencode

# During session
graphify query "where is X configured?"
mem0 search "decision about X" --user-id myproject
hermes sessions browse              # browse past sessions (FTS5 search within)

# Between meetings — dispatch from Telegram
# (Hermes gateway is running, send it a message from your phone)

# Before PR — Shannon
npx @keygraph/shannon start -u http://localhost:8000 -r . -w pr-...

# Evening — capture state
./scripts/end-of-day.sh          # refresh graph, export to Obsidian, headroom learn
mem0 add "Decided X for Y because Z" --user-id myproject

# Weekly
mem0 list --user-id myproject    # review decisions
hermes insights --days 7         # Hermes learning loop
./scripts/update.sh              # drift check
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `hermes: command not found` | `source ~/.bashrc` (or `~/.zshrc`); verify install succeeded |
| Hermes TUI won't start | `hermes doctor` — checks Python, Node, ripgrep, ffmpeg |
| 32b model OOMs | Use 14b for daily work; only load 32b for heavy tasks. Or use cloud fallback. |
| Telegram bot not responding | `hermes gateway` must be running; check `hermes gateway status` |
| Obsidian export empty | `GRAPHIFY_OBSIDIAN_PATH` must be set AND point to an existing dir |
| Hermes skills conflict with OpenCode | Pick ONE primary agent (see KI-006). Don't run both simultaneously. |
| Hermes can't reach Mem0/HelixDB | `hermes config set mem0.url http://localhost:3000` + ensure services up |
| Antivirus flags `uv.exe` (Windows) | False positive — see Hermes README verification steps |

## Upgrade path

`--pro` is the top profile. To stay current:
```bash
./scripts/update.sh          # check for upstream drift weekly
hermes update                 # update Hermes in place
headroom update               # update Headroom in place
docker compose pull           # pull latest Mem0 image
```

## What you get by choosing pro

- **Self-improving agent.** Hermes learns from your sessions, creates skills from experience, builds a model of you across sessions.
- **Telegram/Slack dispatch.** Talk to your agent from your phone between meetings; it runs on a cloud VM or local.
- **Obsidian sync.** Your codebase graph exports to a human-readable vault you can browse, link, and query with Dataview.
- **32b model headroom.** Heavy tasks get qwen2.5-coder:32b (~20GB) for better reasoning.
- **mattpocock skills.** triage, to-prd, diagnose, prototype, teach — product-minded engineering.
- **Cron scheduling.** Hermes can run nightly backups, weekly audits, daily reports unattended.