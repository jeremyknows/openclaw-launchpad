# Getting Started: Workflow Optimizer

Welcome! This template turns your AI agent into a personal productivity assistant. Let's get you organized in 5 minutes.

## Quick Setup (3 minutes)

### 1. Install Skills
```bash
bash ~/Downloads/openclaw-setup/workflows/workflow-optimizer/skills.sh
```

### 2. Grant macOS Permissions
When prompted, allow automation access for:
- Apple Notes
- Apple Reminders
- Messages (if using iMessage)

### 3. Connect Google Workspace
```bash
gog auth login
# Opens browser for OAuth
```

### 4. Copy Agent Instructions
```bash
cp ~/Downloads/openclaw-setup/workflows/workflow-optimizer/AGENTS.md ~/.openclaw/workspace/
```

## Your First Win (2 minutes)

Try these to see immediate value:

### Check Your Day
> "What's on my calendar today and what's the weather like?"

### Quick Capture
> "Add a reminder: Review quarterly report by Friday 5pm"

### Email Overview
> "Show me unread emails from this week, prioritized by importance"

### Take a Note
> "Create a note in my Work folder: Meeting with Sarah - discussed Q2 budget, action items: send proposal by Wednesday"

## Sample Workflows

### Morning Routine
1. "Good morning! Give me my daily briefing."
   - Calendar events
   - Priority emails
   - Due tasks
   - Weather

### Email Triage
1. "Show me emails from VIPs in the last 24 hours"
2. "Summarize the long thread from marketing"
3. "Draft a reply to John's request"

### Task Management
1. "What's overdue on my todo list?"
2. "Move the project deadline to next Friday"
3. "Add a reminder to follow up on this in 3 days"

### Weekly Planning
1. "Show me next week's calendar"
2. "What recurring meetings could I decline?"
3. "Block 2 hours of focus time on Tuesday afternoon"

## Recommended Cron Jobs

These automations run in the background:

| Job | Frequency | Purpose |
|-----|-----------|---------|
| morning-briefing | Daily 7:30 AM | Calendar + emails + tasks + weather |
| email-digest | Every 4h | Alert on urgent emails |
| calendar-reminder | 15 min before events | Upcoming meeting heads-up |
| daily-review | Daily 6 PM | What got done, what slipped |
| weekly-planning | Sunday 9 AM | Week ahead preview |

Enable them:
```bash
openclaw cron import ~/Downloads/openclaw-setup/workflows/workflow-optimizer/crons/
```

## Folder Structure

Create these for organization:
```
~/.openclaw/workspace/
├── inbox/           # Email processing notes
├── calendar/        # Meeting notes and prep
├── tasks/           # Task tracking
├── daily/           # Morning/evening logs
└── weekly/          # Weekly reviews
```

## Tips for Success

### Define Your VIPs
Tell your agent who matters most:
> "My VIPs are: [boss name], [partner name], [key client]. Always surface their messages first."

### Set Boundaries
> "Don't message me about non-urgent things between 9 PM and 7 AM"

### Use Natural Language
> "Remind me about the dentist next Tuesday around 2"
> "What did Sarah email me about last week?"

### Let It Draft, You Send
Always review email drafts before sending. Your agent suggests, you decide.

## Common Integrations

### Google Calendar Colors
Tell your agent what colors mean:
> "Red = external meetings, Blue = internal, Green = personal"

### Email Folders
> "Archive newsletters to 'Read Later', flag anything from legal"

### Reminder Lists
> "Use 'Work' for professional tasks, 'Home' for personal"

## Troubleshooting

### "Permission denied" for Notes/Reminders
System Settings → Privacy & Security → Automation → Allow for Terminal

### Google auth not working
```bash
gog auth logout
gog auth login
```

### Email not connecting
Check ~/.config/himalaya/config.toml has correct IMAP/SMTP settings

## Next Steps

1. ✅ Complete the first win exercise above
2. 🔗 Connect your Google account
3. 📝 Define your VIPs and preferences in AGENTS.md
4. ⏰ Enable morning briefing cron
5. 📊 Try a full day with your new assistant

---

*Questions? Ask your agent: "Help me set up my workflow optimizer"*
