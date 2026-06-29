# tests/ — devstrata

> Integration + structural + edge-case tests for the devstrata meta-package.
> Run with: `./scripts/test.sh`

## Stats
- **63 test files** (auto-discovered via `tests/test_*.sh`)
- **~630 individual assertions**
- Run time: < 5 seconds (static analysis — no services needed)

## What's tested

### Structural integrity (8 tests)
| Test | What it verifies |
|---|---|
| `test_structure.sh` | All expected files/dirs exist; no missing templates (12 configs, 13 scripts, 10 docs, 3 profiles, .gitignore) |
| `test_scripts_executable.sh` | Every script in scripts/ + tests/ has the executable bit |
| `test_config_templates_completeness.sh` | Every template has meaningful content + is referenced by install.sh; docker-compose gated to full/pro |
| `test_profile_docs_completeness.sh` | Each PROFILE.md has required sections (install, prereqs, RAM, troubleshooting, upgrade) + RAM tier + boundaries |
| `test_readme_consistency.sh` | README mentions all profiles + links all docs + Quick Start + Structure + auto-adoption Q&A + star data + Headroom=Apache + no 885k claim |
| `test_cornerstones_intact.sh` | 10 guiding principles + 7 layers (L0-L6) + 11 tools + 4 memory domains all present |
| `test_gitignore_template.sh` | .gitignore exists, protects headroom.env/.env/*.bak.*/graphify-out/.shannon/*.pem, install.sh copies it |
| `test_scripts_absolute_paths_in_footer.sh` | doctor.sh + morning-startup.sh use absolute paths (not ./scripts/) so they work from project dir |

### Syntax + format validity (4 tests)
| Test | What it verifies |
|---|---|
| `test_bash_syntax.sh` | Every script passes `bash -n` |
| `test_json_valid.sh` | `.mcp.json.template` is valid JSON |
| `test_yaml_valid.sh` | `docker-compose.yml` is valid YAML |
| `test_plist_systemd_validity.sh` | HelixDB plist: valid XML + KeepAlive/RunAtLoad + `helix start dev --disk`; systemd: [Unit]/[Service]/[Install] + Restart=always + WantedBy |
| `test_headroom_supervision_templates.sh` | Headroom plist + systemd + watchdog plist + systemd timer all valid + correct ExecStart/StartInterval |

### .mcp.json generation logic (3 tests)
| Test | What it verifies |
|---|---|
| `test_mcp_generation.sh` | lite → 4 servers, full/pro → 6, lite set is exactly {fetch, filesystem, git, graphify} |
| `test_mcp_generation_edge_cases.sh` | lite output is valid JSON; full ≠ lite; graphify/git/filesystem/fetch survive lite strip; only helix+mem0 stripped; every server has command+args |
| `test_jq_absence_fallback.sh` | install.sh checks for jq before using it, has cp fallback, warns lite users |

### install.sh behavior (8 tests)
| Test | What it verifies |
|---|---|
| `test_install_sh_arg_parsing.sh` | arg-loop parser (any order), validates --lite/--full/--pro, rejects --foo, --yes/-y, --force |
| `test_install_sh_refs.sh` | every `$SCRIPT_DIR/...` path points to a real file |
| `test_install_sh_hardening.sh` | Node major version check, Mem0 image pre-pull (full/pro), recommend-profile mentioned in docs |
| `test_install_sh_post_drill_fixes.sh` | --yes flag, absolute paths in next-steps, profile-aware upgrade, pro next-steps (Hermes/Obsidian/32b), Step 12, AGENTS.md lite-trim, uvx check, read guards |
| `test_install_sh_force_and_upgrade.sh` | --force regenerates .mcp.json+AGENTS.md, upgrade/downgrade warnings, --yes without profile defaults to lite, invalid arg exits non-zero |
| `test_install_sh_idempotency.sh` | Headroom/Graphify guarded with command -v, proxy checks pgrep, .mcp.json/AGENTS.md/.graphifyignore/headroom.env respect existing, functional run-twice test |
| `test_install_sh_force_backup.sh` | --force backs up .mcp.json + AGENTS.md to .bak.<ts> before clobbering, docker-compose backed up on downgrade, functional backup-contains-edit test |
| `test_install_sh_downgrade_cleanup.sh` | docker-compose.yml removed on downgrade to lite (backed up, not rm'd), .mcp.json stripped to 4 servers, full sandbox simulation |
| `test_install_sh_mem0_apikey_guidance.sh` | install.sh mentions mem0 init + MEM0_API_KEY + agent signup, guidance in full/pro branch |
| `test_agents_md_lite_trim_helix_placeholder.sh` | AGENTS.md template Database placeholder is generic (no HelixDB); functional lite AGENTS.md verified clean |

### Runtime script behavior (8 tests)
| Test | What it verifies |
|---|---|
| `test_doctor_sh_port_checks.sh` | doctor.sh checks ports 8787/6969/3000/11434, has fix commands, checks graph freshness + model + 3 skills dirs |
| `test_doctor_sh_pre_install_state.sh` | doctor.sh detects pre-install state (≥3 missing) → recommends install.sh + recommend-profile.sh; points to version-check.sh |
| `test_morning_startup_idempotency.sh` | checks "already running" before starting each service, HTTP health checks, graph freshness, set -u |
| `test_end_of_day_script.sh` | refreshes graph, handles Obsidian export, --stop-proxy, set -u, reminds about Mem0, guards graphify |
| `test_end_of_day_state_aware.sh` | curls Mem0 + HelixDB health, no static "left running" message, gives start command when down, acknowledges lite |
| `test_update_sh_drift_detection.sh` | checks all 6 tools, docker compose pull, does NOT auto-upgrade, references doctor.sh, pip/npm commands |
| `test_docker_compose_services.sh` | mem0 service exists, port 3000, restart: unless-stopped, healthcheck /health, named volumes, host.docker.internal |
| `test_validate_mcp.sh` | functional test: broken .mcp.json rejected, valid .mcp.json accepted, exit codes distinct |
| `test_validate_mcp_corrupted_json.sh` | pre-validates JSON before iterating, rejects corrupted JSON, accepts valid, error says "not valid JSON" |
| `test_validate_mcp_error_messages.sh` | per-tool install commands (uvx→astral.sh, npx→nodejs.org, etc.), re-run guidance, no "run update.sh" |
| `test_version_check.sh` | queries PyPI (headroom/graphify/mem0) + GitHub (helix/shannon/hermes/gsd/superpowers) + npm, reports drift, no auto-upgrade |
| `test_version_check_docker_fallback.sh` | doesn't hard-require docker-compose.yml, falls back to docker ps, says "not installed" not "not available" |
| `test_sync_memory.sh` | structure, arg handling, requires --user-id, one-way direction, checks Mem0 running, set -u |
| `test_sync_memory_empty_export.sh` | detects header-only exports, warns user-id may be wrong, skips index update on empty, success gated by real-content check |
| `test_recommend_profile.sh` | detects RAM cross-platform, recommends --pro/--full/--lite, detects cloud keys + Apple Silicon, sub-8GB handling, says --lite is safe default |
| `test_headroom_watchdog.sh` | checks Ollama + Headroom health, restarts both if down, logs to file, exits 0 when healthy, guards with command -v |
| `test_headroom_env_template.sh` | all 5 LLM backends + Headroom settings, no real keys (only placeholders), real-provider keys commented, audit log |
| `test_headroom_env_key_warning.sh` | warns about Graphify LLM key requirement, notes README-as-doc, mentions Ollama workaround |
| `test_agent_isolate.sh` | references all 3 agent dirs, detects symlinks, unlinks shared, writes registry, recommends primary, set -u |
| `test_wsl2_check.sh` | detects WSL via /proc/version, checks Docker Desktop + systemd, documents Ollama WSL workaround, mentions Hermes native Windows, handles macOS |

### Documentation integrity (7 tests)
| Test | What it verifies |
|---|---|
| `test_doc_links.sh` | Every `docs/X.md` link in README resolves to a real file |
| `test_sources_coverage.sh` | Every tool in README has a `## Tool:` section in SOURCES.md |
| `test_sources_freshness.sh` | SOURCES.md has Last verified date (valid ISO), verified rows ≥ tool sections, URLs ≥ sections, re-verification procedure, unverified-claims section |
| `test_known_issues_consistency.sh` | KI-### + WF-### IDs unique, KI-003 references docker-compose + launchd/systemd, KI-001 references update.sh, has Won't Fix section, severity+status labels ≥ issue count |
| `test_instructions_no_bun_prereq.sh` | INSTRUCTIONS.md no longer requires bun (Hermes doesn't need it), mentions uv install, clarifies Hermes self-installs |
| `test_backends_graphify_cli.sh` | BACKENDS.md uses `graphify .` (not non-existent `graphify extract`), shows --backend, mentions auto-detect |
| `test_memory_domains_hermes_cli.sh` | MEMORY_DOMAINS.md uses `hermes sessions` (not non-existent `hermes search`), mentions insights, clarifies FTS5 location, pro PROFILE.md also clean |
| `test_docs_force_flag_documented.sh` | README mentions --force, has upgrade section, explains backup behavior, documents downgrade path |
| `test_clone_url_not_placeholder.sh` | README + lite PROFILE.md have real clone URL (no YOUR_USERNAME placeholder), valid github.com URL, mentions fork replacement |

### Security + privacy (1 test)
| Test | What it verifies |
|---|---|
| `test_no_personal_data.sh` | Scans every file for 17 personal identifier patterns (project names, employer, location, hardware, vault paths, domain terms). Excludes LICENSE/README/profile docs (attribution + clone URL) + Kafka-as-generic-tech allowlist. **Excludes itself.** 1746 scans across 98 files. |

## Design principles

1. **Static, not runtime** — these tests don't install the 11 upstream tools or spin up services. They verify the meta-package is internally consistent. Runtime health checks are in `doctor.sh`.
2. **No external dependencies required** — tests skip gracefully if `jq`/`pyyaml`/`plutil` aren't installed (SKIP, not FAIL).
3. **Self-excluding** — `test_no_personal_data.sh` excludes itself from the scan (it must contain the patterns to define them).
4. **Auto-discovered** — `scripts/test.sh` finds `tests/test_*.sh` automatically. Add a test by dropping a file in.
5. **One file = one outcome** — a test file with 20 assertions counts as 1 pass or 1 fail.
6. **Cornerstones enforced** — `test_cornerstones_intact.sh` ensures the 10 guiding principles, 7 layers, 11 tools, and 4 memory domains cannot be broken by any edit.

## Adding a test

1. Create `tests/test_<name>.sh` — exit 0 on pass, non-zero on fail
2. Print `PASS: <assertion>` or `FAIL: <assertion>: <reason>` per check
3. Make it executable: `chmod +x tests/test_<name>.sh`
4. `scripts/test.sh` auto-discovers it — no registration needed

## Why this matters

devstrata preaches TDD (Superpowers L4) and verification-before-completion.
Shipping a meta-package with no tests of its own would contradict that.
The suite enforces: no personal data leaks, claims are sourced, configs are
valid, scripts parse, profiles are complete, the jq generation logic is
correct across edge cases, doc commands match real CLIs, and the cornerstones
(10 principles + 7 layers + 11 tools + 4 memory domains) stay intact.