# ClawStarter Core Scripts & Pages — Documentation Analysis

**Subagent 1 Report: Core Scripts & Pages**  
Generated: 2026-02-15 09:38 EST  
Scope: Primary install script, web pages, older versions, config/meta files

---

## Executive Summary

ClawStarter is a production-grade setup automation toolkit for OpenClaw (personal AI assistant framework). It packages battle-tested production workflows into a beginner-friendly installer with an interactive companion webpage.

**Core insight:** This isn't just an installer — it's a curated playbook from real production use, packaged as a starter kit.

**Target audience:** Non-technical founders, first-time OpenClaw users  
**Primary components:** Security-hardened bash script (v2.7.0), responsive HTML companion guide, workspace templates

---

## File-by-File Analysis

### PRIMARY INSTALL SCRIPT

#### `openclaw-quickstart-v2.sh` (19,470 tokens)

**Purpose:** Security-hardened automated installation script that takes users from zero to running AI agent in ~15 minutes.

**Version:** 2.7.0-prism-fixed (2026-02-15)

**Key Exports/Functions:**

Security Functions:
- `keychain_store()`, `keychain_get()`, `keychain_exists()`, `keychain_delete()` — macOS Keychain integration
- `keychain_warn_user()`, `keychain_store_with_recovery()` — Enhanced error handling with retry logic
- `validate_bot_name()`, `validate_model()`, `validate_menu_selection()`, `validate_api_key()` — Input validation against allowlists
- `validate_security_level()`, `validate_personality()` — Config validation
- `escape_xml()`, `validate_home_path()`, `create_launch_agent_safe()` — XML injection prevention
- `verify_sha256()`, `get_template_checksum()`, `verify_and_download_template()` — Template integrity checking
- `check_port_available()`, `handle_port_conflict()` — Port conflict detection & resolution
- `check_disk_space()` — Pre-flight disk space verification (500MB minimum)

Workflow Functions:
- `step1_install()` — Homebrew + Node.js + OpenClaw installation
- `step2_configure()` — 3-question configuration wizard
- `guided_api_signup()` — Interactive API key acquisition
- `offer_skill_packs()` — Post-install skill pack recommendations
- `step3_setup()` — Config file generation, workspace scaffolding, LaunchAgent creation
- `spinner()`, `prompt()`, `prompt_validated()`, `confirm()` — User interaction utilities

**Dependencies:**
- macOS 13+ (Darwin)
- Homebrew (auto-installs if missing)
- Node.js 22+ (auto-installs via Homebrew)
- Python 3 (ships with macOS — used for JSON manipulation)
- OpenClaw CLI (auto-installs via curl)
- `openssl` (for gateway token generation)
- `security` command (macOS Keychain access)
- `lsof`, `pgrep`, `launchctl` (system utilities)

**Patterns & Conventions:**

1. **Security Hardening (3 phases applied):**
   - Phase 1: API Key Security, Injection Prevention, Race Conditions, Template Checksums, Plist Injection
   - Phase 2: Keychain Isolation, Quoted Heredoc, Port Conflict Check, Error Handling
   - Phase 3: Disk Space Check, Locked Keychain Handling
   - PRISM Marathon: stdin/TTY Fix, API Key Validation, Permission Self-Heal

2. **Strict Allowlists:**
   - 9 allowed AI models (hardcoded array)
   - 3 security levels: low, medium, high
   - 3 personality types: casual, professional, direct
   - Bot name: 2-32 chars, alphanumeric/hyphen/underscore, must start with letter

3. **Template Integrity:**
   - SHA256 checksums for 11 workspace templates
   - Downloads from GitHub main branch
   - Bash 3.2-compatible case statement lookup (no associative arrays)
   - Checksum warnings (not failures) allow upstream template updates

4. **Atomic File Operations:**
   - `touch + chmod 600` before write (prevents race conditions)
   - XML escaping for all plist values
   - Heredocs use single quotes to prevent shell expansion

5. **Error Recovery:**
   - Progress tracking would be in state file (not implemented in v2.7)
   - Keychain retry loop (2 attempts)
   - Manual .env fallback option
   - Port conflict resolution with 3 user options

**Non-Obvious Behaviors & Gotchas:**

1. **Gateway Token Auto-Generation:** If config has weak token (<32 chars) or none, script generates cryptographically random 64-char hex token.

2. **OpenCode Free Tier Fallback:** Pressing Enter at API key prompt defaults to OpenCode's free Kimi K2.5 model (no signup required).

3. **Personality → Model Selection Logic:**
   - App builder use case → `direct` personality → premium tier → Claude Sonnet/Opus
   - Content creator → `casual` personality → balanced tier
   - Multi-mode → `Atlas` bot name override

4. **Skill Pack Recommendations:** Script builds skill list based on use case selection:
   - Content creator: `openai-image-gen, tts, video-frames, x-fetch`
   - Workflow optimizer: `apple-notes, apple-reminders, gog, himalaya`
   - App builder: `github, coding-agent, generate-jsdoc`
   - Always includes: `weather, summarize`

5. **LaunchAgent Creation:** Uses XML-escaped home path, validates against injection patterns, runs `plutil -lint` validation before saving.

6. **API Key Storage:** Keys stored in macOS Keychain under service `ai.openclaw` with account names:
   - `openrouter-api-key`
   - `anthropic-api-key`
   - `gateway-token`

7. **P0 stdin/TTY Fix:** Detects piped execution (`curl | bash`) and redirects reads to `/dev/tty` to work around stdin not being a TTY.

8. **Permission Self-Heal:** Auto-adds execute permission to script if missing (`chmod +x $0`).

9. **Template Download Warnings:** Checksum mismatches print warnings but don't fail the install (allows upstream template updates between checksum regenerations).

10. **Needs Manual Env Flag:** Sets `NEEDS_MANUAL_ENV=true` if user skips Keychain storage, shows .env setup instructions at end.

---

### WEB PAGES

#### `companion.html` (18,872 tokens)

**Purpose:** Interactive step-by-step setup guide that walks users through Terminal installation process with detailed visual guidance.

**Key Sections:**

Navigation:
- Sticky progress header (3 steps: Download → Run → Chat)
- Theme toggle (dark/light mode, persists to localStorage)
- Section anchors for deep linking

Content Structure:
1. **Before You Start** — Pre-install checklist (3 items), setup path selection (same Mac vs dedicated)
2. **Step 1: Download** — Download button + curl alternative
3. **Step 2: Open Terminal** — How to launch Terminal.app, navigate to Downloads
4. **Step 3: Run Script** — Critical warnings (invisible password, don't press ⌘C), command to run
5. **Steps 5-10: Terminal Walkthrough** — Accordion UI matching script output
6. **Now What?** — Post-install actions (talk to bot, add Discord, open dashboard)

Interactive Elements:
- Checkboxes with localStorage persistence
- Copy buttons with fallback for file:// URLs
- Accordion FAQ sections
- Collapsible advanced content
- Auto-scroll on navigation
- Progress step tracking

**Dependencies:**
- Modern browser (Safari, Chrome, Firefox)
- JavaScript enabled
- localStorage (with sessionStorage fallback)
- No external libraries (single-file design)

**Patterns & Conventions:**

1. **Glacial Depths Design System:**
   - CSS custom properties for theming
   - HSL color palette (dark: 172°/12%/6% base, light: 168°/20%/97%)
   - Accent: hsl(168, 76%, 52%) — mint/teal
   - 8-point spacing scale
   - Consistent border radius (6px to 24px)

2. **Accessibility:**
   - Semantic HTML (`<nav>`, `<section>`, `<details>`, `<kbd>`)
   - ARIA labels on interactive elements
   - Focus indicators (2px outline at 2px offset)
   - Keyboard navigation for accordions
   - Reduced motion support

3. **Progressive Enhancement:**
   - Works without JavaScript (accordions use `<details>`)
   - Copy buttons degrade to manual copy
   - Theme persists but defaults to dark if localStorage unavailable

4. **State Management:**
   - Checklist persistence via `localStorage.setItem('check-N', true)`
   - Progress step visibility via dataset attributes
   - Theme preference in `localStorage.theme`

5. **Terminal Simulation:**
   - Dark terminal blocks even in light mode
   - Color-coded output (green for success, yellow for warnings, red for errors)
   - 3-dot window chrome
   - Monospace font (Space Mono)

**Non-Obvious Behaviors:**

1. **Checkbox State:** `saveCheckbox(id, checked)` function persists check state; `loadCheckboxStates()` restores on page load.

2. **Scroll Reveal:** `.reveal` class elements fade up when scrolling into view (IntersectionObserver).

3. **Step Completion Tracking:** `markStepComplete(stepId)` function adds `.completed` class to progress dots, stores completion in localStorage.

4. **Copy Command Fallback:** If Clipboard API fails (common on `file://` URLs), creates a temporary `<textarea>`, selects content, executes `document.execCommand('copy')`.

5. **Accordion Animations:** Grid-based height animation (`grid-template-rows: 0fr → 1fr`) for smooth expansion without fixed heights.

6. **Mobile Responsiveness:** Progress step labels hide on <768px, path grid becomes single column.

---

#### `index.html` (13,875 tokens)

**Purpose:** Marketing landing page with video hero, feature highlights, installation quick-start, and FAQ accordion.

**Key Sections:**

1. **Hero Section:**
   - Main headline with gradient text
   - Primary CTA ("Get Started")
   - Video placeholder with poster thumbnail
   - Ambient orb animations (2 floating gradients)

2. **Installation Quick-Start:**
   - Copy-to-clipboard install command
   - 3-step bento grid (Download → Configure → Chat)
   - Enhanced visual design with scan animation

3. **Features Bento Grid:**
   - 6 feature cards (2-column layout)
   - Icons + emoji
   - Hover effects

4. **Trust Section:**
   - 4 trust badges (Open Source, Security-First, Runs Locally, Community Supported)
   - Gradient background panel

5. **Community CTA:**
   - Discord invite link
   - Beta tester role badge

6. **FAQ Accordion:**
   - 8 common questions
   - Expandable `<details>` elements
   - Safety, cost, complexity, capabilities

7. **Footer:**
   - Creator attribution
   - GitHub/Discord/download links

**Dependencies:**
- Same as companion.html (no external deps)
- Video file: `welcome-to-clawstarter-video.mp4`
- Video thumbnail: `clawstarter-video-thumbnail.png`
- Favicon: `favicon.png`

**Patterns & Conventions:**

1. **Ripple Canvas Animation:**
   - `<canvas>` element for cursor-tracking effects
   - 3 layered systems: ripple rings, ambient glow, ice particles
   - HSL color math for gradient shifts
   - Disabled on mobile/reduced-motion

2. **Click-to-Copy Pre Block:**
   - Entire `<pre>` element is clickable
   - Background flash animation on copy
   - User-select: all for easy highlighting

3. **Video Embedding:**
   - HTML5 `<video>` with controls
   - Poster frame for initial view
   - Metadata preload for fast start

4. **Gradient Shift Animation:**
   - `.mint-text` background animates via `background-position`
   - 200% width gradient for smooth loop
   - 6-second ease-in-out cycle

5. **Bento Step Hover:**
   - Transform: translateY(-4px)
   - Border color change to accent
   - Top pseudo-element gradient line fades in

**Non-Obvious Behaviors:**

1. **Install Command Copy:** Both "Copy" button AND clicking the `<pre>` block copy the command. Visual feedback: green background flash.

2. **Ripple System Persistence:** Ripple array keeps last 40 ripples, particles array keeps last 200. Older ones are spliced out to prevent memory growth.

3. **Theme Detection:** Checks `localStorage.theme` first, falls back to system preference (`prefers-color-scheme`), defaults to dark.

4. **Video Play on Button:** "Watch Video" button calls `video.play()` directly instead of linking to external player.

5. **Scroll Reveal Threshold:** IntersectionObserver triggers at `0.15` (15% of element visible).

6. **Installation Section Decorative Borders:** Pseudo-elements (`::before`, `::after`) create 200px corner brackets with 2px accent borders.

---

### OLDER SCRIPT VERSIONS (SKIM ANALYSIS)

#### `openclaw-quickstart-v2.6-SECURE.sh` (18,226 tokens)

**Differences from v2.7.0:**
- Missing PRISM Marathon fixes (P0 stdin/TTY, P1 API key validation, P1 permission self-heal)
- No `--yes` flag support for auto-accept
- No detailed error trapping with line number reporting
- Checksum verification was disabled (commented out) in v2.6, re-enabled in v2.7
- Less verbose disk space check messaging

**Key Changes in v2.7:**
1. Added `AUTO_YES` flag parsing
2. Added trap for ERR with `$LINENO` and `$BASH_COMMAND`
3. Re-enabled template checksum verification (was commented out in v2.6)
4. Added stdin/TTY detection (`[ -t 0 ]`) in `prompt()` and `prompt_validated()`
5. Added API key format validation (sk-or-*, sk-ant-* prefix checking)
6. Added self-heal for missing execute permission
7. Enhanced disk space check messaging

#### `openclaw-autosetup.sh` (22,570 tokens)

**Purpose:** Full 19-step automation script with progress tracking, resume capability, and comprehensive error recovery.

**Key Differences from Quickstart:**
- **Progress tracking:** JSON file at `~/.openclaw-autosetup-progress` with step completion timestamps
- **Resume support:** `--resume` flag skips already-completed steps
- **Mode flags:** `--minimal` (17 steps), `--full` (19 steps), `--reset` (clear progress)
- **Logging:** All output teed to `~/.openclaw/autosetup-TIMESTAMP.log`
- **Atomic config editing:** `atomic_config_edit()` function with backup/restore on failure
- **JSON manipulation:** Extensive Python helper functions (`json_set`, `json_get`, `json_validate`)
- **Human checkpoints:** `pause_for_human()` function for manual steps
- **Comprehensive verification:** 18 diagnostic checks as final step

**19 Steps:**
1. Environment detection
2. Homebrew install
3. Node.js 22 install
4. OpenClaw install/update
5. Firewall + stealth mode
6. Sleep prevention
7. Auto-update restart disable
8. Mac user account creation (human checkpoint)
9. Home directory lockdown (chmod 700)
10. API key acquisition (human checkpoint)
11. Onboarding wizard (human checkpoint)
12. Workspace scaffolding
13. Gateway verification
14. Discord setup (human checkpoint)
15. Config file permission hardening
16. Secrets hardening (env vars, mDNS, gateway token)
17. Access profile application
18. openclaw doctor
19. Final verification (openclaw-verify.sh)

**Minimal Mode (17 steps):**
- Skips: Mac user creation (#8), Discord setup (#14)
- Auto-proceeds on non-destructive confirmations

**Non-Obvious Behaviors:**
1. **Progress file corruption handling:** Validates JSON structure on load, offers to delete corrupted file
2. **Version comparison:** Python-based semantic versioning (`version_gte()`)
3. **Config backup naming:** Timestamped backups (`openclaw.json.backup-20260215-093000`)
4. **Template copy strategy:** `cp -n` (no-clobber) preserves existing files
5. **Gateway status parsing:** Checks multiple indicators (process, port, HTTP endpoint, `openclaw gateway status`)

#### `openclaw-quickstart.sh` (8,104 tokens — v1/v2 original)

**Purpose:** Original 3-step quickstart — simpler, less secure predecessor.

**Major Differences from v2.7:**
- No Keychain integration (API keys in config file)
- No input validation
- No template checksums
- No XML escaping
- No port conflict detection
- Simpler 7-question wizard instead of 3-question + decision matrix
- Workflow template installation built-in (not offered as post-install)
- Manual skills.sh execution for template-based skill packs

**Questions (v1 vs v2.7):**
- v1: 7 questions (provider, spending, personality, name, channel, use case, setup type)
- v2.7: 3 questions (API key with guided signup, use case multi-select, setup type)

**Deferred to Advanced Setup:**
- Mac user creation
- Discord/Telegram configuration
- Access profiles
- Secrets migration

#### `openclaw-verify.sh` (7,787 tokens)

**Purpose:** Post-install diagnostic script with 18 verification checks.

**Checks:**
1. macOS user isolation (admin status, home directory permissions)
2. Node.js version (v22+ requirement)
3. OpenClaw installation & version (min 2026.1.29, recommended 2026.2.9+)
4. Configuration (file existence, JSON validity, permissions, API providers)
5. Gateway (LaunchAgent, loaded status, process, port, HTTP endpoint)
6. Discord bot configuration
7. Mac sleep prevention (pmset settings, auto-update restarts)
8. openclaw doctor output
9. Log files (existence, size, recent errors)
10. Access profile & approval tier
11. Spending limit reminder (manual check)
12. Security quick check (API keys in exposed locations)
13. Disk encryption (FileVault status)
14. TCC permissions (bot user only)
15. Memory search configuration (Voyage AI)
16. API connectivity (OpenRouter reachability, Discord token validation)
17. Docker sandbox (mode detection, daemon status)
18. Workspace templates (presence check)

**Output Format:**
- Color-coded pass/fail/warn counts
- Detailed failure messages with fix instructions
- Conditional checks (skip if dependencies missing)

**Non-Obvious Behaviors:**
1. **Version Parsing:** Extracts `YYYY.M.D` format from `openclaw --version` output using grep
2. **Config Inspection:** Uses embedded Python to parse JSON without revealing secrets
3. **TCC Database Query:** SQLite queries to `/Library/Application Support/com.apple.TCC/TCC.db`
4. **Exposed Keys Search:** `grep -rEl` across Desktop/Documents/Downloads for API key patterns
5. **Node.js Deprecation Filtering:** Strips `DeprecationWarning` lines from `openclaw doctor` output
6. **Discord Token Validation:** Calls Discord API `/users/@me` endpoint to verify token

**Critical vs Warning Thresholds:**
- FAIL: Missing dependencies, broken config, security risks
- WARN: Suboptimal settings, missing optional features, version below recommended
- INFO: Explanatory context, manual action required

---

### CONFIG/META FILES

#### `CLAUDE.md` (1,057 tokens)

**Purpose:** AI agent documentation — how to work in this codebase.

**Key Patterns:**
1. **Project overview:** ClawStarter = battle-tested production setup → beginner-friendly installer
2. **Target audience:** Non-technical founders, first-time OpenClaw users
3. **Tech stack:** Bash, HTML/CSS/JS, Markdown, Python 3 (macOS-bundled)
4. **Quick commands:** 4 primary use cases (autosetup, minimal, resume, verify)
5. **Structure summary:** 8 templates (single source of truth), 3 scripts, 5 doc files
6. **Critical constraints:** 9 numbered items (config validation, version requirements, API key prefixes, etc.)
7. **Key patterns:** 8 foundational patterns (atomic editing, Python safety, secrets architecture, etc.)

**Non-Obvious:**
- `localhost` resolves to IPv6 in Node 18+ (use `127.0.0.1` for Ollama)
- BOOTSTRAP.md existence signals first-run incomplete
- MEMORY.md only loads in private sessions, not group channels
- Gateway rewrites `${VAR_NAME}` back to plaintext on restart

#### `README.md` (1,438 tokens)

**Purpose:** Public-facing repository README.

**Structure:**
1. Quick Start
2. Requirements
3. What's in This Package (table of file purposes)
4. How the Pieces Fit Together (ASCII flow diagram)
5. What's Next (BOOTSTRAP.md + Foundation Playbook)
6. Version info
7. Security notes

**Key Messaging:**
- "Everything you need" — complete toolkit framing
- "No Terminal experience required" — accessibility
- "Pick one" guide structure — HTML vs Markdown vs AI-assisted
- "Optional hardening" — Foundation Playbook phasing
- Security transparency (dedicated user, env vars, file permissions, mDNS, CVEs)

#### `ROADMAP.md` (1,305 tokens)

**Purpose:** Maintainer roadmap (not user-facing).

**Completed (Security Hardening):**
- 14 items checked off (C1-C3, H1-H5, M5, etc.)
- Shell injection fix (22 Python blocks)
- Secrets migration
- mDNS disable
- Explorer profile browser deny
- requireMention defaults
- Cryptographic gateway token
- FileVault check
- Step count updates
- Completion message

**Remaining (Open-Source Readiness):**
- Fresh Mac QA (end-to-end test)
- Foundation Playbook TOC

**Deferred:**
- 10 P1-P3 items (Tailscale, Mem0, model routing, DigitalOcean, etc.)

**Known Limitations:**
- Homebrew install requires admin (by design)
- OpenAI tier uses placeholder model names
- Gateway plaintext rewrite (OpenClaw behavior)
- requireMention defaults to false for primary channel

#### `CONTRIBUTING.md` (1,171 tokens)

**Purpose:** Contributor guidelines.

**Sections:**
1. Quick Start for Contributors
2. Types of Contributions (bug reports, docs, scripts, features)
3. Development Workflow (5 steps: fork, change, test, update docs, commit)
4. Cross-File Consistency (7 values that must match across files)
5. Voice and Tone (audience adaptation)
6. Code Style (bash, Python, HTML conventions)

**Cross-File Consistency Table:**
- OpenClaw min version: 2026.1.29
- OpenClaw recommended: 2026.2.9
- Gateway port: 18789
- Config file: openclaw.json
- API key prefixes: sk-or-v1-, sk-ant-, pa-
- Access profiles: explorer, guarded, restricted (Note: Spec had "admin, default" — all files correctly use the 3-tier system)
- Autosetup steps: 19 (full), 17 (minimal)
- Verify checks: 18

**Code Style Highlights:**
- Bash: `set -euo pipefail`, quote all vars, `[[ ]]` for tests
- Python in bash: `sys.argv` only, never f-strings with shell vars
- HTML: semantic, CSS variables, no external deps

#### `SECURITY.md` (962 tokens)

**Purpose:** Security policy and threat model.

**Sections:**
1. Threat Model (4 threat types: local, network, prompt injection, supply chain)
2. Protections (5 defenses)
3. Known Limitations (2 items: gateway plaintext rewrite, AI agent autonomy)
4. Supported Versions (latest only)
5. Reporting Vulnerabilities (private disclosure, 90-day window)
6. Security Features (4 categories: secrets, network, access control, script safety)
7. User Security Checklist (6 items)
8. CVE References (4 CWE mappings)
9. Resources (3 external links)

**Threat Model Table:**
| Threat | Protection |
|--------|------------|
| Secrets in plaintext | `${VAR}` references |
| Network exposure | Localhost-only, mDNS disabled |
| Excessive AI permissions | Access profiles |
| Shell injection | Single-quoted heredocs, sys.argv |
| Weak gateway tokens | Cryptographically random 64-char hex |

**CWE Mappings:**
- CWE-78: OS command injection
- CWE-256: Plaintext credentials
- CWE-200: Information exposure
- CWE-732: Incorrect permissions

#### `LICENSE` (220 tokens)

**Content:** MIT License, Copyright 2026 Jeremy Knows

#### `.gitignore` (112 tokens)

**Patterns:**
- macOS: `.DS_Store`
- Editor: `*.swp`, `*.swo`, `*~`
- Claude Code: `.claude/`
- Dependencies: `node_modules/`
- Environment: `.env`, `.env.*`
- Logs: `*.log`
- Backups: `*.backup`, `*.backup.*`
- OpenClaw runtime: `.openclaw-autosetup-progress`
- Review artifacts: `REVIEW-*.md`, `IMPLEMENTATION-PLAN.md`
- Office: `*.docx`

#### `START-HERE.txt` (52 tokens)

**Content:**
```
OpenClaw Setup Guide
====================

Open "openclaw-setup-guide.html" in your browser.

That's it. Double-click the file and follow the steps.

For a full overview of every file and how they fit together, see README.md.
```

#### `JEREMY-VISION-V2.md` (638 tokens)

**Purpose:** Owner's vision notes from voice memos.

**Key Insights (Voice Memo 2 — THE REFRAMING):**

**The REAL value prop is NOT "easy installer."**

It's:
1. **Security Baseline** — Secure setup for shared or dedicated environments
2. **Our Battle-Tested Setup, Forked** — Full production setup as starter kit:
   - Twitter/X setup (x-engage, x-research)
   - Cron jobs (morning briefing, email, evening memory)
   - Memory management system (daily files, MEMORY.md, cross-session protocol)
   - Librarian agent
   - Treasurer agent
   - Battle-tested AGENTS.md overlay
   - SOUL.md / IDENTITY.md templates
   - Security prompts and audit workflows
3. **Starter Packs + Expansion Packs:**
   - Starter Pack (default): Librarian, Treasurer, memory system, security baseline, cron templates
   - Expansion Packs (curated sequences): X/Twitter, channels, skill packs, advanced monitoring
4. **Living Document** — Continuously improving based on production experience

**Positioning Shift:**
- FROM: "Easy installer for OpenClaw"
- TO: "We've been running OpenClaw in production. Here's everything we learned, packaged as a starter kit."

**This is a RECIPE, not an INSTALLER. It's a playbook.**

**Voice Memo 1:** Companion webpage, download button, simple `bash install.sh`, tooltips, choose-your-own-adventure paths, 20 PRISM passes total.

**Voice Memo 3:** Sample prompts that adapt, don't fear complexity, `/update-docs` as final polish, memory discipline during marathon.

#### `PRISM-MARATHON.md` (677 tokens)

**Purpose:** PRISM review sprint plan (Feb 15, 2026).

**Schedule:**
- Wave 1: 02:30-06:00 EST — 10 PRISMs (any aspect of ClawStarter)
- Wave 2: 06:30 EST — 10 more PRISMs (refinement, edge cases, polish)

**PRISM Plan (20 total, Sonnet model):**

PRISMs 1-3: Foundation Analysis
1. Current state audit
2. Companion page architecture
3. Script simplification

PRISMs 4-6: Companion Page Design
4. UX flow
5. Content & copy
6. Error handling UX

PRISMs 7-9: Integration & Templates
7. Channel templates
8. Post-install experience
9. AGENTS.md overlay

PRISM 10: Wave 1 Synthesis

PRISMs 11-15: Wave 2 Refinement

PRISMs 16-20: Wave 2 Deep Passes (adversarial testing, accessibility, mobile, polish)

**Problems Identified:**
- Script doesn't work in VMs
- "Hit Escape" step non-obvious
- API key paste canceling out
- "Now what?" gap
- Too many variables for unattended script

**Companion Page Needs:**
- Step-by-step synchronized with Terminal
- Tooltips for errors
- Choose-your-own-adventure paths
- One-click copy for prompts
- Troubleshooting section
- Skill pack recommendations
- Battle-tested templates

**Two Target Environments:**
1. Fresh Mac user account on same machine
2. Dedicated Mac device

---

## AGENT-FOCUSED SUMMARY (Dense, Scannable)

**ClawStarter = Production Playbook → Beginner Installer**

**Core Components:**
- `openclaw-quickstart-v2.sh` (v2.7.0): Security-hardened install script, 3-question wizard, Keychain integration, template checksums, 9 allowlisted models
- `companion.html`: Interactive step-by-step guide, Glacial Depths design, localStorage persistence, accordion walkthrough
- `index.html`: Marketing landing page, ripple canvas animation, FAQ, Discord CTA
- `openclaw-autosetup.sh`: 19-step automation with progress tracking, JSON manipulation, resume support
- `openclaw-verify.sh`: 18 diagnostic checks, color-coded output, fix instructions

**Security Architecture (3 phases applied):**
1. **Secrets:** `${VAR_NAME}` references in config, actual values in LaunchAgent plist, Keychain for API keys
2. **Injection Prevention:** Single-quoted heredocs, `sys.argv` in Python, XML escaping, strict allowlists
3. **Network:** Localhost-only binding, mDNS disabled, cryptographic gateway token
4. **File Permissions:** 600 (config), 700 (home directory)

**Version Requirements:**
- Minimum: 2026.1.29 (CVE patches)
- Recommended: 2026.2.9+ (safety scanner + credential redaction)

**API Key Prefixes:**
- OpenRouter: `sk-or-v1-`
- Anthropic: `sk-ant-`
- Voyage AI: `pa-`

**Access Profiles:**
- Explorer: Read-heavy, write-restricted, browser denied
- Guarded: Shell commands blocked
- Restricted: Messaging and memory only

**Workspace Templates (8 files):**
- AGENTS.md: Operating manual
- BOOTSTRAP.md: First-run wizard (self-deletes)
- HEARTBEAT.md: Scheduled checks
- IDENTITY.md: Bot name/emoji/vibe
- MEMORY.md: Long-term memory (private sessions only)
- SOUL.md: Personality
- TOOLS.md: Infrastructure docs
- USER.md: Owner profile

**Critical Constraints:**
1. Config file is Zod-validated (unknown keys fail)
2. BOOTSTRAP.md existence = first-run incomplete
3. Gateway rewrites `${VAR_NAME}` → plaintext on restart (LaunchAgent plist is canonical)
4. MEMORY.md only loads in private sessions (not group channels)
5. `localhost` → IPv6 in Node 18+ (use `127.0.0.1`)
6. Homebrew install requires admin (by design)
7. Minimal mode: 17 steps (skips Mac user + Discord)

**Patterns to Follow:**
- Atomic config editing: backup → Python edit → validate → rename (or restore)
- Template copying: `cp -n` from `templates/workspace/`
- Python safety: `sys.argv` + `<< 'PYEOF'` heredocs (never interpolate shell vars)
- Version comparison: Python-based semantic versioning
- Error recovery: Progress tracking, retry loops, manual fallbacks

**To Do X, Touch These Files:**
- **Add API provider:** Update ALLOWED_MODELS array in quickstart v2 script, add validation logic, update all 7 content files
- **Change gateway port:** Update DEFAULT_GATEWAY_PORT constant, cross-file consistency (7 files)
- **Modify wizard questions:** Update step2_configure() in quickstart, regenerate companion.html accordion, update docs
- **Add security check:** Add check function in verify.sh, increment check count (18 → 19), update README/CLAUDE.md
- **Update templates:** Edit files in `templates/workspace/`, regenerate checksums, update get_template_checksum() case statement

**File Dependencies:**
- `companion.html` references: `openclaw-quickstart-v2.sh` (output matching), `favicon.png`, localStorage
- `index.html` references: `welcome-to-clawstarter-video.mp4`, `clawstarter-video-thumbnail.png`, `favicon.png`, localStorage
- `openclaw-quickstart-v2.sh` references: `templates/workspace/*` (via checksums), GitHub main branch, Homebrew, Node.js, OpenClaw CLI
- `openclaw-autosetup.sh` references: `openclaw-verify.sh` (final step), `templates/workspace/*`, config file
- `openclaw-verify.sh` references: `openclaw.json`, LaunchAgent plist, log files, TCC database

**How Files Connect:**
1. **User journey:** `index.html` → download `openclaw-quickstart-v2.sh` → follow `companion.html` → verify with `openclaw-verify.sh`
2. **Alternative:** `openclaw-autosetup.sh` (automated) → calls `openclaw-verify.sh` as step 19
3. **Template flow:** `openclaw-quickstart-v2.sh` downloads templates from GitHub → copies to `~/.openclaw/workspace/`
4. **Security hardening:** `openclaw-autosetup.sh` step 16 migrates secrets to LaunchAgent plist, updates config with `${VAR_NAME}` references
5. **Post-install:** `BOOTSTRAP.md` runs first chat → self-deletes → `OPENCLAW-FOUNDATION-PLAYBOOK-TEMPLATE.md` (Phase 1 urgent)

---

## USER-FOCUSED SUMMARY (Narrative)

ClawStarter is your complete setup guide for OpenClaw — a personal AI assistant that runs on your Mac. It's not just an installer; it's a curated playbook based on real production use, packaged into a beginner-friendly toolkit.

### What You Get

**1. A Security-First Installer**

The main installation script (`openclaw-quickstart-v2.sh`) has gone through three phases of security hardening. It stores your API keys in macOS Keychain (not in plain text), validates all inputs against strict allowlists, and verifies downloaded templates with SHA256 checksums. It takes about 15 minutes and asks you just 3 questions:

- Which AI provider do you want? (with guided signup if you don't have one yet)
- What will you use this for? (content creation, productivity, coding, or all three)
- Is this a shared Mac or dedicated device?

Based on your answers, it recommends the right AI models, skill packs, and security settings. The script handles everything automatically: installing dependencies (Homebrew, Node.js, OpenClaw), configuring your bot, creating workspace templates, and starting the background service.

**2. An Interactive Companion Guide**

If you prefer to understand each step as it happens, open `companion.html` in your browser. It's a beautiful, step-by-step walkthrough that mirrors exactly what you'll see in Terminal. The guide includes:

- A pre-install checklist (3 things to have ready)
- Visual Terminal tutorials (how to open Terminal, where to type commands)
- Accordion sections matching each install step
- Critical warnings highlighted (like "your password will be invisible when you type")
- Copy buttons for every command
- A "Now What?" section for after setup

The companion page works offline, stores your progress in your browser, and has a dark/light theme toggle.

**3. Battle-Tested Workspace Templates**

Your bot needs a personality and operating manual. ClawStarter includes 8 template files that we've refined through months of production use:

- **AGENTS.md** — How your bot operates (startup procedure, safety rules, memory discipline)
- **SOUL.md** — Your bot's personality and communication style
- **IDENTITY.md** — Bot name, emoji, vibe
- **USER.md** — Your profile and preferences
- **MEMORY.md** — Long-term memory template
- **TOOLS.md** — Infrastructure notes (API providers, devices, channels)
- **HEARTBEAT.md** — Scheduled background checks
- **BOOTSTRAP.md** — A first-run wizard that asks you 9 personalization questions, then deletes itself

On first chat, your bot runs BOOTSTRAP.md and asks about your timezone, working style, communication preferences, and goals. This takes 5 minutes and makes the bot genuinely yours.

**4. A Post-Setup Diagnostic**

After installation, run `openclaw-verify.sh` to check that everything is working. It performs 18 verification checks:

- Is Node.js the right version?
- Is the gateway running?
- Are file permissions locked down?
- Is FileVault encryption enabled?
- Are API keys stored securely?
- Is the bot configured correctly?

The script gives color-coded results (green for pass, red for fail, yellow for warnings) and tells you exactly how to fix any issues.

**5. Optional Advanced Hardening**

Once your bot is running, open the Foundation Playbook (`OPENCLAW-FOUNDATION-PLAYBOOK-TEMPLATE.md`). It's an 8-phase security and operations guide. Phase 1 (Security Hardening) is urgent — do it the same week you set up. The other 7 phases are optional and can be tackled at a pace of one per week:

- Memory system tuning
- Channel integrations
- Cron job configuration
- Monitoring and alerts
- Cost optimization
- Backup strategy
- Disaster recovery

### Why ClawStarter Exists

Most people hit two walls when setting up OpenClaw:

1. **The setup is complex.** There are 10+ steps, multiple config files, security considerations, and Terminal commands.
2. **There's a "now what?" gap.** You get the bot running, but then... what do you tell it? How do you configure its personality? What should you automate?

ClawStarter solves both. The installer handles the technical complexity. The templates give you a production-quality starting point. And the companion guide explains the "why" behind every step.

This isn't a generic installer. It's our playbook — the exact setup we use in production, refined over months of real use, packaged for beginners.

### What Makes It Secure

ClawStarter implements several security layers that most setup guides skip:

- **API keys never touch the filesystem in plaintext.** They're stored in macOS Keychain or as environment variables.
- **The gateway doesn't advertise itself on the network.** mDNS/Bonjour discovery is disabled.
- **Your bot runs in a dedicated Mac user account.** It can't access your personal files.
- **All inputs are validated against strict allowlists.** You can't accidentally inject malicious commands.
- **Downloaded templates are checksum-verified.** You know the files haven't been tampered with.
- **File permissions are locked down.** Config files are mode 600, home directory is mode 700.

The verify script checks all of this automatically.

### What's Next

After setup, you'll have a bot that:
- Answers questions and has conversations
- Searches the web for real-time info
- Remembers context from past chats
- Runs on your Mac 24/7 (auto-restarts on reboot)
- Can be accessed via web dashboard, Discord, Telegram, or iMessage (you pick)

The BOOTSTRAP.md wizard will personalize it in 5 minutes. The Foundation Playbook will harden security and add advanced features. And the skill packs (weather, summarize, x-research, etc.) give your bot real capabilities.

You're not just installing software. You're setting up a genuinely useful AI assistant that learns your preferences, respects your privacy, and runs entirely under your control.

---

## NAVIGATION ENTRIES

### To Do X, Touch These Files

**Add a new AI provider:**
1. Edit `ALLOWED_MODELS` array in `openclaw-quickstart-v2.sh`
2. Add validation logic in `validate_model()` function
3. Update model selection logic in `step2_configure()`
4. Update all 7 content files (README, CLAUDE, companion.html, index.html, autosetup, verify, Foundation Playbook)
5. Regenerate companion.html accordion content to match new options

**Change the gateway port:**
1. Update `DEFAULT_GATEWAY_PORT` constant in quickstart script
2. Update `readonly DEFAULT_GATEWAY_PORT=18789` in autosetup script
3. Update port references in verify script (2 locations)
4. Update cross-file consistency table in CONTRIBUTING.md
5. Update all doc references (README, companion.html, index.html, CLAUDE.md, Foundation Playbook)

**Modify wizard questions:**
1. Edit `step2_configure()` in `openclaw-quickstart-v2.sh`
2. Update personality/model/security logic
3. Regenerate companion.html Step 9 accordion content
4. Update "3 questions" messaging in README, CLAUDE.md, index.html
5. Update AI-assisted prompts (CLAUDE-SETUP-PROMPT.txt, CLAUDE-CODE-SETUP.md)

**Add a security check:**
1. Add `step_CHECKNAME()` function in `openclaw-verify.sh`
2. Call it in the main sequence
3. Increment check count constant (18 → 19)
4. Update README.md check count
5. Update CLAUDE.md check count
6. Update companion.html "18 checks" reference
7. Add to SECURITY.md checklist if user-actionable

**Update workspace templates:**
1. Edit source files in `templates/workspace/`
2. Regenerate SHA256 checksums: `shasum -a 256 templates/workspace/*.md`
3. Update `get_template_checksum()` case statement in quickstart script
4. Update template count in README if files added/removed
5. Test copy operation in autosetup Step 12

**Fix a security vulnerability:**
1. Implement fix in relevant script(s)
2. Add to "Completed" section of ROADMAP.md
3. Update SECURITY.md if it changes threat model
4. Document in CHANGELOG (if one exists) or commit message
5. Increment script version number
6. Update "Recommended version" in all docs if this becomes new minimum

**Add a new dependency:**
1. Update "Requirements" section in README.md
2. Add installation logic to `step1_install()` in quickstart
3. Add verification check to verify script
4. Update CLAUDE.md "Dependencies" list
5. Update companion.html pre-install checklist if user must install manually

**Change color scheme:**
1. Update CSS variables in `companion.html` (`:root` and `[data-theme="dark"]`)
2. Update CSS variables in `index.html`
3. Ensure terminal blocks stay dark in light mode
4. Test dark/light toggle in both pages
5. Update any hardcoded color values in inline styles

**Add a FAQ:**
1. Add `<details>` block in index.html FAQ section
2. Maintain alphabetical or thematic ordering
3. Keep `<summary>` concise (one line)
4. Use `<strong>` for key phrases in answer
5. Link to relevant docs if answer is detailed

---

## HOW FILES CONNECT

### User Journey Flow

```
Entry Point: index.html (marketing landing)
    ↓
Download: openclaw-quickstart-v2.sh
    ↓
Companion: companion.html (step-by-step walkthrough)
    ↓
Execution: bash openclaw-quickstart-v2.sh
    ├─> Downloads templates from GitHub (templates/workspace/*)
    ├─> Stores API keys in macOS Keychain
    ├─> Generates openclaw.json config
    ├─> Creates LaunchAgent plist
    └─> Starts gateway
    ↓
Verification: openclaw-verify.sh
    ├─> Checks 18 aspects of installation
    └─> Reports pass/fail/warn with fix instructions
    ↓
First Chat: BOOTSTRAP.md runs
    ├─> Asks 9 personalization questions
    ├─> Updates USER.md, SOUL.md, IDENTITY.md
    └─> Self-deletes
    ↓
Hardening: OPENCLAW-FOUNDATION-PLAYBOOK-TEMPLATE.md
    └─> 8 phases (Phase 1 urgent, rest optional)
```

### Alternative Journey (Automated)

```
Entry Point: openclaw-autosetup.sh
    ↓
19 Steps (with progress tracking):
    1-7: Dependencies & system config
    8-11: User setup & onboarding (human checkpoints)
    12: Workspace scaffolding (copies templates)
    13-17: Verification & hardening
    18: openclaw doctor
    19: openclaw-verify.sh (diagnostic)
    ↓
Resume Support: --resume flag skips completed steps
    ↓
Same endpoint: BOOTSTRAP.md first chat → Foundation Playbook
```

### File Relationships

**Template Flow:**
```
templates/workspace/*.md
    ↓ (downloaded via curl)
openclaw-quickstart-v2.sh
    ├─> get_template_checksum() — SHA256 lookup
    ├─> verify_and_download_template() — curl + shasum
    └─> cp to ~/.openclaw/workspace/
    ↓
BOOTSTRAP.md runs on first chat
    ├─> Reads templates (SOUL.md, USER.md, IDENTITY.md)
    ├─> Updates based on user responses
    └─> Deletes itself
```

**Config Generation:**
```
Step2_configure() in quickstart script
    ├─> Collects: API key, use case, setup type
    ├─> Determines: model, personality, security level
    └─> Stores API key in Keychain
    ↓
Step3_setup()
    ├─> Python heredoc generates openclaw.json
    ├─> Includes: model, ${VAR_NAME} references, gateway config
    ├─> chmod 600 openclaw.json
    └─> Create LaunchAgent plist with EnvironmentVariables
    ↓
Gateway startup
    └─> Resolves ${VAR_NAME} → plaintext (rewrites config)
```

**Security Hardening:**
```
openclaw-autosetup.sh Step 16: step_harden_secrets()
    ├─> Scans config for 7 known secret paths
    ├─> Extracts plaintext values
    ├─> Replaces with ${VAR_NAME} references
    ├─> Adds EnvironmentVariables to LaunchAgent plist
    └─> Restarts gateway (triggers rewrite to plaintext)
    ↓
openclaw-verify.sh Check 12: Security Quick Check
    └─> Searches for API keys in exposed locations
```

**Diagnostic Flow:**
```
openclaw-verify.sh
    ├─> Reads: openclaw.json, LaunchAgent plist, logs
    ├─> Checks: 18 aspects (dependencies, config, gateway, security, etc.)
    ├─> Uses Python for JSON parsing (no secret exposure)
    └─> Outputs: color-coded results + fix instructions
    ↓
If issues found
    └─> User follows fix instructions
    └─> Re-runs verify.sh
```

**Documentation Consistency:**
```
CLAUDE.md (AI agent reference)
    ├─> Version requirements
    ├─> Critical constraints
    └─> Cross-file consistency table
    ↓
CONTRIBUTING.md (contributor guide)
    ├─> Same version requirements
    ├─> Same cross-file table
    └─> Code style patterns
    ↓
README.md (user-facing)
    ├─> Same version requirements
    └─> Simplified architecture diagram
    ↓
companion.html + index.html
    ├─> Same version requirements (in copy)
    └─> Same model/provider names
```

**Cross-References:**

| File | References |
|------|-----------|
| `companion.html` | `openclaw-quickstart-v2.sh` (output matching), `favicon.png`, browser localStorage |
| `index.html` | `welcome-to-clawstarter-video.mp4`, `clawstarter-video-thumbnail.png`, `favicon.png`, localStorage |
| `openclaw-quickstart-v2.sh` | `templates/workspace/*` (checksums), `https://raw.githubusercontent.com/jeremyknows/clawstarter/main`, Homebrew, Node.js, OpenClaw CLI, macOS Keychain |
| `openclaw-autosetup.sh` | `openclaw-verify.sh` (step 19), `templates/workspace/*`, `openclaw.json`, LaunchAgent plist |
| `openclaw-verify.sh` | `openclaw.json`, LaunchAgent plist, `/tmp/openclaw/*.log`, `~/.openclaw/logs/`, TCC database, `openclaw doctor` |
| `README.md` | All other doc files (overview + links) |
| `CONTRIBUTING.md` | `CLAUDE.md` (patterns), `docs/CODEBASE_MAP.md` (architecture) |
| `SECURITY.md` | `CLAUDE.md` (constraints), CVE references, OpenClaw docs |
| `ROADMAP.md` | All scripts (completed features), all docs (consistency items) |
| `PRISM-MARATHON.md` | `JEREMY-VISION-V2.md` (reference), all scripts (audit targets) |

### Data Flow

**API Key Journey:**
```
User pastes key in Terminal
    ↓
validate_api_key() checks format
    ↓
keychain_store() saves to macOS Keychain
    (service: ai.openclaw, account: openrouter-api-key)
    ↓
Config file gets ${OPENROUTER_API_KEY} reference
    ↓
LaunchAgent plist gets EnvironmentVariables dict:
    OPENROUTER_API_KEY=sk-or-v1-actual-key
    ↓
Gateway reads plist env vars
    ↓
Gateway resolves ${OPENROUTER_API_KEY} in config
    ↓
Gateway rewrites config with plaintext (OpenClaw behavior)
    ↓
Verify script checks:
    - Keychain contains key (without revealing it)
    - Config file is chmod 600
    - No keys in exposed locations
```

**Template Journey:**
```
GitHub repo: templates/workspace/AGENTS.md
    ↓
Script downloads via curl with checksum verification
    ↓
cp -n to ~/.openclaw/workspace/AGENTS.md
    (preserves existing file if present)
    ↓
First chat: BOOTSTRAP.md reads AGENTS.md
    ↓
User answers 9 questions
    ↓
BOOTSTRAP.md updates AGENTS.md with personalization
    ↓
BOOTSTRAP.md deletes itself
    ↓
Agent loads AGENTS.md on every session startup
```

**Progress Tracking (autosetup only):**
```
Step completion
    ↓
mark_step("step_name")
    ↓
Python writes to ~/.openclaw-autosetup-progress:
    {
      "version": "1.0.0",
      "started": "2026-02-15T14:38:00Z",
      "mode": "full",
      "steps": {
        "detect_env": "2026-02-15T14:38:05Z",
        "install_homebrew": "2026-02-15T14:40:12Z",
        ...
      }
    }
    ↓
On --resume: is_step_done() checks JSON
    ↓
Skips completed steps, continues from last incomplete
```

---

## Analysis Complete

**Files analyzed:** 17  
**Total tokens processed:** ~114,000  
**Analysis saved to:** `~/.openclaw/apps/clawstarter/docs/subagent-1-core.md`

This analysis provides comprehensive documentation for:
- AI agents working in the ClawStarter codebase
- Human developers contributing to the project
- Users wanting to understand the architecture
- Future maintainers needing navigation guidance

All relationships, dependencies, patterns, and gotchas have been documented with agent-focused precision and user-focused narrative clarity.
