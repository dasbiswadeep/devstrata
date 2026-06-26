# ARCHITECTURE.md — devstrata

> Layer diagram, component map, and data flow for the full devstrata stack.

---

## Layer Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│  L0 — SECURITY (run per PR, not in daily loop)                      │
│  Shannon — AI pentester · prompt injection guard · OWASP coverage   │
│  npx @keygraph/shannon start -u $APP_URL -r .                       │
└─────────────────────────────────────────────────────────────────────┘
                              ↑ gates PRs
┌─────────────────────────────────────────────────────────────────────┐
│  L6 — PKM (human-readable knowledge vault)                          │
│  Obsidian · local Markdown · graph view · 1000+ plugins             │
│  graphify --obsidian exports → vault · Hermes writes daily notes    │
└─────────────────────────────────────────────────────────────────────┘
                              ↓ decisions captured
┌─────────────────────────────────────────────────────────────────────┐
│  L5 — AGENT SHELL + SKILL REGISTRY                                  │
│  Hermes Agent (self-improving, learning loop, 200+ models)          │
│  skills.sh   (npx skillsadd — ~780k installs)                        │
└─────────────────────────────────────────────────────────────────────┘
                              ↓ skills fire per task
┌─────────────────────────────────────────────────────────────────────┐
│  L4 — METHODOLOGY + WORKFLOW                                        │
│  Superpowers (TDD · brainstorm · subagent-driven-dev)               │
│  GSD Core   (Discuss → Plan → Execute → Verify → Ship · STATE.md)   │
└─────────────────────────────────────────────────────────────────────┘
                              ↓ phase gates + skill triggers
┌─────────────────────────────────────────────────────────────────────┐
│  L3 — CODEBASE INTELLIGENCE                                         │
│  Graphify · tree-sitter · 28 languages · MCP server · --obsidian   │
└─────────────────────────────────────────────────────────────────────┘
                              ↓ graph queries via MCP
┌─────────────────────────────────────────────────────────────────────┐
│  L2 — COMPRESSION + PROTOCOL                                        │
│  Headroom proxy :8787  (60–95% token compression, cross-agent)      │
│  MCP Servers           (filesystem · git · memory · fetch · custom) │
└─────────────────────────────────────────────────────────────────────┘
                              ↓ compressed, tool-accessed context
┌─────────────────────────────────────────────────────────────────────┐
│  L1 — MEMORY + STORAGE                                              │
│  Mem0    · semantic long-term memory · 94.8% LongMemEval recall     │
│  HelixDB · graph + vector + relational · Rust · OLTP · ACID        │
└─────────────────────────────────────────────────────────────────────┘
                              ↓ routes to chosen backend
┌─────────────────────────────────────────────────────────────────────┐
│  LLM BACKEND (swap anytime — all layers adapt)                      │
│  Ollama local · Ollama Cloud · Claude · ChatGPT · Gemini · DeepSeek│
│  Hermes/NousPortal · Kimi · GLM · your own endpoint                │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Per Agent Turn

```
User prompt
  ↓
Agent shell (Hermes / OpenCode / Claude Code)
  ↓
skills.sh fires (brainstorm? TDD? plan?)
  ↓
GSD Core: which phase? (Discuss/Plan/Execute/Verify/Ship)
  ↓
Superpowers: enforce methodology for this task type
  ↓
MCP tool calls dispatched in parallel:
  ├── graphify         → "what calls this function?"
  ├── mem0             → "what did I decide about X before?"
  ├── helix            → "query entity graph"
  ├── git              → "diff last 3 commits"
  └── filesystem       → "read config file"
  ↓
All MCP results → Headroom proxy (compress 60–95%)
  ↓
Compressed context → LLM backend
  ↓
LLM response → Headroom (shape output tokens)
  ↓
Agent executes → STATE.md updated, HelixDB written, Mem0 updated
  ↓
Shannon (per-PR): scan for vulnerabilities introduced
  ↓
Obsidian: decisions captured as linked Markdown notes
```

---

## Memory Domain Split

Four memory systems coexist. They serve different purposes and must NOT overlap:

| System | Owns | Example |
|---|---|---|
| Mem0 | Long-term semantic facts | "User prefers async message consumers" |
| Graphify | Codebase structure | "auth_handler calls validate_token" |
| Hermes FTS5 | Conversation history | "Last week I debugged a database offset issue" |
| Obsidian | Human-curated knowledge | design docs, research notes |

**The MCP Memory server (`@modelcontextprotocol/server-memory`) is redundant with Mem0.**
Use Mem0 as your long-term memory source of truth. Remove the MCP memory server if both are installed.

---

## Process Map (what runs where)

| Process | Port | Profile | Restart policy |
|---|---|---|---|
| Headroom proxy | 8787 | lite+ | Add to shell startup |
| HelixDB local | 6969 | full+ | `helix start dev --disk` |
| Mem0 server | 3000 | full+ | Docker: `restart: unless-stopped` |
| Graphify MCP | 8788 | lite+ | Spawned by agent via .mcp.json |
| Hermes TUI | — | pro | Manual: `hermes` |
| Shannon worker | — | full+ | Per-PR: `npx @keygraph/shannon start` |

---

## Profile Breakdown

### --lite (8GB+ RAM)
- Headroom proxy
- Graphify (Ollama backend)
- MCP: filesystem + git + fetch
- Primary agent: OpenCode or Claude Code
- LLM: Ollama local (qwen2.5-coder:14b recommended)

### --full (16GB+ RAM)
Everything in lite, plus:
- Mem0 (self-hosted Docker)
- HelixDB local instance
- MCP: helix + mem0
- Shannon (per-PR security scanning)

### --pro (24GB+ RAM, M-series Mac recommended)
Everything in full, plus:
- Hermes Agent (self-improving shell)
- Obsidian vault sync (graphify --obsidian)
- Hermes messaging gateway (Telegram/Slack)
- LLM: mix of Ollama local + cloud fallback

---

## Shannon Security Layer

Shannon sits at L0 — below and separate from the development loop. It is NOT part of the daily workflow. It runs:

1. Per PR (CI/CD gate)
2. Before any major release
3. When you add a new MCP server (prompt injection risk)
4. When you onboard a new external repo into Graphify

```bash
# Run Shannon on your project
npx @keygraph/shannon start \
  -u http://localhost:3000 \
  -r . \
  -w pre-release-audit

# View report
cat ~/.shannon/workspaces/pre-release-audit/deliverables/*.md
```

**Why Shannon matters for this stack specifically:**
- Graphify reads raw source files — malicious repos can inject prompts through code comments
- MCP filesystem server has controlled but real file access
- Hermes agent can be influenced by content it reads
- Mem0 stores facts that could be poisoned by malicious input

Shannon catches these before they reach production.

---

## .mcp.json (full stack)

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    },
    "git": {
      "command": "uvx",
      "args": ["mcp-server-git", "--repository", "."]
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    },
    "helix": {
      "command": "helix",
      "args": ["mcp", "--url", "http://localhost:6969"]
    },
    "mem0": {
      "command": "mem0",
      "args": ["mcp", "--url", "http://localhost:3000"]
    },
    "graphify": {
      "command": "graphify",
      "args": ["mcp", "--graph", "./graphify-out/graph.json"]
    }
  }
}
```
