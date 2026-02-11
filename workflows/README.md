# OpenClaw Workflow Templates

Pre-configured packages for common use cases. Start productive in minutes, not hours.

---

## 🎯 Choose Your Path

### Three Onboarding Styles

**⚡ Fast Track (Developers)**
Already comfortable with CLI tools? Pick a template, run `skills.sh`, start working.
```bash
bash workflows/app-builder/skills.sh
cp workflows/app-builder/AGENTS.md ~/.openclaw/workspace/
# You're ready
```

**📋 Guided Path (New to AI Agents)**
Follow the GETTING-STARTED.md step-by-step. Each template includes:
- Prerequisites checklist
- 3-step setup
- Verification commands
- "Your First Win" exercises

**🔄 Migration Path (Switching from Another Tool)**
Coming from Claude Desktop, ChatGPT, or another assistant? Start with workflow-optimizer to see how OpenClaw handles your existing workflows differently.

---

## 📦 Available Templates

| Template | Best For | Time to Value | Difficulty |
|----------|----------|---------------|------------|
| 📱 [content-creator](./content-creator/) | Social media, podcasts, video | 5-10 min | Beginner |
| 📅 [workflow-optimizer](./workflow-optimizer/) | Email, calendar, tasks, notes | 10-15 min | Beginner |
| 🛠️ [app-builder](./app-builder/) | Coding, GitHub, APIs | 10-15 min | Intermediate |

### What's Included

Each template is a complete package:

```
template-name/
├── AGENTS.md           # Agent behavior instructions
├── GETTING-STARTED.md  # Step-by-step setup guide
├── TROUBLESHOOTING.md  # Common issues & solutions
├── skills.sh           # One-command skill installer
├── template.json       # Metadata
└── crons/              # Pre-configured automation jobs
    ├── job-1.json
    └── job-2.json
```

---

## 🚀 Quick Install

### Option 1: Via Quickstart Script
The main quickstart script offers template installation after initial setup.

### Option 2: Manual Installation

```bash
# 1. Pick your template
cd ~/Downloads/openclaw-setup/workflows/content-creator

# 2. Install skills
bash skills.sh

# 3. Copy agent instructions
cp AGENTS.md ~/.openclaw/workspace/

# 4. Read the getting started guide
cat GETTING-STARTED.md
```

---

## 🔄 Switching Templates

Want to try a different template? Templates are additive, not exclusive.

**To reset completely:**
```bash
# 1. Back up current AGENTS.md
mv ~/.openclaw/workspace/AGENTS.md ~/.openclaw/workspace/AGENTS.md.backup

# 2. Copy new template
cp workflows/new-template/AGENTS.md ~/.openclaw/workspace/

# 3. Install new skills (safe to re-run)
bash workflows/new-template/skills.sh
```

**To combine templates:**
Merge the AGENTS.md files manually, keeping sections from both.

---

## 📝 Customization Guide

Templates are starting points. Make them yours:

### 1. Personalize AGENTS.md
Edit the personality, add your preferences:
```markdown
## Communication Style
- Be brief — I prefer bullet points
- Use humor when appropriate
- My timezone is Pacific, not Eastern
```

### 2. Add Your VIPs
Tell your agent who matters most:
```markdown
## Priority Contacts
- Boss: [name] — always flag their messages
- Partner: [name] — can interrupt focus time
```

### 3. Tune Cron Schedules
Adjust times to match your routine:
```bash
# Change morning briefing from 7:30 to 8:00
openclaw cron edit morning-briefing --cron "0 8 * * 1-5"
```

---

## 🆘 Getting Help

Each template includes a TROUBLESHOOTING.md with common issues.

**General resources:**
- **Ask your agent:** "Help me set up [template name]"
- **OpenClaw docs:** https://docs.openclaw.ai
- **Community:** https://discord.com/invite/clawd

---

## 🤝 Contributing

Have a workflow that others would find useful? Templates are community contributions!

1. Fork the repo
2. Create a new folder in `workflows/`
3. Follow the structure above
4. Submit a PR

Good templates are:
- Focused on a specific use case
- Tested end-to-end
- Documented clearly
- Include troubleshooting

---

*Templates are inspired by patterns from LangChain, AutoGPT, and Claude Code.*
*See RESEARCH-COMPETITORS.md for the design research behind these templates.*
