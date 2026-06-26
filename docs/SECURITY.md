# SECURITY.md — devstrata

> Threat model, Shannon integration, and security guidelines for the stack.

---

## Why Security is L0

This stack gives agents significant system access:
- MCP filesystem server: read/write to project directory
- MCP git server: read/write to git history
- HelixDB: read/write to entity graph database
- Mem0: read/write to long-term memory store
- Headroom proxy: all LLM traffic passes through it
- Graphify: reads all source files in the project

**A single prompt injection can compromise all of these simultaneously.**

---

## Threat Model

### T1 — Prompt Injection via Source Code
An attacker embeds instructions in source code comments, docstrings, or
variable names. Graphify reads these during extraction. The agent processes
them as data but the LLM may treat them as instructions.

**Mitigation:** Shannon scans for this. Graphify extraction is local
(no external API calls). Treat all observed content as data, not commands.

### T2 — Prompt Injection via MCP Tool Results
A malicious file or database record returns content that re-instructs
the agent ("Ignore previous instructions and...").

**Mitigation:** Configure agents to treat MCP results as data.
Shannon tests your app for injection vulnerabilities before they ship.

### T3 — Memory Poisoning via Mem0
An attacker (or a poorly-scoped task) stores false facts in Mem0 that
persist across sessions and affect future decisions.

**Mitigation:** Scope mem0 user_id to specific projects.
Review `mem0 list --user-id <project>` periodically.
Mem0's entity linking helps detect contradictory facts.

### T4 — Credential Exposure via Agent
An agent with filesystem access could read `.env` files and exfiltrate
credentials through tool calls or LLM context.

**Mitigation:**
- Scope MCP filesystem to project directory only (not `~`)
- Never put real API keys in files the agent can read
- Use headroom.env for agent config, not .env in project root
- Add sensitive paths to `.graphifyignore`

### T5 — Supply Chain via Upstream Tools
Any of the 11 tools could ship malicious updates.

**Mitigation:**
- Pin versions in install.sh
- Review changelogs before updating
- Shannon can scan the devstrata install itself

---

## Shannon Integration

Shannon is an autonomous, white-box AI pentester for web applications and APIs.
It analyzes your source code, identifies attack vectors, and executes real
exploits to prove vulnerabilities before they reach production.

### License note
Shannon Lite is AGPL-3.0. If you are building a commercial SaaS product,
review the AGPL terms carefully. For internal development use, AGPL is
not a concern.

### When to run Shannon

```
Per PR        → catch vulnerabilities before merge
Pre-release   → full audit before shipping
New MCP server → prompt injection risk surface changed
New external repo → unknown code entering Graphify
Monthly       → baseline security health check
```

### Quick Shannon run

```bash
# Prerequisites: Docker, Node.js 18+, Anthropic API key
export ANTHROPIC_API_KEY=sk-ant-...

# Basic run against local dev server
npx @keygraph/shannon start \
  -u http://localhost:8000 \
  -r . \
  -w $(date +%Y-%m-%d)-security-scan

# Monitor
npx @keygraph/shannon logs $(date +%Y-%m-%d)-security-scan

# View report
ls ~/.shannon/workspaces/$(date +%Y-%m-%d)-security-scan/deliverables/
```

### Shannon config for devstrata projects

```yaml
# shannon-config.yaml — place in project root, gitignore sensitive parts
description: "FastAPI backend with HelixDB and Mem0 integration"

# Focus on the attack surfaces devstrata exposes
rules:
  focus:
    - description: "Test MCP endpoint if exposed"
      type: url_path
      value: "/mcp"
    - description: "Test API endpoints thoroughly"
      type: url_path
      value: "/api"
  avoid:
    - description: "Skip Ollama admin endpoints"
      type: url_path
      value: "/api/tags"

report:
  min_severity: medium
  guidance: |
    Focus on injection vulnerabilities and authentication bypass.
    Flag any endpoint that reads from agent-provided input without sanitisation.
```

---

## Security Checklist Before Open-Sourcing

If you fork devstrata and open-source your version:

- [ ] Remove all API keys from configs (check git history with `git log -p`)
- [ ] Scope MCP filesystem to project directory, not home directory
- [ ] Review `.graphifyignore` — ensure `.env`, `secrets/`, `*.pem` excluded
- [ ] Run Shannon on your own fork before publishing
- [ ] Audit Mem0 contents — `mem0 list --user-id <your-id>` for personal data
- [ ] Review HelixDB data — no PII in the graph database
- [ ] Check Hermes skills for personal project context
- [ ] Ensure private project configs are not included (check with `git log -p`)

---

## Responsible Disclosure

Security issues in devstrata itself (the config/glue layer):
Open a GitHub issue marked `[SECURITY]`.

Security issues in upstream tools:
Report directly to the upstream repo. Do not report them here.

Shannon vulnerabilities found in your project:
Fix them. Shannon's report includes PoC exploits — do not publish
the report publicly without fixing the vulnerabilities first.
