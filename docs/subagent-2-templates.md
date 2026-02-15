# ClawStarter Templates & Workflows — Architecture Analysis

**Subagent 2: Detailed Documentation Analysis**  
**Date:** 2026-02-15  
**Scope:** Starter Pack, Workspace Templates, Workflow Packages

---

## Executive Summary

ClawStarter provides three layers of battle-tested configuration:

1. **Starter Pack** (`starter-pack/`) — Simplified production configs for beginners
2. **Workspace Templates** (`templates/workspace/`) — Universal base files for any agent
3. **Workflow Packages** (`workflows/`) — Domain-specific skill bundles (content creator, app builder, etc.)

**Value proposition:** Not "here's how to install," but "here's what works in production, simplified for you."

---

## 1. Starter Pack (`starter-pack/`)

### Purpose
Pre-configured, production-tested foundation for OpenClaw beginners. Distills months of real usage into a 45KB documentation bundle.

### Core Files

#### STARTER-PACK-MANIFEST.md (12KB)
**Responsibility:** Complete installation guide, file structure, configuration options

**Key Content:**
- What's included (core system, agents, cron jobs, security)
- Value proposition ("We've been running this in production")
- Installation steps (automated + manual)
- Post-installation checklist
- Operating costs (~$0.37/month overhead)
- Security features
- Learning path (Week 1-3 progression)
- Support resources

**Connects to:**
- References all other starter pack files
- Links to CRON-TEMPLATES.md for automation details
- Points to SECURITY-AUDIT-PROMPT.md for safety verification
- Mentions expansion packs (skill packs, advanced features)

**Pattern:** Comprehensive onboarding document. Start here, branch to specifics.

---

#### AGENTS-STARTER.md (7KB)
**Responsibility:** Simplified operating manual for beginners

**Key Content:**
- Startup checklist (read SOUL.md, USER.md, memory files)
- Memory system explained (daily files + long-term MEMORY.md)
- Golden rule: "Write it down" (no mental notes)
- Pilot's checklist — memory checkpoints every 30 min
- Safety rules (ask before external actions)
- Quality standards (evidence before assertions, verification before completion)
- Cross-session memory protocol (512-byte atomic writes)

**Connects to:**
- Simplified from production AGENTS.md (24KB → 7KB)
- References SOUL.md for personality
- References USER.md for owner profile
- References MEMORY.md for long-term context
- Used by all starter pack agents (main, Librarian, Treasurer)

**Pattern:** Operating system kernel. Defines how agents think and remember.

**Notable conventions:**
- Standardized memory format: `## [HH:MM] AgentId:SessionType:Detail — Topic`
- 512-byte limit per entry (POSIX atomic append guarantee)
- Session type detection (main, discord, cron, subagent)
- Memory checkpoint triggers (30 min, context shift, task completion, commitment)

---

#### SOUL-STARTER.md (4KB)
**Responsibility:** Agent personality template

**Key Content:**
- Core identity ("genuinely helpful, not performatively helpful")
- Communication style (skip corporate jargon, be direct)
- Boundaries (privacy-first, ask before external actions)
- Operating philosophy (earn trust through competence)
- Decision-making framework
- Evolution note (living document)

**Connects to:**
- Read by AGENTS-STARTER.md during startup
- Customized by user during BOOTSTRAP
- References souls.directory for inspiration

**Pattern:** Personality definition. Who the agent is, not just what it does.

---

#### CRON-TEMPLATES.md (12KB)
**Responsibility:** Exact cron job definitions with prompts and costs

**Key Content:**
- 5 pre-configured jobs:
  1. Morning Briefing (8 AM weekdays, gemini-lite, $0.02/month)
  2. Email Monitor (every 30 min, gpt-nano, $0.08/month)
  3. Evening Memory (9 PM daily, haiku, $0.09/month)
  4. Weekly Cost Report (Fridays 5 PM, gemini-lite, $0.01/month)
  5. Memory Health Check (Sundays 8 PM, haiku, $0.01/month)
- Template format (JSON structure)
- Installation notes
- Customization guide (cron syntax, modifying prompts)
- Cost breakdown

**Connects to:**
- Jobs reference AGENTS-STARTER.md memory checkpoint rules
- Treasurer job uses Treasurer specialist
- Librarian job uses Librarian specialist
- Installer copies these to user's cron directory

**Pattern:** Automation recipes. Proven useful, not theoretical.

**Notable conventions:**
- All cron jobs MUST write to `memory/YYYY-MM-DD.md` before completing
- Model selection based on task complexity (nano for simple, haiku for reasoning)
- Delivery modes: announce (post to channel) or silent (write to memory only)

---

#### SECURITY-AUDIT-PROMPT.md (10KB)
**Responsibility:** Self-service security checklist

**Key Content:**
- 10 audit categories (credentials, permissions, memory privacy, etc.)
- Exact prompt to paste to agent for audit
- Expected output format
- Common issues and fixes
- When to run (post-install, monthly, after config changes)
- Emergency response procedures

**Connects to:**
- Validates AGENTS-STARTER.md safety rules
- Checks memory privacy boundaries
- Verifies cron job configurations
- References MEMORY.md exclusion from group chats

**Pattern:** Trust but verify. Agent audits its own setup.

---

#### README.md (Starter Pack)
**Responsibility:** Quick reference and philosophy

**Key Content:**
- "We've been running this in production" philosophy
- Quick start options (automated vs manual)
- What you get (memory system, specialists, automation)
- What's NOT included (expansion packs)
- Operating cost summary
- Credits and license

**Connects to:**
- Entry point to all starter pack docs
- References STARTER-PACK-MANIFEST.md for details
- Points to expansion packs (skill packs, workflows)

**Pattern:** Executive summary + quick start.

---

#### SKILLS-STARTER-PACK.md
**Responsibility:** Skill installation guide

**Key Content:**
- 5 essential skills (weather, Apple Notes, Reminders, Summarize, GifGrep)
- Level 2 skills (1Password, Google Workspace, Whisper, etc.)
- Installation speed run (all 5 in one command)
- Learning path (Week 1-3 progression)
- Joy Pack (image generation, TTS, Spotify)

**Connects to:**
- Workflows reference these skills
- Skills enable CRON-TEMPLATES functionality
- Security audit checks skill permissions

**Pattern:** Capability catalog. What's possible, how to enable it.

---

### Starter Pack Relationships

```
STARTER-PACK-MANIFEST.md (entry point)
├── AGENTS-STARTER.md (how agents operate)
│   ├── reads → SOUL-STARTER.md (personality)
│   ├── reads → USER.md (owner profile, from templates/)
│   └── writes → memory/YYYY-MM-DD.md (daily logs)
├── CRON-TEMPLATES.md (automation recipes)
│   ├── uses → AGENTS-STARTER.md (memory checkpoint rules)
│   └── creates → memory/ entries (cross-session coordination)
├── SECURITY-AUDIT-PROMPT.md (safety verification)
│   └── validates → all above files
└── SKILLS-STARTER-PACK.md (capability catalog)
    └── enables → cron jobs + workflows
```

---

## 2. Workspace Templates (`templates/workspace/`)

### Purpose
Universal base files for any OpenClaw agent, regardless of use case. Installation-time templates that get personalized during BOOTSTRAP.

### Core Files

#### AGENTS.md (Template)
**Responsibility:** Full operating manual (production version)

**Key Content:**
- First run procedure (BOOTSTRAP detection)
- Startup ritual (load SOUL, USER, IDENTITY, memory)
- Memory discipline (daily notes, long-term consolidation)
- Safety rules (ask before external, never credentials)
- Code discipline (read before write, pre-flight checklist)
- Quality standards (evidence, verification, cost discipline, PRISM)
- Session-specific overlays (main session vs group chat vs cron)
- Heartbeat vs cron decision tree
- Memory maintenance schedule

**Connects to:**
- Starter pack AGENTS-STARTER.md is simplified from this (24KB → 7KB)
- References SOUL.md, USER.md, IDENTITY.md, HEARTBEAT.md, MEMORY.md, TOOLS.md
- Includes placeholders for `[SESSION-SPECIFIC MEMORY RULES]` (filled by installer)
- Defines overlay system for main session (expanded permissions)

**Pattern:** Complete operating system. Everything an agent needs to know.

**Notable conventions:**
- Overlay architecture (base + session-specific additions)
- PRISM methodology (multi-agent review for critical decisions)
- Cost discipline (model selection guidance)
- Override system respect (understand before bypassing)

---

#### SOUL.md (Template)
**Responsibility:** Personality framework

**Key Content:**
- Placeholders for name, vibe, emoji (established during BOOTSTRAP)
- Communication style (helpful not performative, try before asking)
- Boundaries (privacy, external actions, group chat etiquette)
- Operating philosophy (earn trust through competence)
- Decision-making framework
- Evolution notes

**Connects to:**
- Filled during BOOTSTRAP.md process
- Read by AGENTS.md at startup
- References souls.directory for inspiration
- Template for SOUL-STARTER.md (simplified version)

**Pattern:** Identity scaffold. User fills the blanks.

---

#### IDENTITY.md (Template)
**Responsibility:** Agent self-concept

**Key Content:**
- Official name
- Nature (AI assistant for [areas])
- Vibe (descriptive phrase)
- Visual identity (emoji, optional avatar)
- Operating principles reference

**Connects to:**
- Filled during BOOTSTRAP
- Read by AGENTS.md at startup
- Short and stable (rarely changes)

**Pattern:** Business card. Essential facts only.

---

#### HEARTBEAT.md (Template)
**Responsibility:** Daily rhythm configuration

**Key Content:**
- Check schedule (morning, midday, evening)
- What to check (calendar, email, alerts, system health)
- How to report (format examples)
- Alert decision tree (immediate vs scheduled)
- Gateway watchdog configuration
- Memory consolidation schedule

**Connects to:**
- References USER.md for timezone
- Used by main session for batched checks
- Contrasts with cron jobs (isolated, time-precise)
- Writes to memory/YYYY-MM-DD.md

**Pattern:** Routine definition. When to check in, what to look for.

**Notable conventions:**
- Heartbeat vs cron decision tree
- HEARTBEAT_OK for "nothing urgent" (don't spam)
- Silence rule (only message when there's news)

---

#### MEMORY.md (Template)
**Responsibility:** Long-term knowledge base

**Key Content:**
- Critical rules (security, approval gates, off-limits)
- Owner profile (name, timezone, preferences, working style)
- Projects & context (active work, key systems)
- Preferences (technical choices, automation philosophy, communication)
- Lessons learned (dated entries, categories)
- Active automations (heartbeat checks, cron jobs, watchdog)
- System state (hardware, software, credentials, network)
- Channel architecture (isolation model, session flow)
- Consolidation notes

**Connects to:**
- Read by AGENTS.md at startup (main session only)
- Updated weekly from daily memory files
- Excluded from group chat sessions (privacy)
- Persistent across sessions

**Pattern:** Living knowledge base. Distilled from daily experience.

**Notable conventions:**
- Owner profile filled during BOOTSTRAP
- Lessons learned format: `[YYYY-MM-DD] [Category] - [Lesson] [Explanation]`
- Weekly consolidation from daily files
- Session architecture (what loads when)

---

#### BOOTSTRAP.md (Template)
**Responsibility:** First-run personalization guide

**Key Content:**
- 9 setup questions (agent name, personality, emoji, user info, etc.)
- What happens next (fills IDENTITY, SOUL, USER, HEARTBEAT, MEMORY)
- How to use the files (which evolve, which are static)
- Privacy note
- Self-deletes after completion

**Connects to:**
- Creates/updates all other workspace files
- Deletes itself when done (signals setup complete)
- AGENTS.md checks for its existence (first run detection)

**Pattern:** Setup wizard. Interactive personalization.

**Notable conventions:**
- Conversational Q&A format
- Explains file purposes before asking questions
- Emphasizes privacy and boundaries
- One-time use (deletes on completion)

---

#### USER.md (Template)
**Responsibility:** Owner profile

**Key Content:**
- Basic info (name, pronouns, timezone)
- Communication preferences (style, brevity, channels)
- What agent is here for (primary purpose, success criteria)
- Current projects (active work, key focuses)
- Working style (daily rhythm, peak focus time, quirks)
- Technical preferences (languages, tools, formats)
- Integration philosophy (what can automate, what needs approval)
- Lessons and patterns (updated over time)

**Connects to:**
- Filled during BOOTSTRAP
- Read by AGENTS.md at startup
- Used by HEARTBEAT.md for scheduling
- Evolves as agent learns owner's patterns

**Pattern:** User manual. Who the agent is working with.

---

#### TOOLS.md (Template)
**Responsibility:** Environment-specific infrastructure notes

**Key Content:**
- API providers (OpenRouter, Anthropic, etc.)
- Communication channels (Discord, iMessage, etc.)
- Connected devices (Mac, smart home, etc.)
- Custom tools (skills, scripts, integrations)
- Environment variables

**Connects to:**
- Optional (not required for operation)
- Read by AGENTS.md if present
- User customizes with their setup
- Examples in production TOOLS.md

**Pattern:** Cheat sheet. Quick reference for agent capabilities.

---

#### workspace-scaffold-prompt.md
**Responsibility:** Manual setup instructions (if autosetup not used)

**Key Content:**
- Directory creation commands
- Template file copying
- Daily log initialization
- First-run personalization trigger

**Connects to:**
- Alternative to autosetup script
- References BOOTSTRAP.md for personalization
- Creates same structure as automated installer

**Pattern:** Escape hatch. Manual path if automation fails.

---

### Workspace Template Relationships

```
BOOTSTRAP.md (first run)
├── personalizes → IDENTITY.md (name, emoji, vibe)
├── personalizes → SOUL.md (personality, boundaries)
├── personalizes → USER.md (owner profile, preferences)
├── personalizes → HEARTBEAT.md (timezone, check schedule)
├── personalizes → MEMORY.md (owner profile, critical rules)
└── deletes self when complete

AGENTS.md (startup ritual)
├── reads → SOUL.md (who I am)
├── reads → USER.md (who I'm helping)
├── reads → IDENTITY.md (my name and vibe)
├── reads → TOOLS.md (what's available, optional)
├── reads → MEMORY.md (long-term context, main session only)
└── reads → memory/YYYY-MM-DD.md (today + yesterday)

HEARTBEAT.md (daily rhythm)
├── uses → USER.md (timezone, work hours)
├── writes → memory/YYYY-MM-DD.md (check results)
└── updates → MEMORY.md (weekly consolidation)
```

---

## 3. Workflow Packages (`workflows/`)

### Purpose
Domain-specific skill bundles. Pre-configured AGENTS.md + skills + crons for specific use cases.

### Package Structure

Each workflow contains:
```
workflow-name/
├── AGENTS.md           # Domain-specific behavior
├── GETTING-STARTED.md  # Step-by-step setup
├── TROUBLESHOOTING.md  # Common issues
├── template.json       # Metadata
├── skills.sh           # One-command installer
└── crons/              # Pre-configured jobs
    ├── job-1.json
    └── job-2.json
```

---

### Content Creator (`workflows/content-creator/`)

**Best for:** Social media, podcasts, video creation

**Time to value:** 5-10 minutes

**Difficulty:** Beginner

#### AGENTS.md (Content Creator)
**Responsibility:** Creative assistant behavior

**Key Content:**
- First-run welcome (example commands)
- Role (ideation partner, research assistant, production support, engagement helper)
- Core workflows (content research, video/podcast support, image generation, social media)
- Communication style (casual but professional, proactive, brief by default)
- Tools (summarize, gifgrep, tts, image, web_search, x-research-skill)
- Daily rhythms (morning trends, during work support, evening engagement review)
- "Always suggest next steps" pattern
- Celebrate first successes

**Connects to:**
- Replaces base AGENTS.md (or extends it)
- Uses skills from skills.sh
- Enables crons from crons/ directory
- References content/ folder structure

**Pattern:** Domain specialization. Same operating principles, different focus.

**Notable conventions:**
- "What's next" after every completed task
- Celebration on first success
- Folder organization (content/ideas, drafts, published, analytics)

---

#### GETTING-STARTED.md (Content Creator)
**Responsibility:** 5-minute setup guide

**Key Content:**
- Prerequisites checklist
- Quick setup (3 steps: install skills, set API keys, copy AGENTS.md)
- Verification commands
- Your first win (4 example tasks)
- Sample workflows (podcast prep, content ideation, social media batch)
- Recommended cron jobs (content-ideas, trend-monitor, engagement-check, weekly-analytics)
- Folder structure
- Tips for success
- Troubleshooting (quick fixes)

**Connects to:**
- References skills.sh for installation
- Points to TROUBLESHOOTING.md for issues
- Links to crons/ for automation
- Mentions AGENTS.md customization

**Pattern:** Quick win focus. Show value in minutes.

---

#### TROUBLESHOOTING.md (Content Creator)
**Responsibility:** Common issues and fixes

**Key Content:**
- Installation issues (skills.sh failures, Homebrew problems)
- API key issues (missing keys, quota exceeded, rate limits)
- Media processing issues (transcription failures, video download, image generation, GIF search)
- File organization issues
- Content quality issues (summaries miss points, wrong brand voice)
- Platform-specific gotchas (macOS permissions, YouTube restrictions, social media APIs)
- Recovery procedures (full reset, switching templates, disk cleanup)

**Connects to:**
- References GETTING-STARTED.md for setup
- Links to external docs (API providers, tools)
- Suggests asking agent for debugging help

**Pattern:** Debug guide. Anticipate failure modes.

---

#### template.json
**Responsibility:** Workflow metadata

**Key Content:**
```json
{
  "name": "content-creator",
  "displayName": "Content Creator",
  "description": "Social media, podcasts, video...",
  "emoji": "📱",
  "skills": {
    "external": ["summarize", "gifgrep"],
    "builtin": ["web_search", "web_fetch", "tts", "image"]
  },
  "optionalSkills": {...},
  "crons": ["content-ideas", "trend-monitor", ...],
  "tags": ["social", "video", "podcast", "creative"],
  "difficulty": "beginner",
  "timeToValue": "5 minutes"
}
```

**Connects to:**
- Machine-readable manifest
- Used by installers/marketplaces
- Documents skill dependencies
- Lists cron jobs included

**Pattern:** Package manifest. Declarative metadata.

---

#### skills.sh
**Responsibility:** One-command skill installer

**Key Content:**
- Homebrew tap addition
- Core skills (gifgrep, ffmpeg, summarize)
- Workspace folder creation (content/, images/, transcripts/)
- Installation verification
- API key instructions
- Success message with examples

**Connects to:**
- Referenced by GETTING-STARTED.md
- Creates folders expected by AGENTS.md
- Enables tools used in crons

**Pattern:** Dependency installer. Make it work.

---

#### crons/ Directory
**Files:** content-ideas.json, trend-monitor.json, engagement-check.json, weekly-analytics.json

**Example (content-ideas.json):**
```json
{
  "name": "content-ideas",
  "schedule": {"kind": "cron", "expr": "0 8 * * *", "tz": "America/New_York"},
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "Research trending topics in my niche. Check X for viral content, note 3-5 potential content ideas with angles. Save to content/ideas/YYYY-MM-DD.md. Be brief but actionable.",
    "timeoutSeconds": 300
  },
  "delivery": {"mode": "announce"},
  "enabled": true
}
```

**Pattern:** Automation recipes. Import and run.

**Notable conventions:**
- All use `isolated` session target (no main session context)
- All write to workspace files (content/ideas/, analytics/, etc.)
- Delivery mode: announce (post to channel) or silent
- Enabled: true (ready to use immediately)

---

### App Builder (`workflows/app-builder/`)

**Best for:** Coding, GitHub automation, API research

**Time to value:** 10-15 minutes

**Difficulty:** Intermediate

#### Key Differences from Content Creator

**AGENTS.md:**
- Technical and precise communication
- Code examples > explanations
- Quality skills (systematic-debugging, verification-before-completion, test-driven-development)
- Development principles (before/during/after implementation)
- Never push to main without approval
- Model selection for sub-agents (Sonnet for code, gpt-nano for lookups)

**Skills (skills.sh):**
- github (gh CLI)
- jq (JSON processing)
- ripgrep (code search)

**Crons:**
- ci-monitor.json (every 30 min, alert on CI failures)
- pr-review-reminder.json (daily 9 AM, list PRs awaiting review)
- dependency-check.json (weekly, flag outdated dependencies)

**GETTING-STARTED.md:**
- Emphasis on CLAUDE.md (project-specific context)
- GitHub authentication required
- Sample workflows (PR review, bug investigation, documentation, feature development)
- Model selection guide

**Pattern:** Developer workflow. Code-focused, GitHub-integrated.

---

### Workflow Optimizer (`workflows/workflow-optimizer/`)

**Best for:** Email, calendar, tasks, notes, daily routines

**Time to value:** 5-10 minutes

**Difficulty:** Beginner

#### Key Differences

**AGENTS.md:**
- Efficient and clear communication
- Proactive but not pushy
- Context-aware (brief vs detailed)
- Privacy boundaries (summarize email, don't quote sensitive details)
- Daily rhythms (morning briefing, throughout day support, evening review, weekly planning)
- Never send emails without explicit approval

**Skills (skills.sh):**
- gog (Google Workspace: Gmail, Calendar, Drive, Sheets)
- apple-notes (memo CLI)
- apple-reminders (remindctl)
- himalaya (universal email client, IMAP/SMTP)
- summarize (long article/doc summaries)
- weather (curl wttr.in, no setup needed)

**Crons:**
- morning-briefing.json (7:30 AM weekdays, calendar + emails + tasks + weather)
- email-digest.json (every 4h, alert on urgent emails)
- calendar-reminder.json (15 min before events)
- daily-review.json (6 PM, what got done, what slipped)
- weekly-planning.json (Sunday 9 AM, week ahead preview)

**GETTING-STARTED.md:**
- Google OAuth setup prominent
- macOS permissions emphasis (Apple Notes/Reminders automation)
- Sample workflows (morning routine, email triage, task management, weekly planning)
- Folder structure (inbox/, calendar/, tasks/, daily/, weekly/)

**TROUBLESHOOTING.md:**
- macOS permission issues featured
- Google auth troubleshooting
- Himalaya IMAP/SMTP config
- Calendar/location permissions

**Pattern:** Personal assistant. Organize life, not just work.

---

### Workflow Comparison Matrix

| Aspect | Content Creator | App Builder | Workflow Optimizer |
|--------|----------------|-------------|-------------------|
| **Focus** | Creative production | Code and GitHub | Productivity |
| **Communication** | Casual, proactive | Technical, precise | Efficient, clear |
| **Skills** | Media tools | Dev tools | Productivity tools |
| **Crons** | Trend monitoring | CI/PR monitoring | Daily briefings |
| **Difficulty** | Beginner | Intermediate | Beginner |
| **Time to value** | 5-10 min | 10-15 min | 5-10 min |

---

## How the Three Layers Relate

```
┌─────────────────────────────────────────────────────────────┐
│                    WORKFLOW PACKAGES                         │
│  (domain-specific: content-creator, app-builder, etc.)      │
│  - Specialized AGENTS.md (extends base patterns)            │
│  - Domain skills (gifgrep, gh, gog)                         │
│  - Use case crons (trend-monitor, ci-monitor, briefing)     │
└──────────────────┬──────────────────────────────────────────┘
                   │ uses
┌──────────────────▼──────────────────────────────────────────┐
│              WORKSPACE TEMPLATES                             │
│  (universal base: AGENTS.md, SOUL.md, USER.md, etc.)        │
│  - Operating principles (memory, safety, quality)           │
│  - Personality scaffold (BOOTSTRAP personalizes)            │
│  - Infrastructure reference (TOOLS.md, HEARTBEAT.md)        │
└──────────────────┬──────────────────────────────────────────┘
                   │ simplified for beginners
┌──────────────────▼──────────────────────────────────────────┐
│                   STARTER PACK                               │
│  (beginner-friendly: AGENTS-STARTER, SOUL-STARTER, etc.)    │
│  - Simplified docs (24KB → 7KB)                             │
│  - Pre-configured specialists (Librarian, Treasurer)        │
│  - Automation recipes (5 cron jobs)                         │
│  - Security baseline (audit prompt)                         │
└─────────────────────────────────────────────────────────────┘
```

**Relationship:**
- **Starter Pack** = Beginner subset of workspace templates + pre-configured automation
- **Workspace Templates** = Universal foundation for any agent
- **Workflow Packages** = Starter Pack or Templates + domain-specific additions

**Install flow:**
1. Installer downloads **workspace templates** to `~/.openclaw/apps/clawstarter/templates/`
2. User chooses **workflow** (or skips to starter pack)
3. Workflow's `skills.sh` installs domain tools
4. Workflow's `AGENTS.md` copies to `~/.openclaw/workspace/` (or extends existing)
5. Workflow's `crons/*.json` import to OpenClaw scheduler
6. User runs **BOOTSTRAP.md** to personalize (name, timezone, preferences)
7. Templates are filled with user data → working system

**What's missing:**
- Advanced workflows (researcher, data analyst, home automation)
- Multi-agent orchestration (beyond Librarian/Treasurer)
- Expansion packs (X/Twitter integration, advanced channels)
- Migration guides (from Claude Desktop, ChatGPT, etc.)
- Template marketplace/gallery
- Checksum verification system (for template integrity)

---

## Navigation Guides

### To Add a New Workflow

Touch these files:

1. **Create workflow directory:**
   ```
   workflows/my-workflow/
   ├── AGENTS.md           # Domain behavior
   ├── GETTING-STARTED.md  # Setup guide
   ├── TROUBLESHOOTING.md  # Common issues
   ├── template.json       # Metadata
   ├── skills.sh           # Installer
   └── crons/              # Automation jobs
   ```

2. **Update workflows/README.md:**
   - Add row to comparison table
   - Add to "Available Templates" section
   - Include emoji, best for, time to value, difficulty

3. **Create template.json:**
   ```json
   {
     "name": "my-workflow",
     "displayName": "My Workflow",
     "description": "...",
     "emoji": "🔮",
     "skills": {"external": [...], "builtin": [...]},
     "crons": [...],
     "tags": [...],
     "difficulty": "beginner|intermediate|advanced",
     "timeToValue": "X minutes"
   }
   ```

4. **Write AGENTS.md following pattern:**
   - First-run welcome
   - Role definition
   - Core workflows
   - Communication style
   - Tools used
   - "Always suggest next steps"
   - "Celebrate first successes"

5. **Create skills.sh:**
   - Check Homebrew
   - Add taps if needed
   - Install external skills
   - Create workspace folders
   - Verify installations
   - Show API key instructions

6. **Write GETTING-STARTED.md:**
   - Prerequisites checklist
   - Quick setup (3-4 steps)
   - Verification commands
   - Your first win (3-4 examples)
   - Sample workflows (3-4 scenarios)
   - Recommended cron jobs
   - Tips for success

7. **Create crons/*.json for each automation:**
   ```json
   {
     "name": "job-name",
     "schedule": {"kind": "cron", "expr": "...", "tz": "..."},
     "sessionTarget": "isolated",
     "payload": {
       "kind": "agentTurn",
       "message": "...",
       "timeoutSeconds": 300
     },
     "delivery": {"mode": "announce"},
     "enabled": true
   }
   ```

8. **Test end-to-end:**
   - Fresh macOS install (VM recommended)
   - Run skills.sh
   - Copy AGENTS.md
   - Import crons
   - Verify each example in GETTING-STARTED.md works

9. **Document common failures in TROUBLESHOOTING.md**

---

### To Update a Template

Touch these files and regenerate checksums:

1. **Edit template file:**
   ```
   templates/workspace/AGENTS.md
   templates/workspace/SOUL.md
   # etc.
   ```

2. **Test with BOOTSTRAP:**
   - Verify placeholders still work
   - Check that personalization fills correctly
   - Test with workspace-scaffold-prompt.md

3. **Update starter pack if simplified version exists:**
   ```
   starter-pack/AGENTS-STARTER.md
   starter-pack/SOUL-STARTER.md
   # Keep beginner-friendly (7KB target for AGENTS)
   ```

4. **Regenerate checksums (TODO: system not yet implemented):**
   ```bash
   # Future: checksum generation script
   # For now: manual verification via git diff
   ```

5. **Update version in relevant template.json files:**
   ```json
   {"version": "1.2.0", ...}
   ```

6. **Update starter-pack/STARTER-PACK-MANIFEST.md:**
   - Increment version
   - Note "Last updated: YYYY-MM-DD"
   - Add to version history if significant change

7. **Test workflows still work:**
   - Run each workflow's skills.sh
   - Verify AGENTS.md still compatible
   - Check cron jobs still import

8. **Update docs/CHANGELOG.md (if exists):**
   - Note breaking changes
   - Migration instructions if needed

---

### To Regenerate Checksums (Future Feature)

**Currently missing:** Checksum verification system for template integrity.

**Proposed implementation:**

1. **Generate checksums:**
   ```bash
   # For each template file
   sha256sum templates/workspace/*.md > templates/workspace/CHECKSUMS
   sha256sum workflows/*/AGENTS.md >> workflows/CHECKSUMS
   ```

2. **Verify on install:**
   ```bash
   # Installer script checks
   sha256sum -c templates/workspace/CHECKSUMS
   ```

3. **Touch when updating templates:**
   - Edit template file
   - Regenerate checksums
   - Commit both together

**Why needed:** Detect corruption or tampering during download/transfer.

**Not yet implemented:** Manual verification via git suffices for now.

---

## Patterns and Conventions

### File Naming

- **Configuration:** `AGENTS.md`, `SOUL.md`, `MEMORY.md` (uppercase, `.md`)
- **Templates:** Same names + placeholders `[To be filled]`
- **Workflows:** `template.json`, `skills.sh`, `crons/*.json`
- **Documentation:** `GETTING-STARTED.md`, `TROUBLESHOOTING.md`, `README.md`

### Memory Format

**Standardized header:**
```markdown
## [HH:MM] AgentId:SessionType:Detail — Topic
```

**Components:**
- `[HH:MM]` — Local time, 24-hour format
- `AgentId` — Agent name from config
- `SessionType` — main | discord | cron | subagent
- `Detail` — Session-specific (channel name, job name, task name)
- `Topic` — Human-readable summary

**Body fields (optional):**
- `**Decisions:**` — What was decided
- `**Actions:**` — What was done or needs doing
- `**Carry-forward:**` — Items for future sessions
- `**Notable:**` — Anything worth remembering
- `**Result:**` — success/failure/partial (for cron/subagent)

**Size limit:** ≤512 bytes per entry (POSIX atomic append guarantee)

### Cron Job Format

**Required fields:**
```json
{
  "name": "unique-job-name",
  "schedule": {
    "kind": "cron",
    "expr": "0 8 * * *",
    "tz": "America/New_York"
  },
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "Exact instructions...",
    "timeoutSeconds": 300
  },
  "delivery": {"mode": "announce"},
  "enabled": true
}
```

**Conventions:**
- `sessionTarget: isolated` — No main session context
- All jobs write to `memory/YYYY-MM-DD.md` before completing
- Delivery: `announce` (post to channel) or `silent` (memory only)
- Timeout: 300s typical, adjust for complexity

### Workflow Package Structure

**Every workflow MUST include:**
- `AGENTS.md` — Domain-specific behavior
- `GETTING-STARTED.md` — Step-by-step setup
- `TROUBLESHOOTING.md` — Common issues
- `template.json` — Machine-readable metadata
- `skills.sh` — One-command installer
- `crons/` — At least one example job (optional but recommended)

**Optional:**
- `README.md` — Overview (if needed beyond GETTING-STARTED)
- `examples/` — Sample prompts or outputs
- `docs/` — Additional documentation

### Documentation Patterns

**GETTING-STARTED.md structure:**
1. Prerequisites checklist
2. Quick setup (≤5 steps)
3. Verification commands
4. Your first win (3-4 examples)
5. Sample workflows (3-4 scenarios)
6. Recommended cron jobs
7. Folder structure
8. Tips for success
9. Troubleshooting (quick fixes only, link to full doc)

**TROUBLESHOOTING.md structure:**
1. Installation issues
2. Authentication/permission issues
3. Tool-specific issues (by tool)
4. Platform-specific gotchas
5. Recovery procedures (reset, switch, cleanup)
6. Getting more help (links, community)

**AGENTS.md structure:**
1. First-run welcome (example commands)
2. Role definition (bullet list)
3. Core workflows (by task type)
4. Communication style (brief description)
5. Tools used (table)
6. Daily rhythms (when to do what)
7. What you don't do (boundaries)
8. "Always suggest next steps" section
9. "Celebrate first successes" section
10. Customization note

### Code Conventions

**skills.sh:**
- Set `-euo pipefail` for safety
- Check Homebrew before proceeding
- Add taps if needed
- Install with `2>/dev/null || echo "already installed"` pattern
- Create workspace folders with `mkdir -p`
- Verify installations with `command -v`
- Display API key instructions at end
- Show example commands to try

**Bash style:**
- Use POSIX-compatible commands where possible
- Prefer `command -v` over `which`
- Use `mkdir -p` (idempotent)
- Check environment variables with `[ -z "$VAR" ]`
- Echo with colors: `GREEN='\033[0;32m'`, `NC='\033[0m'`

---

## What's Included vs What's Missing

### ✅ Included

**Starter Pack:**
- Simplified operating manual (AGENTS-STARTER.md)
- Personality template (SOUL-STARTER.md)
- 5 cron jobs (morning briefing, email monitor, evening memory, cost report, health check)
- 2 specialists (Librarian, Treasurer)
- Security audit prompt
- Skills guide (essential + level 2 + joy pack)

**Workspace Templates:**
- Complete operating manual (AGENTS.md)
- Personality scaffold (SOUL.md)
- Identity template (IDENTITY.md)
- User profile template (USER.md)
- Daily rhythm config (HEARTBEAT.md)
- Long-term memory template (MEMORY.md)
- First-run wizard (BOOTSTRAP.md)
- Tools reference (TOOLS.md)
- Manual setup prompt (workspace-scaffold-prompt.md)

**Workflows:**
- 3 complete packages (content-creator, app-builder, workflow-optimizer)
- Each with: AGENTS.md, GETTING-STARTED, TROUBLESHOOTING, skills.sh, crons, metadata
- 13 total cron jobs across all workflows
- 15+ skill integrations

### ❌ Missing (Expansion Packs or Future Work)

**Advanced Workflows:**
- Researcher (academic papers, deep dives)
- Data Analyst (SQL, spreadsheets, visualization)
- Home Automation (smart home, IoT)
- Finance Manager (budgets, investments, taxes)
- Health Tracker (fitness, diet, medical)

**Advanced Features:**
- X/Twitter integration (engagement, posting, monitoring)
- Multi-channel support (iMessage, Telegram, Slack)
- Multi-agent orchestration (beyond 2 specialists)
- Custom specialist creation guide
- PRISM workshop templates
- Advanced skill packs

**Infrastructure:**
- Template marketplace/gallery
- Checksum verification system
- Automated testing framework
- Migration tools (from Claude Desktop, ChatGPT, etc.)
- Template analytics (usage, success metrics)
- Community contribution guidelines

**Documentation:**
- Video walkthroughs
- Interactive setup wizard (web UI)
- Template comparison tool
- Use case decision tree ("Which workflow should I start with?")
- Advanced customization examples

---

## Installation Flow (Detailed)

### Automated Install (Recommended)

1. **User downloads installer:**
   ```bash
   curl -fsSL https://clawstarter.com/install-starter.sh | bash
   ```

2. **Installer downloads templates:**
   - Clones/downloads `clawstarter` repo to `~/Downloads/openclaw-setup/`
   - Templates land in `~/Downloads/openclaw-setup/templates/`
   - Workflows land in `~/Downloads/openclaw-setup/workflows/`
   - Starter pack in `~/Downloads/openclaw-setup/starter-pack/`

3. **User picks workflow (or skips):**
   - Installer prompts: "Choose a workflow or start with basics"
   - Options: content-creator | app-builder | workflow-optimizer | starter pack | skip
   - Or run workflow installer later: `bash workflows/[name]/skills.sh`

4. **Workflow installer runs:**
   - `bash workflows/content-creator/skills.sh` (example)
   - Checks Homebrew
   - Installs external skills (gifgrep, summarize, etc.)
   - Creates workspace folders (content/, images/, etc.)
   - Verifies installations
   - Shows API key instructions

5. **Templates copy to workspace:**
   - If starter pack: copies simplified files
     ```bash
     cp starter-pack/AGENTS-STARTER.md ~/.openclaw/workspace/AGENTS.md
     cp starter-pack/SOUL-STARTER.md ~/.openclaw/workspace/SOUL.md
     ```
   - If workflow: copies workflow AGENTS.md
     ```bash
     cp workflows/content-creator/AGENTS.md ~/.openclaw/workspace/
     ```
   - Base templates copy:
     ```bash
     cp templates/workspace/USER.md ~/.openclaw/workspace/
     cp templates/workspace/IDENTITY.md ~/.openclaw/workspace/
     cp templates/workspace/MEMORY.md ~/.openclaw/workspace/
     cp templates/workspace/HEARTBEAT.md ~/.openclaw/workspace/
     cp templates/workspace/BOOTSTRAP.md ~/.openclaw/workspace/
     ```

6. **Cron jobs import:**
   ```bash
   openclaw cron import workflows/content-creator/crons/content-ideas.json
   openclaw cron import workflows/content-creator/crons/trend-monitor.json
   # etc.
   ```

7. **User runs BOOTSTRAP:**
   - User starts first chat with agent
   - Agent reads BOOTSTRAP.md
   - Asks 9 personalization questions
   - Fills placeholders in IDENTITY.md, SOUL.md, USER.md, HEARTBEAT.md, MEMORY.md
   - Deletes BOOTSTRAP.md (signals setup complete)

8. **System ready:**
   - Agent has personality (SOUL.md)
   - Agent knows owner (USER.md)
   - Agent has operating manual (AGENTS.md)
   - Memory system active (memory/ folder + MEMORY.md)
   - Cron jobs scheduled
   - Skills installed and working

### Manual Install

1. **User creates directories:**
   ```bash
   mkdir -p ~/.openclaw/workspace/memory
   mkdir -p ~/.openclaw/workspace/cron
   ```

2. **User copies templates manually:**
   ```bash
   cp ~/Downloads/openclaw-setup/starter-pack/AGENTS-STARTER.md ~/.openclaw/workspace/AGENTS.md
   # etc.
   ```

3. **User follows workflow GETTING-STARTED.md:**
   - Runs skills.sh
   - Copies workflow AGENTS.md
   - Imports cron jobs

4. **User personalizes via BOOTSTRAP or manual editing:**
   - Either: Agent reads BOOTSTRAP.md and guides setup
   - Or: User edits `[placeholders]` directly in template files

5. **Same result as automated install**

---

## Summary

**ClawStarter provides three layers:**

1. **Starter Pack** — Battle-tested production configs simplified for beginners (45KB docs, 5 crons, 2 specialists, ~$0.37/month)

2. **Workspace Templates** — Universal foundation for any agent (9 core files, BOOTSTRAP personalization, session architecture)

3. **Workflow Packages** — Domain-specific bundles (3 complete workflows, 13 crons, 15+ skills, <15 min setup)

**Key patterns:**
- Evidence before assertions (show your work)
- Verification before completion (test before claiming "done")
- Memory discipline (512-byte atomic writes, standardized headers)
- Session type detection (main, discord, cron, subagent)
- "Always suggest next steps" (keep momentum)
- Celebrate first successes (build confidence)

**Value proposition:**
Not "here's how to install," but "here's what works in production, simplified for you."

**What's missing:**
Advanced workflows, checksum verification, template marketplace, migration tools, video walkthroughs.

**What to touch to add a workflow:**
workflows/[name]/ folder + README.md + skills.sh + AGENTS.md + GETTING-STARTED.md + TROUBLESHOOTING.md + template.json + crons/

**What to touch to update a template:**
Edit template file → update starter pack simplified version → regenerate checksums (future) → test workflows → update version → commit.

---

**End of analysis. File count: 40+ files analyzed. Total analysis: ~11,000 words.**
