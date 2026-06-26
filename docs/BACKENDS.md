# BACKENDS.md — devstrata
> LLM provider switching guide. Change one env var, restart Headroom. Done.

## Decision Guide

| Need | Use |
|---|---|
| Private / sensitive code | Ollama local |
| Best reasoning quality | Claude Opus 4.7 |
| Lowest cost | Ollama local or DeepSeek |
| Largest context (1M tokens) | Gemini |
| Self-improving agent + 300+ models | Hermes + Nous Portal |
| Enterprise / data residency | Azure OpenAI |
| Daily coding (balanced) | Qwen2.5-Coder:14b or Claude Sonnet |
| Planning only (no tool-call needed) | DeepSeek R1 (no tool-calling support) |

## Switching Backend

```bash
# All tools read these env vars. Change here, restart proxy.
export OLLAMA_BASE_URL=http://localhost:11434
export OLLAMA_MODEL=qwen2.5-coder:14b
# or
export ANTHROPIC_API_KEY=sk-ant-...
# or
export OPENAI_API_KEY=sk-...

# Restart Headroom to pick up new backend
pkill -f "headroom proxy"
headroom proxy --port 8787 &
```

## Per-Tool Backend Config

### Graphify
```bash
# Graphify auto-detects the backend from your env vars (ANTHROPIC_API_KEY, OPENAI_API_KEY, etc.)
graphify .                           # build graph (auto-detects backend)
graphify . --backend=ollama          # force Ollama local
graphify . --backend=claude           # force Claude
graphify . --backend=openai           # force OpenAI
graphify . --backend=gemini           # force Gemini
graphify . --backend=deepseek         # force DeepSeek
# See: graphify --help for the full flag list
```

### Mem0
Config in Python or mem0 config file:
```python
config = {
    "llm": {
        "provider": "ollama",      # or: openai, anthropic, gemini
        "config": {
            "model": "qwen2.5-coder:14b",
            "base_url": "http://localhost:11434"
        }
    }
}
```

### Hermes
```bash
hermes model                                   # interactive picker
hermes model ollama:qwen2.5-coder:14b         # local
hermes model anthropic:claude-sonnet-4-6      # Claude
hermes model openai:gpt-4o                    # OpenAI
hermes model nous:hermes3-70b                 # Nous Portal
```

### Shannon (Claude models only — officially)
```bash
export ANTHROPIC_API_KEY=sk-ant-...
# Shannon is only officially supported on Claude models
# AWS Bedrock and Google Vertex also supported
```

## Ollama Model Recommendations

| Use case | Model | RAM needed |
|---|---|---|
| Code (primary) | qwen2.5-coder:14b | ~9GB |
| Code (heavy) | qwen2.5-coder:32b | ~20GB |
| Reasoning/planning | deepseek-r1:14b | ~9GB |
| General | llama3.3:8b | ~5GB |
| Fast/cheap | qwen2.5:3b | ~2GB |

> deepseek-r1 does NOT support tool-calling. Use for planning phases only.
