# ClawStarter Starter Pack — Manifest

**Version:** 1.0 (February 2026)  
**Philosophy:** "We've been running this in production. Here's everything we learned, packaged for you."

---

## 📦 What's Included

The starter pack gives you a **battle-tested OpenClaw setup** based on our production environment, simplified for beginners.

### Core Operating System
- **AGENTS-STARTER.md** (~7KB) — How your agent operates (memory, quality, safety)
- **SOUL-STARTER.md** (~4KB) — Your agent's personality and voice
- **USER.md template** — About you (for your agent to learn from)
- **Memory system** — Daily files + long-term memory protocol

### Pre-Configured Agents
- **Librarian** — Memory curator (keeps your notes organized)
- **Treasurer** — Cost tracker (weekly spend reports)

### Automation (Cron Jobs)
- **Morning briefing** — Calendar + email check (8 AM weekdays)
- **Email monitor** — Urgent email alerts (every 30 min, 6 AM - 8 PM)
- **Evening memory** — Daily review and organization (9 PM)
- **Weekly cost report** — Budget tracking (Fridays 5 PM)
- **Memory health check** — File organization (Sundays 8 PM)

### Security Baseline
- **Security audit prompt** — Have your agent review your setup
- **Privacy guidelines** — What to share, what to protect
- **Safe defaults** — Pre-configured for shared computer safety

### Skills (5 Essential)
- **PRISM** — Multi-perspective review protocol (catch blind spots before they become bugs)
- **systematic-debugging** — Methodical troubleshooting (don't guess, investigate)
- **verification-before-completion** — Test your work before claiming it's done
- **receiving-feedback** — Anti-sycophancy framework (evaluate feedback critically)
- **markdown-fetch** — 80% token savings on web content (via markdown.new)

---

## 🎯 Value Proposition

**NOT:** "Installing OpenClaw is hard, this makes it easy"  
**YES:** "We've been running OpenClaw for months. Here's our playbook."

**What you get:**
- ✅ Memory system that actually works (we learned the hard way)
- ✅ Specialists that save you time (Librarian, Treasurer)
- ✅ Cron jobs we use daily (proven useful, not theoretical)
- ✅ Security patterns we wish we'd known earlier
- ✅ Quality standards from production experience

---

## 📁 File Structure

```
~/.openclaw/workspace/
├── AGENTS.md              ← Simplified operating manual (~7KB)
├── SOUL.md                ← Personality template (~4KB)
├── USER.md                ← About you (you fill this in)
├── MEMORY.md              ← Long-term memory (starts empty)
├── memory/
│   └── YYYY-MM-DD.md      ← Daily files (auto-created)
├── scripts/
│   ├── memory-append.sh   ← Safe concurrent writing
│   └── treasurer          ← Cost tracking CLI
└── cron/
    └── [5 pre-configured jobs]

~/.openclaw/skills/
├── prism/                 ← Multi-perspective review (5+ agents audit your work)
├── systematic-debugging/  ← Methodical troubleshooting protocol
├── verification-before-completion/ ← Test before claiming done
├── receiving-feedback/    ← Anti-sycophancy (evaluate, don't just accept)
└── markdown-fetch/        ← 80% token savings on web fetches

~/.openclaw/workspace-librarian/
├── AGENTS.md              ← Librarian's operating manual
├── SOUL.md                ← Librarian personality
├── IDENTITY.md            ← Name, emoji, role
└── TOOLS.md               ← Librarian-specific tools

~/.openclaw/workspace-treasurer/
├── AGENTS.md              ← Treasurer's operating manual
├── SOUL.md                ← Treasurer personality
├── IDENTITY.md            ← Name, emoji, role
└── TOOLS.md               ← Treasurer-specific tools
```

---

## 🚀 Installation

### Prerequisites

- OpenClaw installed and configured
- Anthropic API key (set up during OpenClaw install)
- Discord bot (optional but recommended for specialists)

### Installation Steps

**Option A: Automated (Recommended)**

```bash
# Download and run the starter pack installer
curl -fsSL https://clawstarter.com/install-starter.sh | bash
```

**The installer will:**
1. Copy template files to your workspace
2. Create memory directory structure
3. Deploy 5 cron jobs
4. Configure Librarian + Treasurer (if Discord token provided)
5. Run initial setup prompts
6. Generate your first memory file

**Option B: Manual Installation**

```bash
# 1. Copy core files
cp starter-pack/AGENTS-STARTER.md ~/.openclaw/workspace/AGENTS.md
cp starter-pack/SOUL-STARTER.md ~/.openclaw/workspace/SOUL.md
cp starter-pack/USER-TEMPLATE.md ~/.openclaw/workspace/USER.md

# 2. Create memory directory
mkdir -p ~/.openclaw/workspace/memory

# 3. Copy utility scripts
cp starter-pack/scripts/* ~/.openclaw/scripts/
chmod +x ~/.openclaw/scripts/*

# 4. Deploy cron jobs
openclaw cron import starter-pack/cron/morning-briefing.json
openclaw cron import starter-pack/cron/email-monitor.json
openclaw cron import starter-pack/cron/evening-memory.json
openclaw cron import starter-pack/cron/weekly-cost-report.json
openclaw cron import starter-pack/cron/memory-health-check.json

# 5. Set up specialists (optional)
bash starter-pack/install-specialists.sh
```

### Post-Installation

**1. Customize USER.md**
Tell your agent about yourself:
- Your name and role
- Current projects
- Communication preferences
- What you want help with

**2. First Conversation**
Start a session with your agent:
```
Hi! This is our first session together. Let's get to know each other.
```

Your agent will:
- Read its configuration files
- Ask clarifying questions about you
- Write initial memory entries
- Explain how it works

**3. Test the Cron Jobs**
```bash
# List installed jobs
openclaw cron list

# Test morning briefing (dry run)
openclaw cron run morning-briefing

# View cron logs
tail -f ~/.openclaw/logs/cron-*.log
```

**4. Set Up Discord (Optional)**
If you want Librarian and Treasurer:
1. Create Discord server or use existing
2. Create channels: `#memory-lab`, `#treasurer`
3. Follow Discord bot setup in `docs/discord-setup.md`

---

## 🔧 Configuration

### Minimal Setup (Works Out of Box)
- Main agent only
- Morning briefing (cron)
- Evening memory (cron)
- Basic memory system

**Perfect for:** Single-user, terminal-only usage

### Standard Setup (Recommended)
- Main agent + Discord
- Librarian (memory curation)
- Treasurer (cost tracking)
- All 5 cron jobs
- Full memory system

**Perfect for:** Power users, multi-channel workflows

### Advanced Setup (Not Included — Expansion Packs)
- X/Twitter integration
- Multiple Discord servers
- iMessage/Telegram
- Custom specialists
- Skill packs

**Add via:** ClawStarter expansion packs (installed separately)

---

## 📊 Cron Job Details

### 1. Morning Briefing
- **Schedule:** 8:00 AM, Monday-Friday
- **Model:** gemini-lite ($0.001/run)
- **Runs:** ~22 times/month
- **Cost:** ~$0.02/month
- **What it does:**
  - Checks calendar for today's events
  - Scans inbox for urgent emails
  - Posts summary to Discord or terminal

**Prompt:**
```
Morning briefing time. Check:
1. Calendar events for next 24 hours
2. Unread emails in inbox (urgent only)
3. Weather for today

Post concise summary to Discord #general or log to memory/YYYY-MM-DD.md.
Format: Bullets, priorities first, <10 lines.
```

---

### 2. Email Monitor
- **Schedule:** Every 30 minutes, 6 AM - 8 PM
- **Model:** gpt-nano ($0.0001/run)
- **Runs:** ~28 times/day = ~840/month
- **Cost:** ~$0.08/month
- **What it does:**
  - Checks for new important emails
  - Alerts if anything urgent arrives
  - Stays quiet if inbox is calm

**Prompt:**
```
Quick email check. Look for:
- Unread emails from VIPs (boss, clients, family)
- Subject lines with urgent keywords (URGENT, ASAP, IMPORTANT)
- Meeting invites needing response

If urgent: Alert to Discord. If quiet: HEARTBEAT_OK (no message).
```

---

### 3. Evening Memory
- **Schedule:** 9:00 PM daily
- **Model:** haiku ($0.003/run)
- **Runs:** ~30 times/month
- **Cost:** ~$0.09/month
- **What it does:**
  - Reviews today's memory file
  - Summarizes key events
  - Updates long-term memory if needed
  - Prepares carry-forward items

**Prompt:**
```
Evening memory review:
1. Read memory/YYYY-MM-DD.md (today's file)
2. Identify: decisions made, promises to keep, important context
3. Update MEMORY.md if anything significant happened
4. Note carry-forward items for tomorrow

Write summary to today's memory file under "## [21:00] Evening Review"
```

---

### 4. Weekly Cost Report (Treasurer)
- **Schedule:** 5:00 PM every Friday
- **Model:** gemini-lite ($0.002/run)
- **Runs:** ~4 times/month
- **Cost:** ~$0.01/month
- **What it does:**
  - Runs Treasurer CLI for spend data
  - Compares to previous week
  - Identifies top spending sessions
  - Posts formatted report to Discord #treasurer

**Prompt:**
```
Generate weekly cost report:
1. Run: treasurer status (get weekly totals)
2. Run: treasurer sessions --period week (top spenders)
3. Compare to last week's numbers
4. Format report (see template in TOOLS.md)
5. Post to Discord #treasurer

Include: Total spend, top 3 sessions, week-over-week change, notable events.
```

---

### 5. Memory Health Check (Librarian)
- **Schedule:** 8:00 PM every Sunday
- **Model:** haiku ($0.003/run)
- **Runs:** ~4 times/month
- **Cost:** ~$0.01/month
- **What it does:**
  - Scans memory files for duplication
  - Checks for contradictions
  - Identifies stale entries
  - Posts health report to Discord #memory-lab

**Prompt:**
```
Weekly memory health check:
1. Scan all memory/YYYY-MM-DD.md files from past week
2. Check for: duplicate entries, contradictions, stale info
3. Verify MEMORY.md is up to date
4. Note any cleanup needed

Post summary to Discord #memory-lab. Include file count, health status, action items.
```

---

## 💰 Total Operating Cost

**Cron jobs:** ~$0.21/month  
**Specialists (Librarian + Treasurer):** ~$0.30/month  
**Actual usage (your conversations):** Variable (depends on usage)

**Estimated starter pack overhead:** < $1/month

**Note:** Your actual AI usage (conversations, tasks) will be additional. The starter pack adds minimal cost.

---

## 🛡️ Security Features

### Included Protections

1. **Private data boundaries**
   - MEMORY.md never loaded in group chats
   - Personal info stays in private sessions
   - Pre-configured privacy rules

2. **Safe defaults**
   - Ask before external actions (emails, tweets)
   - Ask before destructive operations
   - Trash instead of delete

3. **Credential handling**
   - Never write API keys to files
   - Use environment variables or 1Password
   - Audit prompts for exposed secrets

4. **Audit checklist**
   - Weekly security review prompt
   - Configuration validation
   - Permission verification

---

## 📚 Documentation Included

- **AGENTS-STARTER.md** — Operating manual (how your agent works)
- **SOUL-STARTER.md** — Personality guide (who your agent is)
- **SECURITY-CHECKLIST.md** — Audit your setup
- **CRON-GUIDE.md** — Understanding and modifying automation
- **MEMORY-GUIDE.md** — Deep dive on memory system
- **TROUBLESHOOTING.md** — Common issues and fixes

---

## 🎓 Learning Path

**Week 1: Basics**
- Understand memory files
- Watch cron jobs run
- Customize USER.md
- First conversations

**Week 2: Specialists**
- Enable Librarian
- Enable Treasurer
- Set up Discord channels
- Review first reports

**Week 3: Customization**
- Adjust cron schedules
- Modify prompts
- Add personal preferences
- Tune agent personality

**Month 2+: Expansion**
- Add X/Twitter (expansion pack)
- Build custom specialists
- Create domain-specific workflows
- Join community, share learnings

---

## ⚙️ What's NOT Included (Available as Expansion Packs)

- **X/Twitter Integration** — Engagement, posting, monitoring
- **Advanced Channel Setup** — iMessage, Telegram, Slack
- **Skill Packs** — Content creator, app builder, researcher
- **Custom Specialists** — Domain-specific agents beyond Librarian/Treasurer
- **Multi-Agent Orchestration** — Complex task delegation

**Why separate?** Starter pack = battle-tested essentials. Expansion packs = advanced features that not everyone needs.

---

## 🆘 Support & Community

**Stuck?** Use the security audit prompt:
```
Run a security audit of my OpenClaw setup. Check:
1. Are memory files being created?
2. Are cron jobs running successfully?
3. Are credentials stored safely?
4. Are privacy boundaries configured correctly?

Provide checklist with ✅/❌ for each item.
```

**Still stuck?** 
- Check `docs/TROUBLESHOOTING.md`
- Join Discord community (link in installer)
- Open GitHub issue (include error logs)

---

## 🔄 Updates

**This starter pack is living documentation.**

As we learn from production:
- New patterns added
- Bad patterns removed
- Cron prompts improved
- Security enhanced

**Check for updates:** `openclaw starter update`

---

## 📜 License

MIT License — Use freely, modify as needed, share what you learn.

---

**This is your foundation. Start here. Grow from here. Make it yours.**

*Last updated: 2026-02-15 | Version 1.0*
