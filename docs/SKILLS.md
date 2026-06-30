# SKILLS.md — devstrata

> All agent skills used in this stack, what each does, and when to install them.
> Skills are installed via skills.sh: `npx skillsadd <owner/repo>`

---

## ECC — the batteries-included alternative to composing your own L4/L5

The default devstrata stack composes its L4 (method) + L5 (skills/agent) layer from
three independent tools: **Superpowers** (TDD + methodology), **GSD Core** (phase
workflow), and **skills.sh** (open skill registry). This is the composition path —
principle #1.

If you want a **single batteries-included pack** instead of composing your own,
[**ECC**](https://github.com/affaan-m/ECC) (affaan-m/ECC, 223k stars, MIT) is the
alternative: 277 skills, 67 agents, hooks (session memory, continuous learning,
verification loops), 12-language rules, a Tkinter dashboard, and a Rust control-plane
prototype. It's a monolith — you install all of ECC or none of it — so it's an
**opt-in replacement** for L4+L5, not a composable tool.

### When to pick ECC over the composed default

| Pick the composed default (Superpowers + GSD + skills.sh) | Pick ECC (`--with-ecc`) |
|---|---|
| You want to swap individual tools (e.g. replace GSD with another workflow) | You want 277 skills ready to go, no assembly |
| You want each tool to have its own upstream + license + maintainer | You want one pack, one update path, one maintainer |
| You're learning how agent stacks compose (principle #10) | You're shipping product and want maximum capability now |

### How to install ECC

ECC is a plugin/marketplace install, not a CLI install — it must be done inside
your agent. devstrata's `--with-ecc` flag prints the official commands; it does
not auto-install ECC (that would bypass the marketplace, which is ECC's supported
path).

```bash
# Tell devstrata you want ECC (prints the install commands in the output):
./scripts/install.sh --pro --with-ecc

# Then run these inside Claude Code (the official ECC install path):
/plugin marketplace add https://github.com/affaan-m/ECC
/plugin install ecc@ecc

# Or the CLI installer (works across Claude Code, Codex, OpenCode, Cursor):
npx ecc-install --profile full --target claude
```

> **Don't layer both.** Installing ECC on top of Superpowers + GSD + skills.sh
> causes skill-name conflicts. Pick one path: the composed default, OR ECC.
> See `scripts/agent-isolate.sh` if you need to separate skill dirs.

### What ECC replaces in the devstrata stack

| devstrata layer | Default (composed) | With `--with-ecc` |
|---|---|---|
| L4 Method | Superpowers (TDD, brainstorming, subagent-driven) | ECC's 277 skills (includes TDD, verification, parallelization) |
| L4 Workflow | GSD Core (Discuss→Plan→Execute→Verify→Ship) | ECC's orchestrator family + worktree-lifecycle service |
| L5 Skills | skills.sh (anthropics, superpowers, graphify, mattpocock) | ECC's 277 skills + 67 agents + hooks |
| L5 Agent | Hermes Agent (pro) or OpenCode (lite/full) | Hermes/OpenCode still used — ECC is a pack, not an agent shell |

ECC does **not** replace L0-L3 + L6 (Shannon, HelixDB, Mem0, MCP, Headroom,
Graphify, Obsidian) — those are the composed backbone and ECC doesn't provide them.

---

## What are skills?

Skills are reusable `SKILL.md` files that inject procedural knowledge into
your coding agent. They work across Claude Code, OpenCode, Cursor, Codex,
Copilot, Gemini CLI, Windsurf, Zed, and Hermes.

Think of them as the npm of agent capabilities — install once, available
in every session.

---

## Core Skills (install for all profiles)

### Anthropic Official Skills
```bash
npx skillsadd anthropics/skills
```
Installs: `docx`, `xlsx`, `pptx`, `frontend-design`, `skill-creator`,
`pdf`, `file-reading`, `pdf-reading`, `product-self-knowledge`

When to use: Always. These are foundational document and design skills.

---

### Superpowers Methodology Skills
```bash
npx skillsadd obra/superpowers
```
Installs all of:

| Skill | What it enforces |
|---|---|
| `brainstorming` | Clarify requirements before touching code |
| `writing-plans` | Break work into 2–5 min tasks with test cases |
| `test-driven-development` | RED → GREEN → REFACTOR — no shortcuts |
| `executing-plans` | Dispatch subagents per task |
| `systematic-debugging` | Structured debugging protocol |
| `requesting-code-review` | Two-stage review: spec then quality |
| `receiving-code-review` | How to process review feedback |
| `using-git-worktrees` | Parallel feature branches |
| `finishing-a-development-branch` | Clean branch + PR process |
| `dispatching-parallel-agents` | Spawn concurrent subagents |
| `verification-before-completion` | Gate before marking done |

When to use: Always. This is the methodology backbone of the stack.

---

### Graphify Skill
```bash
npx skillsadd safishamsi/graphify
```
Teaches your agent how to use Graphify to answer codebase questions.

Key commands injected:
- `graphify query "<question>"` — ask about code structure
- `graphify . --update` — refresh graph after changes
- `graphify export callflow-html` — generate architecture docs

When to use: Always. Required for L3 codebase intelligence layer.

---

### Matt Pocock Skills
```bash
npx skillsadd mattpocock/skills
```
Installs: `tdd`, `triage`, `to-prd`, `diagnose`, `prototype`, `teach`

| Skill | What it does |
|---|---|
| `triage` | Categorise and prioritise incoming issues |
| `to-prd` | Turn a rough idea into a structured PRD |
| `diagnose` | Systematic root-cause analysis |
| `prototype` | Fast proof-of-concept without over-engineering |
| `teach` | Explain concepts to non-technical stakeholders |

When to use: Full and pro profiles. Especially useful for product-minded engineers.

---

### Mem0 Skills
```bash
npx skills add https://github.com/mem0ai/mem0 --skill mem0
npx skills add https://github.com/mem0ai/mem0 --skill mem0-integrate
npx skills add https://github.com/mem0ai/mem0 --skill mem0-cli
```

| Skill | What it does |
|---|---|
| `mem0` | SDK knowledge — how to build with Mem0 |
| `mem0-integrate` | Wires Mem0 into an existing repo (test-first pipeline) |
| `mem0-cli` | CLI commands for memory management |

When to use: Full and pro profiles. Required for L1 memory layer.

---

## Domain-Specific Skills (install as needed)

### Supabase + Postgres
```bash
npx skillsadd supabase/agent-skills
```
When to use: If your project uses Supabase or PostgreSQL.

### Vercel + Next.js + React
```bash
npx skillsadd vercel-labs/agent-skills
```
When to use: Frontend or full-stack projects.

### Firebase
```bash
npx skillsadd firebase/agent-skills
```
When to use: Projects using Firebase or Firestore.

---

## How Skills Work

Skills are loaded into your agent's context at session start. They are
plain Markdown files — human-readable and version-controlled.

```
~/.config/opencode/skills/    ← OpenCode
~/.claude/skills/             ← Claude Code
~/.hermes/skills/             ← Hermes
```

To list installed skills:
```bash
npx skillsadd --list
```

To add a custom skill for your project:
```bash
# Create a SKILL.md in your project
cat > SKILL.md << 'EOF'
---
name: my-project
description: "Context and rules for this specific project"
---
# Project: MyApp

## Stack
- Python 3.12 + FastAPI
- PostgreSQL + HelixDB
- Messaging: [Kafka / RabbitMQ / etc.] (async consumers only)

## Rules
- Always check graphify-out/graph.json before answering architecture questions
- Use type hints in all Python
- Conventional commits
EOF

# Install it
npx skillsadd .
```

---

## Skills vs MCP Servers

These are different things. Do not confuse them.

| | Skills (skills.sh) | MCP Servers |
|---|---|---|
| What they are | Markdown knowledge files | Running processes |
| What they do | Teach agents *how* to work | Give agents *access* to tools |
| Example | "how to write a PRD" | "read this file", "query this DB" |
| Install with | `npx skillsadd` | `.mcp.json` |
| Runtime cost | None (loaded into context) | Process running on a port |

You need both. Skills provide methodology. MCP servers provide data access.
