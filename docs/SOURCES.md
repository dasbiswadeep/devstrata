# SOURCES.md — devstrata

> Every factual claim in this repo, with its source, date verified, and URL.
> This file exists to keep our "honest documentation" principle (GUIDING_PRINCIPLES §8)
> verifiable. If a claim has no entry here, treat it as unverified.
>
> Last verified: **2026-06-26**

---

## How to read this file

Each entry:
- **Claim** — the statement made in README/docs
- **Source** — upstream README, repo metadata, or benchmark page
- **Verified** — date we checked
- **URL** — where you can verify it yourself

Star counts change daily. We re-verify monthly via `./scripts/update.sh`.

---

## Tool: Headroom

| Field | Value | Source | Verified | URL |
|---|---|---|---|---|
| License | **Apache-2.0** | repo metadata + README badge + LICENSE file | 2026-06-26 | https://github.com/headroomlabs-ai/headroom |
| Stars | ~51,275 | GitHub API `repos/headroomlabs-ai/headroom` | 2026-06-26 | https://github.com/headroomlabs-ai/headroom/stargazers |
| Compression | "60–95% fewer tokens" | upstream README headline + Proof table | 2026-06-26 | https://github.com/headroomlabs-ai/headroom#proof |
| Specific claim "92% on code search" | 17,765 → 1,408 tokens = 92% | upstream Proof table | 2026-06-26 | https://github.com/headroomlabs-ai/headroom#proof |
| Install command | `pip install "headroom-ai[all]"` | upstream README "Get started" | 2026-06-26 | https://github.com/headroomlabs-ai/headroom#get-started-60-seconds |
| Update command | `headroom update` (auto-detects pip/pipx/uv) | upstream README "Updating" | 2026-06-26 | https://github.com/headroomlabs-ai/headroom#updating |
| MCP install | `headroom mcp install` | upstream README integrations | 2026-06-26 | https://github.com/headroomlabs-ai/headroom |

> **Note:** The repo is mirrored at `headroomlabs-ai/headroom`; the original and
> active CI is at `chopratejas/headroom`. Both are the same project. LICENSE is
> Apache-2.0. **The previous devstrata README incorrectly listed Headroom as
> "Proprietary" — this was wrong and has been corrected.**

---

## Tool: Mem0

| Field | Value | Source | Verified | URL |
|---|---|---|---|---|
| License | Apache-2.0 | repo metadata + LICENSE | 2026-06-26 | https://github.com/mem0ai/mem0 |
| Stars | ~59,474 | GitHub API | 2026-06-26 | https://github.com/mem0ai/mem0/stargazers |
| LongMemEval recall | **94.8** (new algorithm, April 2026) | upstream README "New Memory Algorithm" table | 2026-06-26 | https://github.com/mem0ai/mem0#new-memory-algorithm-april-2026 |
| LoCoMo score | 91.6 (+20 over previous) | same table | 2026-06-26 | https://github.com/mem0ai/mem0#new-memory-algorithm-april-2026 |
| Install (library) | `pip install mem0ai` | upstream README Quickstart | 2026-06-26 | https://github.com/mem0ai/mem0#quickstart-guide |
| Install (NLP) | `pip install mem0ai[nlp]` + `python -m spacy download en_core_web_sm` | upstream README | 2026-06-26 | https://github.com/mem0ai/mem0 |
| Self-hosted server | `cd server && make bootstrap` (one command) | upstream README "Self-Hosted Server" | 2026-06-26 | https://github.com/mem0ai/mem0#self-hosted-server |
| CLI install | `npm install -g @mem0/cli` (or `pip install mem0-cli`) | upstream README "CLI" | 2026-06-26 | https://github.com/mem0ai/mem0#cli |
| Agent signup | `mem0 init --agent --agent-caller <name>` | upstream README | 2026-06-26 | https://github.com/mem0ai/mem0 |
| Skills | `npx skills add https://github.com/mem0ai/mem0 --skill mem0` | upstream README "Agent Skills" | 2026-06-26 | https://github.com/mem0ai/mem0#agent-skills |

---

## Tool: Graphify

| Field | Value | Source | Verified | URL |
|---|---|---|---|---|
| License | MIT | repo metadata | 2026-06-26 | https://github.com/safishamsi/graphify |
| Stars | ~72,215 | GitHub API | 2026-06-26 | https://github.com/safishamsi/graphify/stargazers |
| Token reduction | "71.5x fewer tokens per query vs reading raw files" | upstream README "Token benchmark" | 2026-06-26 | https://github.com/safishamsi/graphify |
| Install | **`pip install graphifyy && graphify install`** | upstream README "Install" | 2026-06-26 | https://github.com/safishamsi/graphify#install |
| PyPI name note | Package is `graphifyy` (double-y) while CLI is `graphify` — name reclamation in progress | upstream README | 2026-06-26 | https://github.com/safishamsi/graphify#install |
| pipx fallback | `pipx install graphifyy` for externally-managed macOS | upstream README macOS note | 2026-06-26 | https://github.com/safishamsi/graphify#install |
| MCP | `graphify ./raw --mcp` starts stdio MCP server | upstream README usage | 2026-06-26 | https://github.com/safishamsi/graphify |
| Obsidian export | `graphify-out/obsidian/` produced automatically | upstream README "What you get" | 2026-06-26 | https://github.com/safishamsi/graphify |
| Git hook | `graphify hook install` (post-commit rebuild) | upstream README | 2026-06-26 | https://github.com/safishamsi/graphify |
| Watch mode | `graphify ./raw --watch` (auto-sync) | upstream README | 2026-06-26 | https://github.com/safishamsi/graphify |

> **Drift note:** Previous devstrata install.sh used `uv tool install "graphifyy[ollama,mcp]"`.
> Upstream README now shows `pip install graphifyy && graphify install`. Both may work;
> the pip form is the documented canonical path as of 2026-06-26.

---

## Tool: HelixDB

| Field | Value | Source | Verified | URL |
|---|---|---|---|---|
| License | Apache-2.0 | repo metadata | 2026-06-26 | https://github.com/helixdb/helix-db |
| Stars | ~5,501 | GitHub API | 2026-06-26 | https://github.com/helixdb/helix-db/stargazers |
| Install CLI | `curl -sSL "https://install.helix-db.com" \| bash` | upstream README "Getting Started" | 2026-06-26 | https://github.com/helixdb/helix-db#getting-started |
| Start local | `helix start dev` (in-memory) or `helix start dev --disk` (persistent) | upstream README | 2026-06-26 | https://github.com/helixdb/helix-db |
| Port | 6969 (default) | upstream README | 2026-06-26 | https://github.com/helixdb/helix-db |
| Chef bootstrap | `helix chef` (interactive one-shot) | upstream README "quickest path" | 2026-06-26 | https://github.com/helixdb/helix-db |
| Update | `helix update` | upstream README | 2026-06-26 | https://github.com/helixdb/helix-db |
| Docker image | **No official local-dev Docker image** — runs on host | upstream README (no docker pull documented) | 2026-06-26 | https://github.com/helixdb/helix-db |
| Cloud | `helix auth login` + `helix init cloud --cluster-id <id>` | upstream README "HelixDB Cloud" | 2026-06-26 | https://github.com/helixdb/helix-db#helixdb-cloud |

---

## Tool: Shannon

| Field | Value | Source | Verified | URL |
|---|---|---|---|---|
| License | **AGPL-3.0** (Open Source edition); commercial licensing available | repo metadata + LICENSE + README "License" | 2026-06-26 | https://github.com/KeygraphHQ/shannon |
| Stars | ~45,104 | GitHub API | 2026-06-26 | https://github.com/KeygraphHQ/shannon/stargazers |
| Install / run | `npx @keygraph/shannon setup` then `npx @keygraph/shannon start -u <url> -r <repo>` | upstream README "Quick Start" | 2026-06-26 | https://github.com/KeygraphHQ/shannon#quick-start |
| Prerequisites | Docker + Node.js 18+ + AI provider credentials (Anthropic recommended) | upstream README | 2026-06-26 | https://github.com/KeygraphHQ/shannon#prerequisites |
| Provider support | Claude officially; AWS Bedrock + Google Vertex documented | upstream README "AI providers" | 2026-06-26 | https://github.com/KeygraphHQ/shannon |
| Two editions | Shannon Open Source (this repo, AGPL) + Keygraph platform (commercial, continuous) | upstream README "Editions" | 2026-06-26 | https://github.com/KeygraphHQ/shannon#editions |
| Run duration | ~1–1.5 hours for a full scan | upstream README "Limitations" | 2026-06-26 | https://github.com/KeygraphHQ/shannon |
| Not accepting external code contributions | issues + discussions welcome, no PRs | upstream README "Community" | 2026-06-26 | https://github.com/KeygraphHQ/shannon#community-and-support |

---

## Tool: Superpowers

| Field | Value | Source | Verified | URL |
|---|---|---|---|---|
| License | MIT | repo metadata + LICENSE | 2026-06-26 | https://github.com/obra/superpowers |
| Stars | ~238,920 | GitHub API | 2026-06-26 | https://github.com/obra/superpowers/stargazers |
| Claude Code install | `/plugin install superpowers@claude-plugins-official` | upstream README | 2026-06-26 | https://github.com/obra/superpowers#claude-code |
| OpenCode install | "Fetch and follow https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md" | upstream README | 2026-06-26 | https://github.com/obra/superpowers#opencode |
| Cursor install | `/add-plugin superpowers` | upstream README | 2026-06-26 | https://github.com/obra/superpowers#cursor |
| Skills list | brainstorming, writing-plans, subagent-driven-development, test-driven-development, systematic-debugging, requesting-code-review, receiving-code-review, using-git-worktrees, finishing-a-development-branch, verification-before-completion, executing-plans, dispatching-parallel-agents, writing-skills, using-superpowers | upstream README "Skills Library" | 2026-06-26 | https://github.com/obra/superpowers#skills-library |
| Author | Jesse Vincent / Prime Radiant | upstream README "Community" | 2026-06-26 | https://github.com/obra/superpowers |

---

## Tool: GSD Core

| Field | Value | Source | Verified | URL |
|---|---|---|---|---|
| License | MIT | repo metadata + LICENSE | 2026-06-26 | https://github.com/open-gsd/gsd-core |
| Stars | ~5,123 | GitHub API | 2026-06-26 | https://github.com/open-gsd/gsd-core/stargazers |
| Install | `npx @opengsd/gsd-core@latest` | upstream README "Quickstart" | 2026-06-26 | https://github.com/open-gsd/gsd-core#quickstart |
| First project | `/gsd-new-project` | upstream README | 2026-06-26 | https://github.com/open-gsd/gsd-core |
| Phase loop | Discuss → Plan → Execute → Verify → Ship | upstream README "How it works" | 2026-06-26 | https://github.com/open-gsd/gsd-core#how-it-works |
| Core idea | Solves "context rot" via fresh-context subagents | upstream README "Why it works" | 2026-06-26 | https://github.com/open-gsd/gsd-core |

---

## Tool: Hermes Agent

| Field | Value | Source | Verified | URL |
|---|---|---|---|---|
| License | MIT | repo metadata + LICENSE + README badge | 2026-06-26 | https://github.com/nousresearch/hermes-agent |
| Stars | ~203,261 | GitHub API | 2026-06-26 | https://github.com/nousresearch/hermes-agent/stargazers |
| Install (Linux/macOS/WSL2) | `curl -fsSL https://hermes-agent.nousresearch.com/install.sh \| bash` | upstream README "Quick Install" | 2026-06-26 | https://github.com/nousresearch/hermes-agent#quick-install |
| Install (Windows native) | PowerShell: `iex (irm https://hermes-agent.nousresearch.com/install.ps1)` | upstream README | 2026-06-26 | https://github.com/nousresearch/hermes-agent |
| Start | `hermes` | upstream README "Getting Started" | 2026-06-26 | https://github.com/nousresearch/hermes-agent |
| Model pick | `hermes model` | upstream README | 2026-06-26 | https://github.com/nousresearch/hermes-agent |
| Setup wizard | `hermes setup` (or `hermes setup --portal` for Nous Portal) | upstream README | 2026-06-26 | https://github.com/nousresearch/hermes-agent |
| Gateway | `hermes gateway setup` + `hermes gateway start` (Telegram/Discord/Slack/WhatsApp/Signal) | upstream README | 2026-06-26 | https://github.com/nousresearch/hermes-agent |
| Doctor | `hermes doctor` | upstream README | 2026-06-26 | https://github.com/nousresearch/hermes-agent |
| Update | `hermes update` | upstream README | 2026-06-26 | https://github.com/nousresearch/hermes-agent |
| OpenClaw migrate | `hermes claw migrate` | upstream README | 2026-06-26 | https://github.com/nousresearch/hermes-agent |
| Skills standard | Compatible with agentskills.io open standard | upstream README | 2026-06-26 | https://github.com/nousresearch/hermes-agent |

---

## Tool: MCP Servers

| Field | Value | Source | Verified | URL |
|---|---|---|---|---|
| License | Apache-2.0 (new contributions) + MIT (existing code) — NOASSERTION in API | repo metadata + LICENSE | 2026-06-26 | https://github.com/modelcontextprotocol/servers |
| Stars | ~87,718 | GitHub API | 2026-06-26 | https://github.com/modelcontextprotocol/servers/stargazers |
| Reference servers | Everything, Fetch, Filesystem, Git, Memory, Sequential Thinking, Time | upstream README "Reference Servers" | 2026-06-26 | https://github.com/modelcontextprotocol/servers#-reference-servers |
| Archived servers | aws-kb-retrieval, brave-search, everart, github, gitlab, gdrive, google-maps, postgres, puppeteer, redis, sentry, slack, sqlite — moved to `servers-archived` | upstream README "Archived" | 2026-06-26 | https://github.com/modelcontextprotocol/servers-archived |
| Filesystem usage | `npx -y @modelcontextprotocol/server-filesystem <path>` | upstream README | 2026-06-26 | https://github.com/modelcontextprotocol/servers |
| Git usage | `uvx mcp-server-git --repository <path>` | upstream README | 2026-06-26 | https://github.com/modelcontextprotocol/servers |
| Fetch usage | `npx -y @modelcontextprotocol/server-fetch` | upstream README | 2026-06-26 | https://github.com/modelcontextprotocol/servers |
| Memory usage | `npx -y @modelcontextprotocol/server-memory` | upstream README | 2026-06-26 | https://github.com/modelcontextprotocol/servers |
| Registry | Browse all published servers at registry.modelcontextprotocol.io | upstream README note | 2026-06-26 | https://registry.modelcontextprotocol.io/ |

> **Drift note:** `server-github`, `server-postgres`, `server-slack` etc. are
> **archived** — they moved to `modelcontextprotocol/servers-archived`. Do not
> reference them as current. The 6 reference servers that remain active are
> listed above.

---

## Tool: skills.sh

| Field | Value | Source | Verified | URL |
|---|---|---|---|---|
| Install a skill | `npx skillsadd <owner/repo>` | skills.sh homepage | 2026-06-26 | https://www.skills.sh/ |
| All-time installs | ~779,960 (shown on leaderboard) | skills.sh homepage "All Time" | 2026-06-26 | https://www.skills.sh/ |
| Supported agents | Claude Code, Cursor, Codex, GitHub Copilot, Windsurf, Gemini, Cline, AMP, Antigravity, ClawdBot | skills.sh homepage "Agents" | 2026-06-26 | https://www.skills.sh/ |
| Top skill | find-skills (vercel-labs/skills) | skills.sh leaderboard | 2026-06-26 | https://www.skills.sh/ |
| Standard | Open source on GitHub, compatible with agentskills.io | skills.sh homepage | 2026-06-26 | https://www.skills.sh/ |

> **Drift note:** Previous devstrata README claimed "885k installs". The
> skills.sh leaderboard shows ~779,960 all-time as of 2026-06-26. Corrected.

---

## Tool: Obsidian

| Field | Value | Source | Verified | URL |
|---|---|---|---|---|
| License | Proprietary freeware (app); notes are plain Markdown (no lock-in) | Obsidian site + community knowledge | 2026-06-26 | https://obsidian.md |
| Releases repo | Community plugins + themes list | obsidianmd/obsidian-releases | 2026-06-26 | https://github.com/obsidianmd/obsidian-releases |
| Download | obsidian.md (free, no account) | Obsidian site | 2026-06-26 | https://obsidian.md |
| Open alternative | Logseq (same Markdown file format, open-source) | community knowledge | 2026-06-26 | https://logseq.com |

---

## Re-verification procedure

Star counts and install commands drift. To re-verify everything:

```bash
# 1. Run the drift checker (reports installed vs latest, per tool)
./scripts/update.sh

# 2. Re-crawl upstream READMEs (manual, monthly)
#    The URLs in this file are the canonical sources.

# 3. Update the "Verified" dates in this file when you re-check.

# 4. If a claim can no longer be verified, move it to KNOWN_ISSUES.md
#    as a drift item — do not silently delete it.
```

---

## Claims we could NOT verify

None as of 2026-06-26. Every numeric claim in the README now has a source row
above. If you find a claim with no source, open an issue — it should not exist.