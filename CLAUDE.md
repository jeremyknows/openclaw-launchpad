# ClawStarter

Battle-tested OpenClaw production setup packaged as a beginner-friendly installer.

## Stack
- **Scripts:** Bash 3.2 (macOS default, no bash 4+ features)
- **Web:** HTML/CSS/JS (zero external dependencies, works offline)
- **Docs:** Markdown
- **Python 3:** Embedded in scripts for JSON manipulation (ships with macOS)
- **Target:** macOS 13+ (Apple Silicon or Intel)

## Quick Commands
```bash
# Primary installer (interactive, 3 questions, 15-20 min)
bash openclaw-quickstart-v2.sh

# Full automation (19 steps, progress tracking, resume support)
bash openclaw-autosetup.sh

# Resume from last checkpoint
bash openclaw-autosetup.sh --resume

# Minimal mode (17 steps, skips Mac user + Discord)
bash openclaw-autosetup.sh --minimal

# Post-setup diagnostic (18 checks, color-coded)
bash openclaw-verify.sh

# Apply security fixes
cd fixes/
bash phase1-1-api-key-security.sh
bash phase1-2-injection-prevention.sh
bash phase1-3-race-condition.sh
bash phase1-5-plist-injection.sh

# Test security (52+ test cases)
bash fixes/critical-fixes-tests.sh

# Regenerate template checksums (after editing templates)
bash fixes/generate-checksums.sh
```

## Structure
```
clawstarter/
├── openclaw-quickstart-v2.sh          # Primary installer (v2.7.0-prism-fixed)
├── openclaw-autosetup.sh              # 19-step automation
├── openclaw-verify.sh                 # 18-check diagnostic
├── companion.html                     # Interactive setup walkthrough
├── index.html                         # Marketing landing page
├── CLAUDE.md                          # This file
├── README.md                          # User-facing overview
├── docs/
│   └── CODEBASE_MAP.md               # Full architecture map
├── templates/
│   └── workspace/                     # 8 core templates (AGENTS.md, SOUL.md, etc.)
├── starter-pack/                      # Beginner configs (simplified from production)
│   ├── AGENTS-STARTER.md             # 7KB (vs 24KB production)
│   ├── CRON-TEMPLATES.md             # 5 pre-configured jobs
│   └── SECURITY-AUDIT-PROMPT.md      # Self-audit checklist
├── workflows/                         # Domain-specific bundles
│   ├── content-creator/              # Social, video, podcasts
│   ├── app-builder/                  # Coding, GitHub, dev tools
│   └── workflow-optimizer/           # Email, calendar, tasks
├── fixes/                             # Security patches
│   ├── phase1-*.sh                   # 5 security fixes
│   ├── stdin-tty-fix.patch           # Fixes curl | bash
│   └── critical-fixes-tests.sh       # 52+ test cases
└── reviews/                           # 20-PRISM marathon output
    └── PRISM-MARATHON-EXECUTIVE-SUMMARY.md
```

## Key Patterns

**Atomic config editing:**
All `openclaw.json` changes use backup → Python 3 edit → Zod validate → rename (or restore on failure). Never edit config directly.

**Python safety:**
All 22 embedded Python blocks use `sys.argv` + `<< 'PYEOF'` heredocs. Never interpolate shell variables into Python code. This prevents shell injection.

**Secrets architecture:**
`${VAR_NAME}` references in `openclaw.json`, actual values in LaunchAgent plist `EnvironmentVariables` dict. Gateway resolves at startup. **Important:** Gateway rewrites config with plaintext on restart — LaunchAgent plist is canonical secret store.

**Template checksums:**
SHA256 verification for all downloaded templates. Currently disabled (comment says "for bash 3.2 compatibility" but shasum works fine). Re-enable via `fixes/re-enable-checksums.sh`.

**Security layers (6 total):**
1. Input validation (strict allowlists for all user choices)
2. Safe file creation (touch + chmod 600 atomically)
3. XML escaping (LaunchAgent plist injection prevention)
4. Quoted heredocs (prevents shell expansion in literal content)
5. Checksum verification (MITM protection)
6. Output verification (plutil -lint for generated plists)

**Bash 3.2 compatibility:**
Use case statements instead of associative arrays. Use `2>&1` instead of `&>>`. Use indexed arrays only. No `read -i`, no `**` globstar, no `|&`.

**Design system (Glacial Depths):**
Dark theme by default, glacial cyan accent (#5CCFE6), 8-point spacing, WCAG Level AA compliance. Single-file HTML (no external deps).

**Cross-file consistency:**
7 values must match across all docs: OpenClaw min version (2026.1.29), recommended (2026.2.9+), gateway port (18789), config file name, API key prefixes, access profiles (explorer/guarded/restricted), autosetup step counts (19 full, 17 minimal).

## Critical Constraints

1. **Config file is Zod-validated** — Unknown keys fail. Gateway version determines schema.
2. **BOOTSTRAP.md existence signals first-run incomplete** — Agent reads it, asks 9 questions, then deletes it.
3. **Gateway rewrites `${VAR_NAME}` → plaintext on restart** — LaunchAgent plist is canonical. Config file gets overwritten.
4. **MEMORY.md only loads in private sessions** — Not in group channels (Discord, etc.). Privacy boundary.
5. **localhost resolves to IPv6 in Node 18+** — Use `127.0.0.1` for Ollama and other IPv4-only services.
6. **Homebrew install requires admin** — By design. Can't be automated for non-admin users.
7. **Minimal mode: 17 steps** — Skips Mac user creation (#8) and Discord setup (#14).
8. **Template download warnings, not failures** — Checksum mismatches print warnings but don't block (allows upstream template updates).
9. **Bash 3.2 only** — No bash 4+ features. macOS default bash is 3.2.57 (all macOS versions).
10. **API key format validation** — Must match `sk-or-v1-*` (OpenRouter), `sk-ant-*` (Anthropic), or `pa-*` (Voyage AI).
11. **stdin/TTY detection** — Piped execution (`curl | bash`) redirects prompts to `/dev/tty`. Applied in v2.7.0.
12. **Input validation on all user input** — Bot name, model, security level, personality validated against strict allowlists before use.

## Environment Variables

Scripts read from environment, write to LaunchAgent plist:

| Variable | Purpose | Written by | Read by |
|----------|---------|------------|---------|
| `OPENROUTER_API_KEY` | OpenRouter API key | quickstart, autosetup | Gateway (via plist) |
| `ANTHROPIC_API_KEY` | Anthropic API key | quickstart, autosetup | Gateway (via plist) |
| `VOYAGE_AI_API_KEY` | Voyage AI API key | autosetup (step 15) | Gateway (via plist) |
| `GATEWAY_TOKEN` | Gateway auth token | quickstart, autosetup | Gateway (via plist) |
| `HOME` | User home directory | System | Scripts (for path validation) |
| `USER` | Current username | System | Scripts (for Mac user creation) |

**Note:** Scripts store secrets in macOS Keychain AND LaunchAgent plist. Config file contains `${VAR_NAME}` references only.

## Version Requirements

- **OpenClaw minimum:** 2026.1.29 (CVE patches for serious security bugs)
- **OpenClaw recommended:** 2026.2.9+ (safety scanner + credential redaction in logs)
- **Node.js:** v22+ (installed via Homebrew if missing)
- **macOS:** 13+ (Ventura or newer)
- **Bash:** 3.2+ (ships with macOS)
- **Python:** 3.x (ships with macOS)

**How to check:**
```bash
openclaw --version       # Should be 2026.2.9 or higher
node --version           # Should be v22.x or higher
sw_vers                  # ProductVersion should be 13.x or higher
bash --version           # Should be 3.2.57 (macOS default)
python3 --version        # Should be 3.x
```

## Security Model

**Threat model:** Local privilege escalation, API key exposure, network attacks, shell injection

**Defenses:**
- Secrets in macOS Keychain + LaunchAgent env vars (not plaintext config)
- Localhost-only binding (no network exposure)
- mDNS/Bonjour disabled (gateway not advertised)
- Input validation (strict allowlists, no shell metacharacters)
- File permissions (600 for config, 700 for home directory)
- XML escaping (prevents LaunchAgent plist injection)
- Template checksums (MITM protection — pending re-enablement)

**CVSS:** 9.0 (critical) before fixes → 1.0 (low) after fixes. 90% risk reduction.

**Fixes applied in v2.7.0:**
- stdin/TTY handling (usability fix for `curl | bash`)
- API key security (Keychain isolation)
- Command injection prevention (input validation)
- Race condition elimination (atomic file creation)
- XML injection protection (LaunchAgent escaping)

**Pending:** Template checksum re-enablement (Phase 1.4)

## Common Tasks

**Add API provider:**
1. Update `ALLOWED_MODELS` array in quickstart script
2. Add validation logic in `validate_model()`
3. Update all 7 content files (README, CLAUDE, companion.html, index.html, autosetup, verify, Foundation Playbook)
4. Regenerate companion.html accordion to match new options

**Change gateway port:**
1. Update `DEFAULT_GATEWAY_PORT` constant in quickstart script
2. Update same constant in autosetup script
3. Update verify script (2 locations)
4. Update CONTRIBUTING.md cross-file table
5. Update all docs (README, companion.html, index.html, CLAUDE.md, Foundation Playbook)

**Add security check:**
1. Add `step_CHECKNAME()` function in verify.sh
2. Call it in main sequence
3. Increment check count constant (18 → 19)
4. Update README.md, CLAUDE.md, companion.html with new count

**Update template:**
1. Edit file in `templates/workspace/`
2. Update `starter-pack/` simplified version if exists
3. Regenerate checksums: `bash fixes/generate-checksums.sh`
4. Update case statement in quickstart script with new checksums
5. Test workflows still import correctly

**Fix security vulnerability:**
1. Create `fixes/phase1-X-name.sh` with fix
2. Create `fixes/phase1-X-name.md` with documentation
3. Create `fixes/phase1-X-test-suite.sh` with 10+ tests
4. Apply to quickstart script
5. Update SECURITY.md, fixes/COMPLETION-REPORT.md
6. Run `bash fixes/critical-fixes-tests.sh` (must pass 100%)

## Gotchas

1. **Template checksum warnings:** Currently disabled. Mismatches print warnings but don't fail. Re-enable for production via `fixes/re-enable-checksums.sh`.
2. **Gateway rewrites config:** Every restart converts `${VAR_NAME}` back to plaintext. This is OpenClaw behavior, not ClawStarter.
3. **BOOTSTRAP.md self-deletes:** After first chat, it's gone. Existence signals "first-run incomplete."
4. **MEMORY.md privacy:** Only loads in private sessions. Group channels (Discord) don't load it.
5. **localhost → IPv6:** Node 18+ resolves localhost to ::1. Use 127.0.0.1 for IPv4-only services.
6. **Minimal mode skips:** Mac user creation and Discord setup. Everything else runs.
7. **Bash 3.2 limitations:** No associative arrays. Use case statements for key-value lookups.
8. **API key format strict:** Must start with `sk-or-v1-`, `sk-ant-`, or `pa-`. Spaces rejected.
9. **stdin starvation:** Fixed in v2.7.0. Piped execution (`curl | bash`) now redirects to `/dev/tty`.
10. **Keychain retry:** If locked, script retries once, then offers manual .env fallback.

## Architecture

See [docs/CODEBASE_MAP.md](docs/CODEBASE_MAP.md) for:
- System overview diagrams
- Complete file listings
- Data flow sequences
- Security architecture
- Navigation guide (8+ actionable entries)
- Module guide with key files tables
- Conventions and patterns

**Quick navigation:**
- Fix install bug → `CODEBASE_MAP.md#to-fix-a-bug-in-the-install-script`
- Add workflow → `CODEBASE_MAP.md#to-add-a-new-workflowskill-pack`
- Update template → `CODEBASE_MAP.md#to-update-a-template-and-regenerate-checksums`
- Security fix → `CODEBASE_MAP.md#to-add-a-new-security-fix`
- Review PRISM → `CODEBASE_MAP.md#to-review-prism-analysis`

## Resources

- **Full architecture:** [docs/CODEBASE_MAP.md](docs/CODEBASE_MAP.md)
- **Security policy:** [SECURITY.md](SECURITY.md)
- **Contributing guide:** [CONTRIBUTING.md](CONTRIBUTING.md)
- **PRISM reviews:** [reviews/PRISM-MARATHON-EXECUTIVE-SUMMARY.md](reviews/PRISM-MARATHON-EXECUTIVE-SUMMARY.md)
- **Fix documentation:** [fixes/COMPLETION-REPORT.md](fixes/COMPLETION-REPORT.md)
- **Starter pack:** [starter-pack/STARTER-PACK-MANIFEST.md](starter-pack/STARTER-PACK-MANIFEST.md)
