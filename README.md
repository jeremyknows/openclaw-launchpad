# ClawStarter

Your battle-tested OpenClaw production setup, packaged as a beginner-friendly installer.

**What it is:** Everything you need to go from zero to a running 24/7 AI assistant in 15-20 minutes. Not just an installer — a curated playbook from real production use, simplified for first-time users.

**Audience:** Technical-curious founders and first-time OpenClaw users. Basic comfort with Terminal helpful but not required.

## Project Status

**Current version:** v2.8.0 (2026-02-15)  
**Status:** Production-ready — live tested and PRISM-audited  
**Coverage:** 13/20 PRISM reviews complete (security ✅, UX ✅, docs ✅)

**What works:**
- ✅ One-command install (`openclaw-quickstart-v2.sh`)
- ✅ Security-hardened (Keychain isolation, input validation, atomic file ops)
- ✅ Interactive companion page (`companion.html`)
- ✅ Starter pack with 5 pre-configured cron jobs (~$0.37/month)
- ✅ 3 workflow packages (content creator, app builder, workflow optimizer)
- ✅ Post-install verification (18 checks)

**In progress:**
- ⏳ Template checksum re-enablement (security enhancement)
- ⏳ Accessibility improvements (WCAG Level AA compliance)
- ⏳ End-to-end user testing with non-technical users

## Quick Start

**Option 1: One-Command Install** (recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/jeremyknows/clawstarter/main/openclaw-quickstart-v2.sh | bash
```

**Option 2: Interactive Guide**  
Open **`companion.html`** in your browser and follow the step-by-step walkthrough. (Works offline, no internet needed.)

## What's in This Package

### Setup Guides (pick one)

| File | What it is | Best for |
|------|-----------|----------|
| `companion.html` | Interactive setup wizard (10 steps) | Most people (recommended) |
| `OPENCLAW-SETUP-GUIDE.md` | Text version of the setup guide | People who prefer reading markdown |

### AI-Assisted Setup (optional)

These are prompts you paste into an AI assistant so it can walk you through setup conversationally:

| File | What it is | Best for |
|------|-----------|----------|
| `OPENCLAW-CLAUDE-SETUP-PROMPT.txt` | Prompt for [Claude.ai](https://claude.ai) | Chatting through setup with Claude in a browser |
| `OPENCLAW-CLAUDE-CODE-SETUP.md` | Prompt for [Claude Code](https://claude.ai/claude-code) (CLI) | Having Claude Code run commands for you in Terminal |

The HTML guide also generates a customized version of the Claude.ai prompt on its final page, tailored to the choices you made in the configurator.

### Automation

| File | What it is | Best for |
|------|-----------|----------|
| `openclaw-autosetup.sh` | Automated setup script (19 steps) — handles ~80% of the work | "Just do it for me" people |
| `openclaw-verify.sh` | Post-setup diagnostic (18 checks) — checks for common issues | Verifying everything is working |

### After Setup

| File | What it is |
|------|-----------|
| `OPENCLAW-FOUNDATION-PLAYBOOK-TEMPLATE.md` | Optional hardening guide (security audit, backups, monitoring). Do Phase 1 this week; the rest at your own pace. |
| `templates/workspace-scaffold-prompt.md` | Standalone prompt — paste into your bot's first chat to scaffold workspace + run first-time personalization. Use this if you didn't run autosetup.sh and aren't following the Playbook. |

### Starter Pack & Expansion Packs

ClawStarter provides three layers of configuration:

**1. Workspace Templates** (`templates/workspace/`)  
Universal base files for any agent. The installer copies these automatically:

| File | Purpose |
|------|---------|
| `AGENTS.md` | Operating manual — startup procedure, safety rules, memory discipline |
| `SOUL.md` | Personality and communication style |
| `IDENTITY.md` | Name, emoji, vibe |
| `USER.md` | Owner profile and preferences |
| `MEMORY.md` | Long-term memory template |
| `HEARTBEAT.md` | Daily rhythm configuration |
| `BOOTSTRAP.md` | First-run wizard (asks 9 questions, then deletes itself) |
| `TOOLS.md` | Environment-specific infrastructure (optional) |

**2. Starter Pack** (`starter-pack/`)  
Production-tested configs simplified for beginners:
- Simplified operating manual (7KB vs 24KB production)
- 5 pre-configured cron jobs (morning briefing, email monitor, evening memory, cost report, health check)
- 2 specialist agents (Librarian for research, Treasurer for cost tracking)
- Security audit prompt (self-service checklist)
- Operating cost: ~$0.37/month

**3. Workflow Packages** (`workflows/`)  
Domain-specific bundles with specialized AGENTS.md + skills + cron jobs:

| Workflow | Best For | Difficulty | Time to Value |
|----------|----------|------------|---------------|
| `content-creator` | Social media, video, podcasts | Beginner | 5-10 min |
| `app-builder` | Coding, GitHub, dev tools | Intermediate | 10-15 min |
| `workflow-optimizer` | Email, calendar, tasks | Beginner | 5-10 min |

Each workflow includes: domain-specific behavior patterns, one-command skill installer, troubleshooting guide, and pre-configured automation jobs.

## Project Structure

```
clawstarter/
├── openclaw-quickstart-v2.sh          # Primary installer (v2.7.0-prism-fixed)
├── openclaw-autosetup.sh              # Full automation (19 steps, resume support)
├── openclaw-verify.sh                 # Post-install diagnostic (18 checks)
├── companion.html                     # Interactive setup walkthrough
├── index.html                         # Marketing landing page
├── docs/
│   └── CODEBASE_MAP.md               # Full architecture documentation
├── templates/
│   └── workspace/                     # 8 universal templates
├── starter-pack/                      # Beginner configs + 5 cron jobs
├── workflows/                         # 3 domain-specific bundles
│   ├── content-creator/
│   ├── app-builder/
│   └── workflow-optimizer/
├── fixes/                             # Security patches + test suites
└── reviews/                           # 20-PRISM marathon analysis
```

**Total:** 187 files, ~784K tokens analyzed and documented

## Requirements

- **Mac** (Apple Silicon or Intel)
- **macOS 13+** (Ventura or newer)
- **Admin access** to install dependencies (Homebrew, Node.js, OpenClaw)
- **Time:** 15-20 minutes with quickstart script, 30 minutes for full manual setup

## How the Pieces Fit Together

```
You are here
     │
     ▼
 ┌─────────────────────────────────┐
 │  openclaw-setup-guide.html      │──── The main guide. Start here.
 │  (or OPENCLAW-SETUP-GUIDE.md)   │
 └──────────────┬──────────────────┘
                │
    ┌───────────┼───────────────┐
    ▼           ▼               ▼
 Manual    Script mode     AI-assisted
 (follow   (runs           (paste prompt
  steps)    autosetup.sh)   into Claude)
    │           │               │
    └───────────┼───────────────┘
                ▼
        Workspace scaffolded ──── Templates copied, daily log created
                │
                ▼
        openclaw-verify.sh ──── Confirms everything is working
                │
                ▼
        BOOTSTRAP.md ──── First-chat personalization (bot asks 9 questions)
                │
                ▼
        Foundation Playbook ──── Optional post-setup hardening
```

## Architecture

For full architecture documentation, data flow diagrams, and a navigation guide for contributors, see [docs/CODEBASE_MAP.md](docs/CODEBASE_MAP.md).

## What's Next

**First chat:**  
Your bot will run `BOOTSTRAP.md` automatically — it asks 9 personalization questions (name, timezone, preferences) and takes about 5 minutes. After completion, it deletes itself.

**Post-setup hardening:**  
Open `OPENCLAW-FOUNDATION-PLAYBOOK-TEMPLATE.md` — an optional 8-phase guide. **Phase 1 (Security Hardening) is urgent** — complete it within the first week. The rest can be done at your own pace.

**Expansion packs:**
- Install a workflow package: `bash workflows/content-creator/skills.sh`
- Add skill packs: weather, summarize, image generation, TTS
- Configure Discord/Telegram/X (Twitter) integration — see `docs/x-twitter-integration.md`
- Connect X (Twitter) — see `docs/x-twitter-integration.md`
- Set up additional cron jobs for automation

**Learning resources:**
- `starter-pack/STARTER-PACK-MANIFEST.md` — Complete guide with learning path
- `docs/CODEBASE_MAP.md` — Full architecture and navigation
- `reviews/PRISM-MARATHON-EXECUTIVE-SUMMARY.md` — Strategic analysis

## Version

**Recommended: v2026.2.9** (latest). Minimum: v2026.1.29 (security patches). The guide and scripts check your version automatically.

## Security

ClawStarter implements defense-in-depth security with 6 layers:

1. **Input validation** — All user inputs validated against strict allowlists
2. **Safe file creation** — Atomic operations (touch + chmod 600 simultaneously)
3. **XML escaping** — Prevents LaunchAgent plist injection attacks
4. **Quoted heredocs** — Blocks shell expansion in literal content
5. **Checksum verification** — SHA256 hashes for all templates (re-enablement pending)
6. **Secrets isolation** — API keys in macOS Keychain + LaunchAgent env vars, not config files

**Security fixes applied (v2.7.0):**
- ✅ stdin/TTY handling (usability fix for `curl | bash`)
- ✅ API key security (Keychain isolation)
- ✅ Command injection prevention (input validation)
- ✅ Race condition elimination (atomic file creation)
- ✅ XML injection protection (LaunchAgent escaping)

**Risk reduction:** 90% (CVSS 9.0 critical → 1.0 low)

**Best practices:**
- Use a dedicated Mac user account (recommended in setup guide)
- Enable FileVault disk encryption
- Keep OpenClaw updated (min 2026.1.29, recommended 2026.2.9+)
- Review all skill pack code before installation
- Run `openclaw-verify.sh` after setup (18 security checks)

For full security documentation, see [SECURITY.md](SECURITY.md).

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development workflow
- Cross-file consistency requirements
- Code style guidelines (bash, Python, HTML)
- Testing requirements

**Key areas for contribution:**
- Additional workflow packages (researcher, data analyst, home automation)
- Template improvements (accessibility, mobile, error handling)
- Security enhancements (template checksums, GPG signing, sandboxing)
- Documentation (video walkthroughs, troubleshooting guides)

## License

MIT License. See [LICENSE](LICENSE) for details.

---

**Made with care by Jeremy Knows** • [OpenClaw.ai](https://openclaw.ai) • Join us on [Discord](https://discord.gg/openclaw)
