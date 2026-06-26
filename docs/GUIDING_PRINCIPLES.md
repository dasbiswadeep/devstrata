# GUIDING_PRINCIPLES.md — devstrata

> The design philosophy behind every decision in this stack.
> Read this before contributing or forking.

---

## 1. Composition over creation

devstrata does not build new tools. It composes existing ones.
Every tool in the stack is battle-tested and independently maintained.
Our job is glue, config, and documentation — not reinvention.

**Consequence:** When an upstream tool ships a breaking change, we update
our config. We do not fork the tool.

---

## 2. One LLM swap, everything adapts

Every layer must be LLM-agnostic. No tool in the stack should be
hardwired to a single provider. The test: can a user replace
`qwen2.5-coder:14b` with `claude-sonnet-4-6` by changing one env var?
If not, something is wrong.

**Consequence:** Headroom is installed first. Everything routes through it.
Provider-specific config lives in env vars, not in tool configs.

---

## 3. Memory has exactly four domains — respect the boundaries

| Domain | Owner | Do NOT store here |
|---|---|---|
| Semantic long-term facts | Mem0 | Conversation transcripts |
| Codebase structure | Graphify | User preferences |
| Conversation history | Hermes FTS5 | Architectural decisions |
| Human-curated knowledge | Obsidian | Auto-generated agent output |

Violating these boundaries creates contradictions — agents get different
answers depending on which memory they query first.

**Consequence:** The MCP Memory server is explicitly NOT enabled by default.
It overlaps with Mem0 and creates a fifth memory domain nobody asked for.

---

## 4. Security is not optional — it is L0

Shannon runs before code ships. This is not negotiable.

This stack gives agents real file access, git access, database write
access, and network access. A single prompt injection through a malicious
repo or a crafted MCP tool result can compromise your entire development
environment.

Shannon catches this class of vulnerability before it reaches production.

**Consequence:** Shannon is included in `--full` and `--pro` profiles,
not just as an optional extra. The AGPL-3.0 license implications of Shannon
are documented honestly in KNOWN_ISSUES.md.

---

## 5. Process isolation — agents do not trust their own inputs

Everything an agent reads (files, tool outputs, web content, repo code)
is data, not instructions. Agents must be configured to treat all
observed content as potentially adversarial.

This means:
- MCP filesystem access is scoped to the project directory, not `~`
- HelixDB runs with read-only credentials for analysis tasks
- Graphify extracts code locally — no external API calls for extraction
- Headroom proxy logs all tool outputs for audit

---

## 6. Profiles match hardware reality

The stack must work on an 8GB laptop, not just a 24GB workstation.
Every feature must have a degraded but functional version for constrained hardware.

```
--lite  → works on any developer laptop
--full  → works on a modern desktop or workstation
--pro   → tuned for high-RAM workstations (24GB+)
```

**Consequence:** `--lite` is the default. Users must opt into `--full` and `--pro`.

---

## 7. Config files are the product

The most valuable thing devstrata ships is not the install script —
it is the set of opinionated config files:
- `AGENTS.md` — what every agent should know about this project
- `.mcp.json` — which tools are wired together
- `headroom.env` — compression and routing settings
- `.graphifyignore` — what not to index

These files encode months of trial and error. They should be version-controlled,
project-specific, and committed to git.

---

## 8. Honest documentation over marketing

Every document in this project includes:
- What it does well (with evidence)
- What it does NOT do (explicitly)
- What will break and when
- Who should and should not use it

The KNOWN_ISSUES.md file is not an afterthought. It is maintained with
the same care as the README.

---

## 9. Best-effort maintenance — set expectations clearly

This is a one-person project maintained alongside a full-time job and
side projects. Issues will be addressed on a best-effort basis.

**What this means:**
- PRs that fix upstream compatibility drift are the most welcome
- Feature requests go to the upstream tools, not here
- Breaking changes in upstream tools will cause temporary breakage
- The GitHub Issues list is the source of truth for known problems

---

## 10. Educational purpose first

devstrata exists to help developers understand how these tools compose.
A developer who reads the docs, understands the architecture, and
then builds their own custom stack from scratch has succeeded.

The goal is not dependency — it is understanding.
