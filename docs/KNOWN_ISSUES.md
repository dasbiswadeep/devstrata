# KNOWN_ISSUES.md — devstrata

> Honest documentation of every known limitation, weak point, and failure mode.
> This file is maintained with the same priority as the README.
> Each issue lists its **mitigation** — a script, config, or doc that reduces its impact.

---

## Critical Issues (will affect your experience)

### KI-001: Install commands will rot
**Status:** Permanent / by design — **mitigated**
**Severity:** Medium (down from High — two drift-detection tools now)

All 11 upstream tools update independently. Install commands, Docker compose
configs, MCP server parameters, and skill names change without notice. Any
install.sh here will drift within weeks.

**Mitigations:**
1. **`./scripts/update.sh`** — reports installed versions for headroom, graphify,
   mem0, helix, hermes + points you to the correct upgrade command per tool.
2. **`./scripts/version-check.sh`** — stronger: actually queries PyPI + GitHub
   APIs + npm registry to compare installed vs latest. Exits 1 on drift.
3. **`./scripts/validate-mcp.sh`** — validates every `.mcp.json` server command
   exists on PATH. Catches the most common rot failure (tool renamed/removed).

Neither auto-upgrades (deliberate — see README "Does devstrata auto-adopt?").
Run weekly: `./scripts/version-check.sh && ./scripts/validate-mcp.sh .mcp.json`

**Example of what breaks:**
- Mem0 changed Docker bootstrap from `docker compose up -d` to `make bootstrap` in 2026
- Graphify changed its CLI from `graphify` to `graphifyy` (pip package name)
- MCP servers archived 11 reference implementations to a separate repo

---

### KI-002: Three overlapping memory systems
**Status:** **Resolved** (June 2026) — sync script added
**Severity:** Low (down from High — sync closes the gap)

Mem0, MCP Memory server, and Hermes FTS5 all store "memory" but with
different schemas, retrieval methods, and inconsistent content.

**Symptom:** Agent gives different answers depending on which memory it queries
first. "What database does this project use?" may return different answers from
Mem0 vs Hermes FTS5.

**Resolutions:**
1. **Domain split enforced** — see [MEMORY_DOMAINS.md](MEMORY_DOMAINS.md).
   MCP Memory server is disabled by default. Hermes FTS5 is conversation-only.
   Mem0 owns semantic long-term facts.
2. **`./scripts/sync-memory.sh --user-id <project>`** — exports Mem0 facts to
   Obsidian as a human-readable Markdown view, with an INDEX.md for Dataview.
   Closes the "not fully solved: no automatic sync between Mem0 and Obsidian" gap.
   One-way export (Mem0 is source of truth; Obsidian is a review view — do NOT
   edit expecting sync back).

**Remaining gap:** Sync is one-way (Mem0 → Obsidian). Obsidian → Mem0 remains
manual by design — human-reviewed decisions only should enter Mem0.

---

### KI-003: No process supervision
**Status:** **Resolved** (June 2026)
**Severity:** Low (down from Medium-High)

The full stack runs 5–6 processes simultaneously. If any process dies silently,
agents give degraded or wrong answers without obvious errors. **All processes
now have a supervision path:**

| Process | Supervision mechanism | Status |
|---|---|---|
| Mem0 (:3000) | `configs/docker-compose.yml` — `restart: unless-stopped` + healthcheck | ✅ Docker auto-restart |
| HelixDB (:6969) | `configs/com.helixdb.dev.plist` (macOS launchd) + `configs/helixdb.service` (Linux systemd) — `KeepAlive`/`Restart=always` | ✅ OS-level auto-restart |
| Headroom (:8787) | `configs/com.devstrata.headroom.proxy.plist` (macOS) + `configs/headroom-proxy.service` (Linux) — `KeepAlive`/`Restart=always` | ✅ OS-level auto-restart |
| Headroom watchdog | `configs/com.devstrata.headroom-watchdog.plist` (macOS, every 120s) + `configs/headroom-watchdog.timer` (Linux systemd timer) — runs `scripts/headroom-watchdog.sh` | ✅ periodic auto-recovery |
| Ollama (:11434) | Ollama's own installer registers the service on macOS/Linux | ✅ native |
| Graphify MCP | Spawned by agent via `.mcp.json` — no long-running process | ✅ N/A |

See [`docs/SUPERVISION.md`](SUPERVISION.md) for setup commands.

**Remaining gap:** HelixDB has no official Docker image (verified 2026-06-26,
see SOURCES.md), so it cannot join the docker-compose stack yet. When one ships
upstream, add a `helix` service block to `configs/docker-compose.yml` and the
launchd/systemd templates can be retired.

**End-of-day teardown:** `scripts/end-of-day.sh` refreshes the graph, exports to
Obsidian (--pro), and optionally stops Headroom to free RAM.

---

### KI-004: Hardware ceiling is real
**Status:** By design / **mitigated** by recommender
**Severity:** Low (down from Medium — users now get a recommendation before install)

| Profile | Minimum RAM | Comfortable RAM |
|---|---|---|
| --lite | 8GB | 16GB |
| --full | 16GB | 24GB |
| --pro | 24GB | 32GB+ |

Running --pro on 16GB will cause Ollama to swap models to disk, HelixDB to
OOM-kill, and Mem0 Docker stack to thrash.

**Mitigation:** **`./scripts/recommend-profile.sh`** — detects your RAM (sysctl
on macOS, /proc/meminfo on Linux), checks for cloud API keys (allows a higher
profile on less RAM via cloud LLM), detects Apple Silicon (better GPU offload),
and recommends the right profile *before* you install. Below 8GB with no cloud
key → exits with guidance on where to get one.

**Fallback for constrained hardware:**
- Use cloud backends (Claude, GPT) instead of Ollama local — set `ANTHROPIC_API_KEY`
  in `headroom.env`, comment out `OLLAMA_MODEL`. Skips the ~9GB Ollama footprint.
- Use Mem0 cloud instead of self-hosted (skip the Docker stack).

---

## Moderate Issues

### KI-005: Shannon is AGPL-3.0, not MIT
**Status:** Licensing constraint — **documented**
**Severity:** Medium (context-dependent)

Shannon Open Source is AGPL-3.0. If you build a SaaS product using devstrata
and expose Shannon functionality to external users, AGPL requires you to
open-source your modifications.

For internal development use (which is devstrata's intended purpose), AGPL
has no practical impact.

**Mitigation:** Documented in ARCHITECTURE.md + SECURITY.md. Shannon is L0 —
a development tool, not a production dependency. Commercial licensing available
from shannon@keygraph.io for SaaS use.

---

### KI-006: Hermes vs OpenCode — primary agent unclear
**Status:** Design decision per user — **mitigated** by isolator
**Severity:** Low (down from Medium — isolation prevents conflicts)

Both Hermes and OpenCode are capable agent shells with overlapping capabilities.
Running both creates skill config conflicts.

**Mitigation:** **`./scripts/agent-isolate.sh`** — detects if OpenCode skills
is symlinked to Hermes skills (the conflict source), unlinks them to make
independent, and writes a registry of which skills are in which agent. Recommends
picking ONE primary.

**Recommendation:**
- Use Hermes if you want self-improvement, Telegram access, scheduling
- Use OpenCode if you want fast, lightweight, skills.sh-native coding sessions
- Pick one as primary. Keep the other as an occasional alternative.
- Don't run both simultaneously in the same project (they'll fight over .gsd/STATE.md)

---

### KI-007: Graphify --obsidian export is one-directional
**Status:** Upstream limitation — **documented**
**Severity:** Low-Medium

`graphify . --obsidian` exports to Obsidian vault. Changes made in Obsidian do
not sync back to Graphify. The graph is always the source of truth; Obsidian is
a human-readable view. This is by design — Graphify's graph is derived from
source code, not from notes.

**Mitigation:** Documented in `profiles/pro/PROFILE.md` + `docs/INSTRUCTIONS.md`
Step 11. Use `graphify . --update` to refresh the graph after code changes,
then re-export to Obsidian.

---

### KI-008: Windows native not supported
**Status:** Known — **mitigated** by WSL2 helper
**Severity:** Low (for target audience)

Shannon requires WSL2 on Windows. Hermes has native Windows support (PowerShell
install). The rest of the stack works via WSL2.

**Mitigation:** **`./scripts/wsl2-check.sh`** — detects WSL2 via `/proc/version`,
checks Docker Desktop integration, systemd availability (for service templates),
and documents the Ollama-in-WSL vs Ollama-on-Windows-host options (with the
host-IP env var workaround).

**Recommendation:** Use WSL2 for the devstrata stack on Windows. It's the
supported path. Hermes can be installed native Windows if you prefer it there.

---

## Minor Issues

### KI-009: skills.sh install requires Node.js 18+
**Status:** Known — **mitigated** in install.sh
**Severity:** Low (down from Low+ — install.sh now fails fast with a clear message)
Many developer machines run older Node. `npx skillsadd` will fail silently on
Node 16 or earlier.
**Mitigation:** install.sh now parses `node --version` to extract the major
version and fails fast with a clear upgrade message if < 18 (instead of letting
skillsadd fail silently later).
**Fix if you hit it:** `node --version`, upgrade from https://nodejs.org

### KI-010: Headroom proxy kills itself if Ollama goes offline
**Status:** Known — **mitigated** by watchdog
**Severity:** Low (down from Low+ — watchdog auto-recovers)
If Ollama crashes during a session, the Headroom proxy loses its backend and
needs a full restart.
**Mitigation:** **`./scripts/headroom-watchdog.sh`** — checks both Ollama
(:11434) and Headroom (:8787) every 120s. If Ollama is down, restarts it AND
restarts Headroom (which lost its backend). Wire into launchd/systemd via the
templates in `configs/`.
**Manual fix:** `pkill -f "headroom proxy" && headroom proxy --port 8787 &`

### KI-011: Graphify graph goes stale
**Status:** Known — **mitigated** by git hook
**Severity:** Low
The graph does not auto-update when files change. Run `graphify . --update`
after significant code changes. `graphify hook install` adds a post-commit git
hook that rebuilds the graph automatically. `end-of-day.sh` also runs
`graphify . --update` as part of the evening routine.

### KI-012: Mem0 Docker bootstrap requires internet access
**Status:** Known — **mitigated** by pre-pull
**Severity:** Low (down from Low+ — install.sh pre-pulls the image)
Self-hosted Mem0 pulls images on first run. Air-gapped or restricted network
environments will fail.
**Mitigation:** install.sh now runs `docker compose pull mem0` during install
(for --full and --pro), so the image is local by the time you first run
`docker compose up -d`. If pre-pull fails (no network at install time), the
warning is logged but install continues.
**Fix for air-gapped:** Use Mem0 Python library (no Docker) — `pip install mem0ai`.

---

## Won't Fix

### WF-001: Obsidian is not open-source
**Status:** Won't fix — accepted tradeoff
**Severity:** Low (notes are plain Markdown, no lock-in)
Obsidian is proprietary freeware. Notes are plain Markdown (no lock-in) but
the app itself is closed. This is an accepted tradeoff for its functionality.
Alternative: Logseq (open-source) uses the same file format.

### WF-002: MCP server configs break when tools update
**Status:** Won't fix structurally — **mitigated** by validator
**Severity:** Low (down from Medium — validate-mcp.sh catches it before agent start)
Tool update → MCP server command or args change → .mcp.json breaks. There is no
automated solution because the break is upstream. Manual update required.
**Mitigation:** **`./scripts/validate-mcp.sh .mcp.json`** — checks every server's
command exists on PATH before you start your agent. Catches renamed/removed
binaries. Run after any `./scripts/update.sh` that upgrades a tool, or before
any agent session if you're unsure. Exits 1 if any server is broken.

### WF-003: Agent quality depends on LLM backend quality
**Status:** Won't fix — by design
**Severity:** None (not a devstrata bug)
devstrata is a composition layer, not an intelligence layer. A weak LLM produces
weak results regardless of how many tools are wired together. Use the strongest
model your budget allows; see `docs/BACKENDS.md` for the decision guide.