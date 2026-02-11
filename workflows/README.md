# OpenClaw Workflow Templates

Pre-configured packages for common use cases. Each template includes:

- **AGENTS.md** — Agent instructions optimized for the workflow
- **skills.sh** — One-command skill installation
- **crons/** — Ready-to-use automation jobs
- **GETTING-STARTED.md** — 5-minute guide to your first win

## Available Templates

| Template | Best For | Skills | Automations |
|----------|----------|--------|-------------|
| 📱 [content-creator](./content-creator/) | Social media, podcasts, video | 8 skills | 4 crons |
| 📅 [workflow-optimizer](./workflow-optimizer/) | Email, calendar, tasks | 7 skills | 5 crons |
| 🛠️ [app-builder](./app-builder/) | Coding, GitHub, APIs | 6 skills | 3 crons |

## Installation

### Via Quickstart Script
The quickstart script automatically offers template installation based on your use case selection.

### Manual Installation
```bash
# 1. Navigate to template
cd ~/.openclaw/workspace

# 2. Copy template files
cp ~/Downloads/openclaw-setup/workflows/content-creator/AGENTS.md ./

# 3. Install skills
bash ~/Downloads/openclaw-setup/workflows/content-creator/skills.sh

# 4. Import cron jobs (optional)
openclaw cron import ~/Downloads/openclaw-setup/workflows/content-creator/crons/
```

## Customization

Templates are starting points, not destinations. After installation:

1. Edit `AGENTS.md` to match your voice and preferences
2. Disable crons you don't need: `openclaw cron update <id> --enabled false`
3. Add skills from the [Skills Starter Pack](../SKILLS-STARTER-PACK.md)

---

*Templates are community contributions. Submit yours via PR!*
