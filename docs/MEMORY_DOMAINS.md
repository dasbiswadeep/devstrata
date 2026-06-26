# MEMORY_DOMAINS.md — devstrata
> The definitive domain split for the four memory systems in this stack.
> Violating these boundaries causes agents to give contradictory answers.

## The Four Domains

### Domain 1: Mem0 — Semantic Long-Term Facts
**Owns:** Project decisions, user preferences, architectural choices, debugging patterns
**Does NOT own:** Conversation transcripts, file contents, codebase structure

```bash
# Store a decision
mem0 add "Project uses async message consumers, never sync polling" --user-id myproject

# Recall
mem0 search "message consumer pattern" --user-id myproject
```

### Domain 2: Graphify — Codebase Structure
**Owns:** Functions, classes, dependencies, call graphs, file relationships
**Does NOT own:** Why decisions were made, historical context

```bash
graphify query "what calls auth_handler?"
graphify query "what does validate_token depend on?"
```

### Domain 3: Hermes FTS5 — Conversation History
**Owns:** What was discussed in which session, debugging transcripts
**Does NOT own:** Structured facts, codebase structure

```bash
hermes sessions list                 # list recent sessions (find the one you want)
hermes sessions browse               # interactive browser for past sessions
hermes sessions stats                # session statistics
hermes insights --days 7             # token usage, costs, tool patterns over N days
# Note: Hermes FTS5 enables full-text search within the sessions browser, not a
# top-level `hermes search` command. Use `hermes sessions browse` to search session content.
```

### Domain 4: Obsidian — Human-Curated Knowledge
**Owns:** Research notes, design decisions you've reviewed, product thinking
**Does NOT own:** Auto-generated agent output (that goes in Mem0 or Hermes)

## What NOT to do

❌ Install the MCP Memory server alongside Mem0 — creates a 5th domain nobody asked for
❌ Let Hermes write to Mem0 automatically without filtering — poisons structured facts
❌ Store conversation history in Mem0 — wastes retrieval budget on transcripts
❌ Store architectural decisions only in Obsidian — agents can't query it

## Sync Strategy

| From | To | How | When |
|---|---|---|---|
| Graphify | Obsidian | `graphify . --obsidian` | Daily / per-PR |
| Mem0 | Obsidian | Manual or script | Weekly review |
| Hermes FTS5 | Mem0 | `hermes insights` → manual | When a pattern is confirmed |
| Obsidian | Mem0 | Manual | When a human-reviewed decision is confirmed |
