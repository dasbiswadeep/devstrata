# INSTRUCTIONS.md — devstrata

> Step-by-step setup for every tool in the stack.
> Run `./scripts/doctor.sh` first to check prerequisites.

---

## Prerequisites

```bash
# Check all prerequisites
python --version      # 3.10+
node --version        # 18+
docker --version      # any recent version (needed for --full/--pro: Mem0 + Shannon)

# Install missing tools
curl -LsSf https://astral.sh/uv/install.sh | sh    # uv + uvx (git MCP server needs uvx)
brew install ollama                                  # macOS
# Linux Ollama: curl -fsSL https://ollama.com/install.sh | sh
```

> **Note:** Hermes (pro profile) installs its own managed Python 3.11 + Node + ripgrep + ffmpeg.
> You don't need to pre-install those for Hermes. It needs Git, which most devs already have.

---

## Choosing Your Profile

Three profiles, tiered by **hardware** (RAM), not by feature gating:

| Profile | RAM | What you get | See |
|---|---|---|---|
| `--lite` | 8GB+ | Headroom + Graphify + MCP (4) + skills + Superpowers + GSD + Ollama | [`profiles/lite/PROFILE.md`](../profiles/lite/PROFILE.md) |
| `--full` | 16GB+ | + Mem0 + HelixDB + Shannon + MCP (6) + Mem0 skills | [`profiles/full/PROFILE.md`](../profiles/full/PROFILE.md) |
| `--pro` | 24GB+ | + Hermes Agent + Obsidian sync + mattpocock skills + 32b model | [`profiles/pro/PROFILE.md`](../profiles/pro/PROFILE.md) |

```bash
./scripts/install.sh --lite    # start here if unsure
./scripts/install.sh --full    # when you want memory + security
./scripts/install.sh --pro     # when you want self-improvement + PKM
```

### What each profile does at each step (install matrix)

| Step | Tool | --lite | --full | --pro |
|---|---|---|---|---|
| 1 | Headroom (compression proxy :8787) | ✅ | ✅ | ✅ |
| 2 | Graphify (codebase graph) | ✅ | ✅ | ✅ |
| 3 | MCP servers (filesystem, git, fetch, graphify) | ✅ 4 servers | ✅ 6 servers (+helix, +mem0) | ✅ 6 servers |
| 4 | skills.sh (anthropics, superpowers, graphify) | ✅ | ✅ | ✅ |
| 5 | Superpowers (methodology) | ✅ manual in agent | ✅ | ✅ |
| 6 | GSD Core (workflow) | ✅ | ✅ | ✅ |
| 7 | HelixDB (graph+vector DB :6969) | — | ✅ | ✅ |
| 8 | Mem0 (long-term memory :3000, Docker) | — | ✅ | ✅ |
| 9 | Mem0 skills (mem0, mem0-integrate, mem0-cli) | — | ✅ | ✅ |
| 10 | Shannon (AI pentester, AGPL-3.0) | — | ✅ | ✅ |
| 11 | Hermes Agent (self-improving shell) | — | — | ✅ |
| 12 | Obsidian (knowledge vault) | — | — | ✅ |
| 13 | mattpocock skills (triage, diagnose, prototype, teach) | — | — | ✅ |
| 14 | Ollama qwen2.5-coder:32b (heavy model) | — | — | ✅ |
| — | `docker-compose.yml` copied (Mem0 supervision) | — | ✅ | ✅ |
| — | `headroom.env` copied | ✅ | ✅ | ✅ |
| — | `.graphifyignore` copied | ✅ | ✅ | ✅ |
| — | `AGENTS.md` copied | ✅ | ✅ | ✅ |

install.sh is **idempotent** — re-running with a higher profile adds the new
tools without reinstalling existing ones. Upgrade path: `--lite` → `--full`
→ `--pro` with one command each.

### Which profile should I pick?

- **Unsure / laptop / private code** → `--lite` (Ollama local, 8GB+)
- **Want agents that remember + secure PRs** → `--full` (16GB+)
- **Want self-improvement + Telegram dispatch + PKM** → `--pro` (24GB+, M-series Mac)
- **Constrained RAM but want memory** → `--lite` + cloud LLM (Claude/GPT) + Mem0 cloud (skip HelixDB)

See the per-profile docs linked above for step-by-step install, post-install,
daily workflow, troubleshooting, and upgrade path.

---

## Step 0 — Choose Your LLM Backend

Set these environment variables before installing anything else.
Add to `~/.zshrc` or `~/.bashrc`.

### Option A: Ollama (local, private, free)
```bash
ollama pull qwen2.5-coder:14b      # primary coding (9GB)
ollama pull qwen2.5-coder:32b      # heavy tasks (20GB)
ollama pull deepseek-r1:14b        # planning only — NO tool-calling (9GB)

export OLLAMA_BASE_URL=http://localhost:11434
export OLLAMA_MODEL=qwen2.5-coder:14b
export OPENAI_BASE_URL=http://localhost:11434/v1
export OPENAI_API_KEY=ollama
```

### Option B: Claude (best reasoning)
```bash
export ANTHROPIC_API_KEY=sk-ant-...
# Models: claude-opus-4-7 (orchestration) / claude-sonnet-4-6 (daily) / claude-haiku-4-5 (fast)
```

### Option C: OpenAI
```bash
export OPENAI_API_KEY=sk-...
```

### Option D: Gemini
```bash
export GEMINI_API_KEY=...
```

### Option E: DeepSeek
```bash
export DEEPSEEK_API_KEY=...
```

### Option F: Nous Portal / Hermes (300+ models, one subscription)
```bash
hermes setup --portal    # run after Step 7
```

> **Note:** You can mix backends per tool. Graphify extraction can use Ollama
> (private) while your agent uses Claude Sonnet for reasoning.

---

## Step 1 — Headroom (install first — everything routes through it)

```bash
pip install "headroom-ai[all]"

# Start proxy
headroom proxy --port 8787 &

# Add to shell startup (~/.zshrc)
echo 'if ! pgrep -f "headroom proxy" > /dev/null; then
    headroom proxy --port 8787 &>/tmp/headroom.log &
fi' >> ~/.zshrc

# M-series Mac GPU acceleration
export HEADROOM_OUTPUT_SHAPER=1
export HEADROOM_EMBEDDER_RUNTIME=pytorch_mps

# Wrap your agent
headroom wrap opencode    # or: claude, codex, cursor
```

---

## Step 2 — HelixDB [--full and --pro only]

```bash
# Install CLI (verified 2026-06-26 — see docs/SOURCES.md)
curl -sSL "https://install.helix-db.com" | bash

# Quickest path — interactive bootstrap (installs skills + MCP, scaffolds, starts, seeds)
helix chef

# OR manual local setup:
helix init                          # scaffolds helix.toml + .helix/ + examples/
helix start dev --disk              # port 6969, persistent (in-memory is default — use --disk!)
helix query dev --file examples/request.json

# Verify
helix status dev
curl http://localhost:6969/health

# Stop
helix stop dev

# Update
helix update
```

### Process supervision (so HelixDB survives reboots + crashes)
HelixDB has no official Docker image yet. Use the OS-level templates:
- macOS: `cp configs/com.helixdb.dev.plist ~/Library/LaunchAgents/ && launchctl load ~/Library/LaunchAgents/com.helixdb.dev.plist`
- Linux: `sudo cp configs/helixdb.service /etc/systemd/system/ && sudo systemctl enable --now helixdb`
See `docs/SUPERVISION.md` for full detail.

---

## Step 3 — Mem0 [--full and --pro only]

### Option A: Self-hosted server (recommended — has dashboard + auth)
```bash
# One command: starts stack, creates admin, issues first API key (verified 2026-06-26)
git clone https://github.com/mem0ai/mem0.git /tmp/mem0
cd /tmp/mem0/server
make bootstrap
# Dashboard: http://localhost:3000

# Or manual:
docker compose up -d
```

### Option B: Python library (no Docker)
```bash
pip install mem0ai
pip install "mem0ai[nlp]"          # hybrid search (BM25 + entity extraction)
python -m spacy download en_core_web_sm
```

### Option C: CLI (manage memories from terminal)
```bash
npm install -g @mem0/cli           # or: pip install mem0-cli
mem0 init --agent --agent-caller <your-name>   # agent signup (no email needed)
mem0 add "I prefer async message consumers" --user-id myproject
mem0 search "message pattern" --user-id myproject
```

### Agent skills
```bash
# Reference skills (always on — SDK knowledge)
npx skills add https://github.com/mem0ai/mem0 --skill mem0
npx skills add https://github.com/mem0ai/mem0 --skill mem0-cli

# Pipeline skills (run on demand)
npx skills add https://github.com/mem0ai/mem0 --skill mem0-integrate
npx skills add https://github.com/mem0ai/mem0 --skill mem0-test-integration
```

### Set user ID (scope memories per-project to avoid cross-contamination)
```bash
export MEM0_USER_ID=myproject
mem0 init
```

---

## Step 4 — MCP Servers

```bash
# Install reference MCP servers
# Active reference servers (verified 2026-06-26, see docs/SOURCES.md):
#   Everything, Fetch, Filesystem, Git, Memory, Sequential Thinking, Time
# server-github, server-postgres, server-slack etc. are ARCHIVED (servers-archived repo)
npx -y @modelcontextprotocol/server-filesystem --help   # verify filesystem server
uvx mcp-server-git --help                               # verify git server
npx -y @modelcontextprotocol/server-fetch --help        # verify fetch server

# Generate .mcp.json from the single canonical template:
#   --lite: jq strips helix + mem0 → 4 servers
#   --full/--pro: keep all → 6 servers
# install.sh does this automatically. Manual:
jq 'del(.mcpServers.helix, .mcpServers.mem0)' configs/.mcp.json.template > your-project/.mcp.json  # lite
cp configs/.mcp.json.template your-project/.mcp.json                                            # full/pro
# Edit to match your setup (ports, paths)
```

---

## Step 5 — Graphify

```bash
# Install (verified 2026-06-26 — see docs/SOURCES.md)
# Package is graphifyy (double-y); CLI is graphify
pip install graphifyy          # or: pipx install graphifyy  (macOS externally-managed)
graphify install               # register the skill with your agent

# Install into agent (choose platform) — graphify install auto-detects,
# but you can be explicit:
graphify install --platform opencode    # OpenCode
graphify install                         # Claude Code (default)
graphify install --platform codex
graphify install --platform cursor

# Build first graph
cd your-project
graphify .

# Set up git hook for auto-rebuild
graphify hook install

# Create .graphifyignore
cp /path/to/devstrata/configs/.graphifyignore.template .graphifyignore
# Or write your own — see configs/.graphifyignore.template

# Commit graph for team sharing
git add graphify-out/
git commit -m "chore: add codebase knowledge graph"
```

---

## Step 6 — Superpowers

### OpenCode
```
# Inside OpenCode, tell it:
Fetch and follow: https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
```

### Claude Code
```bash
/plugin install superpowers@claude-plugins-official
```

### Hermes
```bash
hermes        # start Hermes
/skills       # browse
# Find superpowers and install
```

---

## Step 7 — GSD Core

```bash
npx @opengsd/gsd-core@latest
# Interactive installer — select your runtime

# Verify inside your agent:
/gsd-new-project
```

---

## Step 8 — skills.sh

```bash
# Core
npx skillsadd anthropics/skills
npx skillsadd obra/superpowers
npx skillsadd safishamsi/graphify
npx skillsadd mattpocock/skills

# Mem0
npx skills add https://github.com/mem0ai/mem0 --skill mem0
npx skills add https://github.com/mem0ai/mem0 --skill mem0-integrate

# Domain-specific (add as needed)
npx skillsadd supabase/agent-skills
npx skillsadd vercel-labs/agent-skills
```

---

## Step 9 — Hermes Agent [--pro only]

```bash
# Install (verified 2026-06-26 — see docs/SOURCES.md)
# Linux / macOS / WSL2 / Termux:
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
source ~/.bashrc    # or: source ~/.zshrc

# Windows native (PowerShell):
# iex (irm https://hermes-agent.nousresearch.com/install.ps1)

# Start
hermes

# Setup (guided wizard)
hermes setup
# or — Nous Portal (300+ models + tool gateway under one sub)
hermes setup --portal

# Pick a model (interactive)
hermes model
# or explicit: hermes model ollama:qwen2.5-coder:14b

# Connect to Mem0 and HelixDB (if config keys exist)
hermes config set mem0.url http://localhost:3000
hermes config set helix.url http://localhost:6969

# Optional: messaging gateway (Telegram, Discord, Slack, WhatsApp, Signal)
hermes gateway setup telegram
hermes gateway start

# Diagnose any issue
hermes doctor

# Update
hermes update

# Migrate from OpenClaw if needed
hermes claw migrate
```

---

## Step 10 — Shannon [--full and --pro only]

> Shannon Open Source is **AGPL-3.0**. For commercial SaaS use, a commercial
> license is available from Keygraph (shannon@keygraph.io). See docs/SOURCES.md.

```bash
# Prerequisites: Docker + Node.js 18+ + AI provider credentials (Anthropic recommended)
docker --version
node --version
export ANTHROPIC_API_KEY=sk-ant-...    # AWS Bedrock / Google Vertex also supported

# One-time setup wizard (credentials, config)
npx @keygraph/shannon setup

# Run a pentest against a source-available target YOU own
npx @keygraph/shannon start \
  -u http://localhost:8000 \
  -r . \
  -w first-scan

# View report
npx @keygraph/shannon logs first-scan
# Reports land in ~/.shannon/workspaces/first-scan/deliverables/

# WARNING: Shannon actively executes exploits. Only run against apps you own
# or have explicit written authorization to test. Never against production.
# A full run takes ~1–1.5 hours and incurs LLM API costs.
```

---

## Step 11 — Obsidian [--pro only]

1. Download from obsidian.md — free, no account required
2. Create vault at `~/obsidian-vault/`
3. Install plugins: Dataview, Kanban, Tasks, Git, Templater, Excalidraw
4. Link Graphify:
```bash
export GRAPHIFY_OBSIDIAN_PATH=~/obsidian-vault/codebase-graphs/
graphify . --obsidian
```

---

## Step 12 — Write Your AGENTS.md

```bash
cp configs/AGENTS.md.template your-project/AGENTS.md
# Edit with your project's stack, rules, and context
```

---

## Step 12b — Protect Your Secrets (.gitignore)

install.sh copies `configs/.gitignore.template` to your project as `.gitignore`
automatically. If you're setting up manually:

```bash
cp configs/.gitignore.template your-project/.gitignore
```

This protects:
- `headroom.env` (contains your API keys — never commit)
- `*.env`, `.env.*` (any env files)
- `*.bak.*` (install.sh --force backups)
- `graphify-out/` (regenerable, large)
- `.shannon/` (scan reports may contain vuln details)
- `*.pem`, `*.key` (private keys)
- `.hermes/sessions/`, `.gsd/STATE.md` (per-developer state)

**If you use git, verify before your first commit:**
```bash
git init
git add -n .   # dry-run: check what would be committed
# headroom.env should NOT appear in the list
```

---

## Step 13 — Process Supervision (--full and --pro only)

```bash
# Copy docker-compose.yml (install.sh does this automatically)
cp configs/docker-compose.yml your-project/docker-compose.yml

# Start Mem0 with auto-restart
cd your-project
docker compose up -d

# Verify
docker compose ps
curl http://localhost:3000/health
```

---

## Step 14 — Daily Workflow Scripts

```bash
# Morning — start Headroom, HelixDB, Ollama; check graph freshness
./scripts/morning-startup.sh

# Evening — refresh graph, export to Obsidian, capture state
./scripts/end-of-day.sh

# Weekly — check for upstream version drift
./scripts/update.sh
```

---

## Verifying the Full Stack

```bash
./scripts/doctor.sh
```

Expected output:
```
✓ Headroom proxy running on :8787
✓ HelixDB responding on :6969
✓ Mem0 server responding on :3000
✓ Ollama running — qwen2.5-coder:14b loaded
✓ Graphify graph exists (graphify-out/graph.json)
✓ MCP servers: filesystem ✓ git ✓ fetch ✓ helix ✓ mem0 ✓
✓ skills installed: superpowers ✓ graphify ✓ mem0 ✓
```
