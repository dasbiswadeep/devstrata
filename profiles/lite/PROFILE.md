# devstrata — `--lite` profile

> **8GB+ RAM · any machine · safest starting point**
> The 80% case: token compression + codebase graph + skills + methodology, all local.

---

## What this profile installs

| # | Tool | Purpose | Port | RAM |
|---|---|---|---|---|
| 1 | Headroom | Token compression proxy (60–95%) | 8787 | ~200MB |
| 2 | Graphify | Codebase knowledge graph (tree-sitter + Ollama) | spawned by agent | ~150MB |
| 3 | MCP servers | filesystem, git, fetch, graphify (4 servers) | via .mcp.json | on-demand |
| 4 | skills.sh | anthropics/skills, obra/superpowers, safishamsi/graphify | loaded into context | 0 |
| 5 | Ollama | Local LLM (qwen2.5-coder:14b recommended) | 11434 | ~9GB |
| 6 | Superpowers | TDD + brainstorming + subagent-driven dev | via agent plugin | 0 |
| 7 | GSD Core | Discuss→Plan→Execute→Verify→Ship workflow | via agent | 0 |

**Total active RAM: ~9.5GB** (fits comfortably in 8GB+ when Ollama model is loaded; model unloads when idle).

## What this profile does NOT install

- Mem0 (long-term memory) → use `--full`
- HelixDB (graph + vector DB) → use `--full`
- Shannon (security scanning) → use `--full`
- Hermes Agent (self-improving shell) → use `--pro`
- Obsidian vault sync → use `--pro`

---

## Prerequisites

| Tool | Min version | Why | Install |
|---|---|---|---|
| Python | 3.10+ | Graphify, Headroom | `brew install python` / `apt install python3` |
| Node.js | 18+ | MCP servers (npx), skills.sh | `brew install node` / nvm |
| pip | any | Headroom, Graphify | comes with Python |
| jq | any | .mcp.json generation for lite (strips helix+mem0) | `brew install jq` / `apt install jq` |
| Ollama | any | Local LLM | `brew install ollama` / `curl -fsSL https://ollama.com/install.sh \| sh` |

> **jq is optional but recommended.** Without jq, install.sh copies the full
> 6-server .mcp.json template and warns you to manually delete helix + mem0 blocks.
> With jq, it auto-generates the correct 4-server lite config.

Check prerequisites:
```bash
python3 --version && node --version && (command -v jq && echo "jq OK" || echo "jq missing (optional)")
```

---

## Install (one command)

```bash
# Clone (replace dasbiswadeep with your fork if you forked it)
git clone https://github.com/dasbiswadeep/devstrata.git
cd devstrata
./scripts/install.sh --lite
```

install.sh does, in order:
1. Verifies Python 3.10+ and Node 18+
2. Installs Headroom (`pip install "headroom-ai[all]"`) — starts proxy on :8787
3. Installs Graphify (`pip install graphifyy && graphify install`)
4. Verifies MCP fetch server (`npx @modelcontextprotocol/server-fetch`)
5. Generates `.mcp.json` with **4 servers** (filesystem, git, fetch, graphify) via jq
6. Installs core skills (anthropics, superpowers, graphify)
7. Installs GSD Core (`npx @opengsd/gsd-core@latest`)
8. Copies config templates: `AGENTS.md`, `.graphifyignore`, `headroom.env`

## Manual install (if you prefer step-by-step)

```bash
# 1. LLM backend — pull the model you'll use
ollama pull qwen2.5-coder:14b      # ~9GB, primary coding model

# 2. Headroom — compression proxy
pip install "headroom-ai[all]"
headroom proxy --port 8787 &

# 3. Graphify — codebase knowledge graph
pip install graphifyy               # package name is double-y; CLI is `graphify`
graphify install                    # register skill with your agent

# 4. MCP servers — verify the 3 npx/uvx-based ones
npx -y @modelcontextprotocol/server-fetch --help
uvx mcp-server-git --help

# 5. Generate .mcp.json (4 servers — strips helix + mem0 for lite)
jq 'del(.mcpServers.helix, .mcpServers.mem0)' \
   /path/to/devstrata/configs/.mcp.json.template > .mcp.json

# 6. Skills
npx skillsadd anthropics/skills
npx skillsadd obra/superpowers
npx skillsadd safishamsi/graphify

# 7. GSD Core
npx @opengsd/gsd-core@latest

# 8. Copy templates
cp /path/to/devstrata/configs/AGENTS.md.template AGENTS.md
cp /path/to/devstrata/configs/.graphifyignore.template .graphifyignore
cp /path/to/devstrata/configs/headroom.env.template headroom.env
source headroom.env                 # set your LLM backend
```

## Post-install setup

```bash
# 1. Pull the Ollama model (if not already)
ollama pull qwen2.5-coder:14b

# 2. Build your first codebase graph
cd your-project
graphify .

# 3. Verify the whole stack
./scripts/doctor.sh

# 4. Start your agent (OpenCode or Claude Code)
opencode    # or: claude

# 5. Inside the agent, install Superpowers
# For OpenCode: tell it to fetch https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
# For Claude Code: /plugin install superpowers@claude-plugins-official

# 6. Start a GSD project
/gsd-new-project
```

## Daily workflow

```bash
# Morning — start Headroom + Ollama, check graph freshness
./scripts/morning-startup.sh

# Work — query codebase, recall decisions (no Mem0 in lite, so just Graphify)
graphify query "where is X configured?"

# Evening — refresh graph for tomorrow
./scripts/end-of-day.sh

# Weekly — check for upstream version drift
./scripts/update.sh
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `headroom: command not found` | `pip install "headroom-ai[all]"` — ensure pip bin dir is on PATH |
| `graphify: command not found` | `pip install graphifyy` — package is double-y, CLI is `graphify`. On macOS externally-managed: `pipx install graphifyy` |
| Ollama model not loaded | `ollama pull qwen2.5-coder:14b` then `ollama serve` |
| Headroom proxy dies | `pkill -f "headroom proxy" && headroom proxy --port 8787 &` (see KI-010) |
| Graphify graph stale | `graphify . --update` or `graphify hook install` for auto-rebuild |
| `.mcp.json` has 6 servers but I'm on lite | You didn't have jq. Install jq, re-run `install.sh --lite`, or manually delete `helix` + `mem0` blocks |
| MCP server fails to start | Check `~/.config/opencode/logs/` or agent's MCP log |

## Upgrade path

```bash
# Lite → Full (adds Mem0, HelixDB, Shannon)
./scripts/install.sh --full

# Lite → Pro (adds Hermes, Obsidian on top of full)
./scripts/install.sh --pro
```

install.sh is idempotent — re-running with a higher profile adds the new tools
without reinstalling existing ones.

## What you give up by choosing lite

- **No persistent agent memory.** Each session starts fresh. (Mem0 is in --full)
- **No entity graph DB.** No HelixDB for vector + relational queries. (--full)
- **No security scanning.** Shannon doesn't run on your PRs. (--full)
- **No self-improving agent.** No Hermes, no Telegram dispatch. (--pro)
- **No Obsidian sync.** Graphify can't export to a knowledge vault. (--pro)

If you hit any of these limits, upgrade with one command.