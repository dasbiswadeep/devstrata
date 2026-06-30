# devstrata

> A layered, composable AI development stack for daily engineering work.
> Works with any LLM: Ollama (local/cloud), Claude, ChatGPT, Gemini, DeepSeek, Hermes.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Education](https://img.shields.io/badge/Purpose-Learning%20%26%20Education-blue)]()
[![Status: Experimental](https://img.shields.io/badge/Status-Experimental-orange)]()

---

## ⚠️ Important Declarations

**This project is for learning and educational purposes.**

- This is a *meta-package* — it installs and wires together other open-source tools.
- It does NOT fork, modify, or redistribute any upstream tool.
- All tools referenced retain their original licenses and authors.
- This project is maintained on a best-effort basis by a single person.
- Commands and configs will drift as upstream tools evolve. Treat them as starting points.
- See [KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) for honest limitations.

---

## What is devstrata?

devstrata is an opinionated installer and configuration layer that wires 11 open-source AI development tools into a coherent, layered stack. Think of it like `oh-my-zsh` for AI-assisted development — it doesn't replace the shell, it makes it dramatically more useful through curated defaults.

### The core problem it solves

10 great AI dev tools exist. None of them know about each other out of the box:
- Mem0 doesn't use HelixDB as its vector backend by default
- Headroom doesn't compress Graphify's MCP output by default
- Hermes doesn't write summaries to Obsidian automatically
- GSD Core and Superpowers don't coordinate their phase gates
- Shannon doesn't run per-PR automatically

devstrata is the composition layer that makes them work together.

---

## The Stack

| Layer | Tool | Role | Stars (Jun 2026) |
|---|---|---|---|
| L0 Security | Shannon | AI pentester, prompt injection guard | 45.1k |
| L1 Storage | HelixDB | Graph+vector DB (Rust, OLTP) | 5.5k |
| L1 Memory | Mem0 | Persistent long-term agent memory | 59.5k |
| L2 Protocol | MCP Servers | Universal tool access bus | 87.7k |
| L2 Compress | Headroom | 60–95% token compression proxy | 51.3k |
| L3 Knowledge | Graphify | Codebase knowledge graph + MCP | 72.2k |
| L4 Method | Superpowers | TDD + methodology enforcement | 238.9k |
| L4 Workflow | GSD Core | Phase-based project workflow | 5.1k |
| L5 Skills | skills.sh | Open agent skill registry | ~780k installs |
| L5 Agent | Hermes Agent | Self-improving agent shell | 203.3k |
| L6 PKM | Obsidian | Local-first personal knowledge base | — |

---

## Profiles

devstrata ships three profiles. Start with `--lite`.

```
--lite    Ollama + Headroom + Graphify + MCP (8GB+ RAM, any machine)
--full    + Mem0 + HelixDB + Shannon (16GB+ RAM)
--pro     + Hermes + Obsidian sync (24GB+ RAM, M-series Mac recommended)
```

Each profile has its own config bundle under [`profiles/`](profiles/):
- [`profiles/lite/`](profiles/lite/PROFILE.md) — `.mcp.json` + RAM budget
- [`profiles/full/`](profiles/full/PROFILE.md) — adds helix + mem0 MCP servers
- [`profiles/pro/`](profiles/pro/PROFILE.md) — adds Hermes + Obsidian setup

---

## Repository Structure

```
devstrata/
├── README.md                      ← this file
├── CLAUDE.md                      ← Claude Code session context
├── LICENSE                        ← MIT
├── .gitignore                     ← protects secrets + backups from being committed
├── docs/                          ← all documentation (10 files)
│   ├── ARCHITECTURE.md            ← layer diagram, data flow, component map
│   ├── SKILLS.md                  ← all skills.sh skills
│   ├── GUIDING_PRINCIPLES.md      ← design philosophy (10 principles)
│   ├── INSTRUCTIONS.md            ← step-by-step setup per tool
│   ├── SECURITY.md                ← Shannon integration, threat model
│   ├── BACKENDS.md                ← LLM switching guide
│   ├── KNOWN_ISSUES.md            ← honest limitations (every issue has a mitigation)
│   ├── MEMORY_DOMAINS.md          ← memory layer split (Mem0/Graphify/Hermes/Obsidian)
│   ├── SOURCES.md                 ← every claim, with source URL + date verified
│   └── SUPERVISION.md             ← launchd/systemd templates for process supervision
├── scripts/                       ← all executable scripts (13 scripts)
│   ├── install.sh                 ← profile-based installer (generates .mcp.json via jq, --force, --yes)
│   ├── doctor.sh                  ← health check for all services
│   ├── morning-startup.sh         ← start all services (KI-003 fix)
│   ├── end-of-day.sh              ← capture state, export to Obsidian
│   ├── update.sh                  ← upstream drift checker (KI-001 fix)
│   ├── version-check.sh           ← queries PyPI/GitHub/npm for latest versions (KI-001 fix)
│   ├── validate-mcp.sh            ← validates .mcp.json server commands exist (WF-002 fix)
│   ├── sync-memory.sh             ← Mem0 → Obsidian one-way export (KI-002 fix)
│   ├── recommend-profile.sh       ← detects RAM + cloud keys, recommends profile (KI-004 fix)
│   ├── headroom-watchdog.sh       ← restarts Headroom + Ollama if either dies (KI-010 fix)
│   ├── agent-isolate.sh           ← separates Hermes/OpenCode skill dirs (KI-006 fix)
│   ├── wsl2-check.sh              ← Windows/WSL2 setup helper (KI-008 fix)
│   └── test.sh                    ← run the test suite (64 test files, ~645 assertions, <5s)
├── tests/                         ← integration + structural tests (64 test files)
│   ├── README.md                  ← full test catalog by category
│   └── test_*.sh                  ← structure, syntax, json, yaml, mcp-gen, links, sources,
│                                    no-personal-data, cornerstones, force/upgrade, idempotency,
│                                    downgrade-cleanup, doc-CLI-accuracy, and more
├── configs/                       ← config templates (single source of truth, 12 files)
│   ├── AGENTS.md.template         ← per-project agent context
│   ├── .mcp.json.template         ← canonical; install.sh strips helix+mem0 for --lite via jq
│   ├── .graphifyignore.template   ← what not to index
│   ├── headroom.env.template      ← LLM backend config (one swap adapts all layers)
│   ├── .gitignore.template        ← protects secrets + backups in user projects
│   ├── docker-compose.yml         ← Mem0 process supervision (KI-003 fix)
│   ├── com.helixdb.dev.plist      ← macOS launchd for HelixDB (KI-003 fix)
│   ├── helixdb.service            ← Linux systemd for HelixDB (KI-003 fix)
│   ├── com.devstrata.headroom.proxy.plist  ← macOS launchd for Headroom (KI-003 fix)
│   ├── headroom-proxy.service     ← Linux systemd for Headroom (KI-003 fix)
│   ├── com.devstrata.headroom-watchdog.plist ← macOS launchd for watchdog (KI-010 fix)
│   └── headroom-watchdog.timer    ← Linux systemd timer for watchdog (KI-010 fix)
└── profiles/                      ← per-profile prose (config is generated, not copied)
    ├── lite/PROFILE.md            ← 8GB+ RAM, what's installed, troubleshooting, upgrade path
    ├── full/PROFILE.md            ← 16GB+ RAM, adds Mem0 + HelixDB + Shannon
    └── pro/PROFILE.md             ← 24GB+ RAM, adds Hermes + Obsidian + 32b model
```

---

## Quick Start

```bash
# Clone (replace dasbiswadeep with your fork if you forked it)
git clone https://github.com/dasbiswadeep/devstrata.git
cd devstrata

# Not sure which profile? Detect your hardware first:
./scripts/recommend-profile.sh

# Run doctor first to check prerequisites
./scripts/doctor.sh

```bash
# Install lite profile (safest starting point)
./scripts/install.sh --lite

# Non-interactive / CI: add --yes to skip the prompt
./scripts/install.sh --lite --yes

# Or full
./scripts/install.sh --full

# Or pro (24GB+ RAM, M-series Mac)
./scripts/install.sh --pro
```

After install, your project directory will have:
- `AGENTS.md` — edit with your project context
- `.mcp.json` — wired for your profile
- `headroom.env` — edit, then `source headroom.env` (gitignored — contains API keys)
- `.graphifyignore` — edit as needed
- `.gitignore` — protects secrets + backups from being committed
- `docker-compose.yml` — (full/pro only) `docker compose up -d` for Mem0 supervision

### Upgrading or changing profiles

```bash
# Lite → Full (adds Mem0, HelixDB, Shannon)
./scripts/install.sh --full

# Full → Pro (adds Hermes, Obsidian)
./scripts/install.sh --pro

# Downgrade (Pro → Lite): use --force to strip helix/mem0 from .mcp.json
./scripts/install.sh --lite --force

# Any profile change: use --force to regenerate .mcp.json + AGENTS.md
# install.sh auto-detects profile mismatch and tells you when --force is needed.
# --force backs up existing .mcp.json and AGENTS.md to .bak.* before overwriting,
# so you don't lose your edits.
./scripts/install.sh --full --force
```

### ECC — the batteries-included alternative to composing L4/L5

The default stack composes L4 (method) + L5 (skills) from three independent tools:
Superpowers + GSD Core + skills.sh. If you want a **single 277-skill pack** instead,
add `--with-ecc` to install ECC ([affaan-m/ECC](https://github.com/affaan-m/ECC),
223k stars, MIT) as a replacement for L4+L5:

```bash
# Prints the official ECC install commands (ECC is a plugin install, not CLI):
./scripts/install.sh --pro --with-ecc

# Then inside Claude Code:
#   /plugin marketplace add https://github.com/affaan-m/ECC
#   /plugin install ecc@ecc
```

ECC is a monolith (277 skills, 67 agents, hooks, 12-language rules) — install all
of it or none. Don't layer it on top of the composed default (causes skill conflicts).
See [SKILLS.md](docs/SKILLS.md) for the full comparison + when to pick which.

---

## Daily Workflow

> Run these from the devstrata repo root (where you cloned it). install.sh copies
> configs into the current directory, so the scripts + configs coexist.

```bash
# Morning — start all services
./scripts/morning-startup.sh

# Work — query codebase via Graphify, recall decisions via Mem0
graphify query "where is the message consumer configured?"
mem0 search "architecture decision" --user-id myproject

# Evening — refresh graph, export to Obsidian, capture decisions
./scripts/end-of-day.sh

# Weekly — check for upstream version drift
./scripts/update.sh
```

---

## Does devstrata auto-adopt upstream repo updates?

**No — and this is intentional.** See [GUIDING_PRINCIPLES.md](docs/GUIDING_PRINCIPLES.md) §1 (composition over creation) and [KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) KI-001.

devstrata is a glue/config layer. The 11 upstream tools update independently and can ship breaking changes (renamed CLIs, changed Docker commands, moved MCP args). Auto-upgrading would silently break your stack. Instead:

1. **`./scripts/update.sh`** reports installed versions vs latest available — run it weekly.
2. **Review the changelog** of any tool that has a new version.
3. **Upgrade deliberately** — one tool at a time, then re-run `./scripts/doctor.sh`.
4. **Pin versions** in production.

If you want something closer to auto-adoption, the closest pattern is:
- Pin all tools in `docker-compose.yml` to `:latest` and run `docker compose pull` weekly
- Subscribe to GitHub releases for each upstream repo (watch button)
- Open an issue in devstrata when an upstream change breaks a config — PRs welcome

Auto-adoption is a non-goal. Stability and understanding are goals.

---

## Documentation

| File | Contents |
|---|---|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Layer diagram, data flow, component map |
| [SKILLS.md](docs/SKILLS.md) | All skills.sh skills, what each does |
| [GUIDING_PRINCIPLES.md](docs/GUIDING_PRINCIPLES.md) | Design philosophy and decisions |
| [INSTRUCTIONS.md](docs/INSTRUCTIONS.md) | Step-by-step setup for each tool |
| [SECURITY.md](docs/SECURITY.md) | Shannon integration, threat model |
| [BACKENDS.md](docs/BACKENDS.md) | LLM switching guide (all providers) |
| [KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) | Honest limitations and weak points |
| [MEMORY_DOMAINS.md](docs/MEMORY_DOMAINS.md) | Memory layer split: Mem0/Graphify/Obsidian |
| [SOURCES.md](docs/SOURCES.md) | Every factual claim, with source URL + date verified |
| [SUPERVISION.md](docs/SUPERVISION.md) | launchd/systemd templates for process supervision |
| [FURTHER_READING.md](docs/FURTHER_READING.md) | Build-your-own-X tutorials mapped to each devstrata layer (principle #10) |

---

## Honest Strengths and Weaknesses

### What works well ✅

- Single config swap to change LLM backend — all layers adapt
- Headroom's 92% token compression genuinely extends session quality
- Graphify eliminates grep-based codebase exploration for agents
- Mem0 v3 algorithm (April 2026) achieves 94.8% recall on LongMemEval
- HelixDB unifies graph + vector + relational in one store
- Shannon catches prompt injection and API vulns before they ship
- Hermes self-improves — gets better the more you use it
- All tools are MIT/Apache 2.0/AGPLv3 — no proprietary lock-in for the core stack (Obsidian is proprietary freeware but notes are plain Markdown; Logseq is the open alternative)
- Every factual claim has a source URL + verification date — see [SOURCES.md](docs/SOURCES.md)

### What doesn't work yet ⚠️

- ~~Three overlapping memory systems~~ → **resolved**: MEMORY_DOMAINS.md enforces the split + `sync-memory.sh` exports Mem0 → Obsidian
- ~~No native process supervision~~ → **resolved**: Mem0 (docker-compose), HelixDB + Headroom (launchd/systemd templates), Headroom watchdog (cron/timer), Ollama (native service). See `docs/SUPERVISION.md`
- Hardware ceiling: full stack needs 16GB+ RAM, pro needs 24GB → **mitigated by `recommend-profile.sh`** (detects RAM + cloud keys, recommends the right profile)
- Upstream tools change fast → **mitigated by `update.sh` + `version-check.sh` (queries PyPI/GitHub/npm) + `validate-mcp.sh` (catches broken .mcp.json)**
- Shannon is AGPL-3.0 — review implications before commercial use (commercial license available from Keygraph)
- No Windows native → **mitigated by `wsl2-check.sh`** (detects WSL2, checks Docker Desktop + systemd + Ollama options)
- HelixDB has no official Docker image yet — runs on host with launchd/systemd supervision
- Hermes + OpenCode skill conflicts → **mitigated by `agent-isolate.sh`** (separates config dirs, writes skills registry)
- Headroom dies if Ollama goes offline → **mitigated by `headroom-watchdog.sh`** (auto-restarts both every 120s)

See [KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) for full detail — every issue now lists its mitigation.

---

## License

MIT — see [LICENSE](LICENSE).

This project is a composition and documentation layer. Each upstream tool retains its original license:

| Tool | License |
|---|---|
| Shannon | AGPL-3.0 |
| HelixDB | Apache 2.0 |
| Mem0 | Apache 2.0 |
| MCP Servers | Apache 2.0 / MIT |
| Headroom | Apache 2.0 |
| Graphify | Check repo |
| Superpowers | MIT |
| GSD Core | MIT |
| skills.sh | MIT |
| Hermes Agent | MIT |
| Obsidian | Proprietary freeware |

---

## Attribution

Built by [dasbiswadeep](https://github.com/dasbiswadeep) based on research into:
mem0ai/mem0 · helixdb/helix-db · KeygraphHQ/shannon · modelcontextprotocol/servers ·
headroomlabs-ai/headroom · safishamsi/graphify · obra/superpowers · open-gsd/gsd-core ·
skills.sh · nousresearch/hermes-agent · obsidianmd

---

*Not affiliated with any of the above projects.*