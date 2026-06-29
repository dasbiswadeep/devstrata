# FURTHER_READING.md — devstrata

> "What I cannot create, I do not understand." — Richard Feynman
>
> devstrata's guiding principle #10: *"The goal is not dependency — it is
> understanding. A developer who reads the docs, understands the architecture,
> and then builds their own custom stack from scratch has succeeded."*

This doc maps each devstrata layer to a **"build your own X from scratch"**
tutorial from [codecrafters-io/build-your-own-x](https://github.com/codecrafters-io/build-your-own-x)
(521k stars). If you want to understand what a devstrata tool actually does
under the hood — not just install it — pick a layer and build one.

---

## How to use this doc

1. Pick the devstrata layer you want to understand deeply
2. Click the tutorial link (filtered to build-your-own-x's curated list)
3. Build the thing from scratch in an evening or a weekend
4. Come back to devstrata with a mental model of what the upstream tool does

You don't have to build all 11. Pick the one whose layer you use most.

---

## Layer → build-your-own-x tutorial map

### L0 — Security (Shannon)

Shannon is an autonomous AI pentester — it reads source, plans attacks, executes
exploits, and reports proven vulnerabilities. There's no direct "build your own
AI pentester" tutorial, but you can build the foundation it depends on:

- **Build your own Web Server** ([Python](https://ruslanspivak.com/lsbaws-part1/) · [Node.js](https://build-your-own.org/webserver/)) — Shannon attacks web apps; understanding HTTP servers from scratch makes you understand the attack surface.
- **Build your own Network Stack** ([C](http://www.saminiir.com/lets-code-tcp-ip-stack-1-ethernet-arp/)) — the deeper layer Shannon's exploits traverse.

---

### L1 — Storage (HelixDB)

HelixDB is a graph + vector + relational database built in Rust. To understand
what it does, build a database from scratch:

- **Build your own Database** ([Go: B+Tree to SQL in 3000 lines](https://build-your-own.org/database/) · [C: step-by-step](https://cstack.github.io/db_tutorial/) · [Go: test-driven](https://trialofcode.org/database/)) — understand storage, indexing, and query execution.
- **Build your own Redis** ([Rust](https://tokio.rs/tokio/tutorial/setup) · [Python](http://charlesleifer.com/blog/building-a-simple-redis-server-with-python/) · [Go](https://www.build-redis-from-scratch.dev/)) — understand in-memory KV + persistence, which is what HelixDB's vector index feels like.
- **Build your own in-memory graph database** ([JavaScript](http://aosabook.org/en/500L/dagoba-an-in-memory-graph-database.html)) — the closest analog to HelixDB's graph model.

---

### L1 — Memory (Mem0)

Mem0 is a long-term semantic memory layer for AI agents (94.8% LongMemEval
recall). To understand what it does, build the primitives:

- **Build your own Redis** ([Python](http://charlesleifer.com/blog/building-a-simple-redis-server-with-python/)) — persistent KV store is the substrate Mem0 builds on.
- **Build your own Search Engine** ([Python: vector space indexing](https://boyter.org/2010/08/build-vector-space-search-engine-python/) · [Python: TF-IDF](https://stevenloria.com/tf-idf/)) — Mem0's hybrid retrieval (semantic + BM25 + entity) is a richer version of this.
- **Build your own Neural Network** ([Python: 11 lines](https://iamtrask.github.io/2015/07/12/basic-python-network/) · [Python: from scratch](https://victorzhou.com/blog/intro-to-neural-networks/)) — the embedding model Mem0 uses is a neural net; building one demystifies it.

---

### L2 — Protocol (MCP Servers)

MCP (Model Context Protocol) is a tool-access bus — your agent calls MCP
servers to read files, query git, fetch URLs. To understand it, build a server:

- **Build your own Web Server** ([Python](https://ruslanspivak.com/lsbaws-part1/) · [Node.js](https://build-your-own.org/webserver/) · [C#](https://www.codeproject.com/Articles/859108/Writing-a-Web-Server-from-Scratch)) — an MCP server IS a small web server with a specific protocol. Build one and the MCP abstraction dissolves.
- **Build your own Command-Line Tool** ([Rust](https://rust-cli.github.io/book/index.html) · [Go](https://flaviocopes.com/go-git-contributions/) · [Node.js](https://citw.dev/tutorial/create-your-own-cli-tool)) — some MCP servers are CLI wrappers; this teaches you how.

---

### L2 — Compress (Headroom)

Headroom compresses tool outputs 60–95% before they reach the LLM, using AST
parsing + a trained model (Kompress-v2). To understand the model half:

- **Build your own Neural Network** ([Python: from scratch](https://victorzhou.com/blog/intro-to-neural-networks/) · [Python: Zero to Hero (video)](https://www.youtube.com/playlist?list=PLAqhIrjkxbuWI23v9cThsA9GvCAUhRvKZ) · [C#: OCR](https://www.codeproject.com/Articles/11285/Neural-Network-OCR)) — Headroom's Kompress model is a neural net trained on agentic traces. Build one to understand what "trained compression" means.
- **Build your own Diff/Patch algorithm** (covered in [Build your own Git](https://benhoyt.com/writings/pygit/)) — Headroom's CodeCompressor does AST-aware diffing; understanding git's diff from scratch is the on-ramp.

---

### L3 — Knowledge (Graphify)

Graphify reads your codebase with tree-sitter + Claude vision and builds a
knowledge graph (71x fewer tokens per query vs raw files). To understand the
two halves:

- **Build your own Search Engine** ([Python: vector space](https://boyter.org/2010/08/build-vector-space-search-engine-python/) · [Python: TF-IDF](https://stevenloria.com/tf-idf/) · [Python: learning from feedback](https://medium.com/filament-ai/making-text-search-learn-from-feedback-4fe210fd87b0)) — Graphify's query engine is a richer version of this.
- **Build your own Git** ([Python: write yourself a Git](https://wyag.thb.lt/) · [Python: ugit](https://www.leshenko.net/p/ugit/) · [JavaScript: Gitlet](http://gitlet.maryrosecook.com/docs/gitlet.html)) — tree-sitter parsing + call-graph extraction is structurally similar to what git does to trees. Build git, understand graph extraction.

---

### L4 — Method (Superpowers)

Superpowers is a TDD + brainstorming + subagent-driven methodology that
enforces RED-GREEN-REFACTOR. To understand the testing half:

- **Build your own Git** ([Python](https://wyag.thb.lt/) · [Ruby](https://robots.thoughtbot.com/rebuilding-git-in-ruby)) — Superpowers' git-worktrees + branch-finish skills assume you understand git internals. Build git from scratch and the skills become obvious.
- **Build your own Command-Line Tool** ([Rust](https://rust-cli.github.io/book/index.html)) — Superpowers dispatches subagents via CLI; understanding CLI internals clarifies the dispatch.

---

### L4 — Workflow (GSD Core)

GSD Core is a phase-based workflow engine (Discuss → Plan → Execute → Verify → Ship)
that solves context rot by running heavy work in fresh-context subagents. To
understand the substrate:

- **Build your own Command-Line Tool** ([Rust](https://rust-cli.github.io/book/index.html) · [Go](https://flaviocopes.com/go-tutorial-lolcat/)) — GSD Core is a CLI that orchestrates phases; build a CLI to understand the orchestration.
- **Build your own Shell** ([C](https://brennan.io/2015/01/16/write-a-shell-in-c/) · [Go](https://sj14.gitlab.io/post/2018-07-01-go-unix-shell/) · [Rust](https://www.joshmcguigan.com/blog/build-your-own-shell-rust/)) — GSD's subagent dispatch is shell-like; building a shell demystifies process spawning.

---

### L5 — Skills (skills.sh)

skills.sh is an open agent skill registry — `npx skillsadd owner/repo` installs
a SKILL.md that injects procedural knowledge into your agent. To understand
what a skill actually is:

- **Build your own Command-Line Tool** ([Node.js](https://citw.dev/tutorial/create-your-own-cli-tool) · [Rust](https://rust-cli.github.io/book/index.html)) — skills.sh's installer is a CLI that fetches + writes markdown files; build one to see how simple it is.
- **Build your own Template Engine** ([JavaScript: 20 lines](http://krasimirtsonev.com/blog/article/Javascript-template-engine-in-just-20-line) · [Python](http://alexmic.net/building-a-template-engine/)) — a SKILL.md is a template the agent fills with context; building a template engine shows you the mechanism.

---

### L5 — Agent (Hermes Agent)

Hermes is a self-improving agent shell with FTS5 session search, scheduled cron,
and a messaging gateway (Telegram/Discord/Slack). To understand the pieces:

- **Build your own Bot** ([Python: Slack bot](https://www.fullstackpython.com/blog/build-first-slack-bot-python.html) · [Node.js: Telegram bot](https://www.sohamkamani.com/blog/2016/09/21/making-a-telegram-bot/) · [Node.js: Discord bot](https://discordjs.guide/)) — Hermes' messaging gateway is a multi-platform bot; build one to understand the abstraction.
- **Build your own Database** ([Go](https://build-your-own.org/database/)) — Hermes' FTS5 session search is SQLite full-text search; building a database teaches you what FTS5 indexes.
- **Build your own Command-Line Tool** ([Rust](https://rust-cli.github.io/book/index.html)) — Hermes is a TUI + CLI; build a CLI to understand the surface.

---

### L6 — PKM (Obsidian)

Obsidian is a local-first Markdown knowledge vault with graph view. To
understand the text-editing + linking half:

- **Build your own Text Editor** ([C: kilo](https://viewsourcecode.org/snaptoken/kilo/) · [Rust: hecto](https://www.flenker.blog/hecto/) · [Python (video)](https://www.youtube.com/watch?v=xqDonHEYPgA)) — Obsidian is a text editor + graph viewer; build a text editor to understand the editing half.
- **Build your own Search Engine** ([Python](https://boyter.org/2010/08/build-vector-space-search-engine-python/)) — Obsidian's search + graph view is a local search engine; build one to understand the indexing.

---

## The graduation path

A developer who:

1. Starts with `./scripts/install.sh --lite`
2. Uses devstrata for a month
3. Reads [ARCHITECTURE.md](ARCHITECTURE.md) + [GUIDING_PRINCIPLES.md](GUIDING_PRINCIPLES.md)
4. Picks one layer from this doc and builds it from scratch
5. Replaces one devstrata tool with their own build

…has succeeded. devstrata's goal was never to be a dependency. It was to be a
scaffold you eventually climb past.

---

## Source

All tutorials above are from [codecrafters-io/build-your-own-x](https://github.com/codecrafters-io/build-your-own-x)
(521k stars, MIT). devstrata is not affiliated with codecrafters; we link to
their curated list because it's the best "learn by building" resource that
aligns with our educational purpose (principle #10).

> Last verified: 2026-06-30. Tutorial links may drift — if a link breaks, open
> an issue and we'll update the mapping.