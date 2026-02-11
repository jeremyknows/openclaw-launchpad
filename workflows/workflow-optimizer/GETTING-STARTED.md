# Getting Started: Workflow Optimizer

Welcome! This template turns your AI agent into a personal productivity assistant. Let's get you organized in 5 minutes.

## Prerequisites

Before you start, make sure you have:
- ✅ **macOS** (these templates are Mac-specific)
- ✅ **Homebrew** installed ([get it here](https://brew.sh) if not)
- ✅ **OpenClaw** running (gateway started)
- ✅ **Google account** (for Calendar/Gmail features)
- ✅ **Basic terminal comfort** (copy/paste commands)

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

## ✅ Verify Your Setup

Run these commands to confirm everything works:

```bash
# 1. Check skills installed
which memo && echo "✅ Apple Notes ready"
which remindctl && echo "✅ Apple Reminders ready"
which gog && echo "✅ Google Workspace ready"

# 2. Check Google auth
gog auth status 2>/dev/null && echo "✅ Google authenticated" || echo "⚠️ Run: gog auth login"

# 3. Check workspace folders
ls ~/.openclaw/workspace/daily/ && echo "✅ Folders created"
```

**What success looks like:**
```
✅ Apple Notes ready
✅ Apple Reminders ready
✅ Google Workspace ready
✅ Google authenticated
✅ Folders created
```

**If macOS permission dialogs appear:**
- Click "Allow" when prompted for Automation access
- If you clicked "Deny": System Settings → Privacy & Security → Automation → enable Terminal

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

**To enable them**, ask your agent:
> "Set up the morning-briefing cron job from ~/Downloads/openclaw-setup/workflows/workflow-optimizer/crons/morning-briefing.json"

Or add manually via CLI:
```bash
openclaw cron add --name "morning-briefing" \
  --cron "30 7 * * 1-5" --tz "America/New_York" \
  --session isolated --announce \
  --message "Generate my morning briefing: calendar, priority emails, due tasks, weather."
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

### ❌ "Permission denied" for Apple Notes or Reminders

**Problem:** macOS hasn't granted automation access

**Fix:**
1. Open **System Settings** → **Privacy & Security** → **Automation**
2. Find **Terminal** in the list
3. Enable checkboxes for:
   - Notes
   - Reminders
   - Calendar (if using)
4. Restart Terminal
5. Try the command again

**Still blocked?** Try running from Terminal.app (not iTerm or other terminals) first.

---

### ❌ Google auth fails or keeps asking for login

**Problem:** OAuth credentials expired or browser blocking popup

**Fix:**
```bash
# Clear existing auth
gog auth logout

# Try fresh login
gog auth login

# If browser doesn't open automatically:
# 1. Copy the URL shown in terminal
# 2. Paste into browser manually
# 3. Complete OAuth flow
# 4. Copy verification code back to terminal
```

**Browser blocking?** Check browser popup blocker settings.

---

### ❌ "Command not found: memo" or other tools

**Problem:** Skills not in PATH or installation failed

**Fix:**
```bash
# Check if Homebrew path is in your shell
echo $PATH | grep homebrew

# If missing, add to ~/.zshrc:
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# Re-install skills
bash ~/Downloads/openclaw-setup/workflows/workflow-optimizer/skills.sh
```

---

### ❌ Email not connecting via Himalaya

**Problem:** IMAP/SMTP config incorrect or app-specific password needed

**Fix:**
```bash
# Check config exists
cat ~/.config/himalaya/config.toml

# For Gmail, you need an app-specific password:
# 1. Google Account → Security → 2-Step Verification
# 2. App passwords → Generate new
# 3. Use generated password in config, not your regular password

# Test connection
himalaya accounts sync
```

---

### ❌ Calendar shows no events (but they exist)

**Problem:** Wrong calendar selected or permissions issue

**Fix:**
```bash
# List available calendars
gog calendar list

# Check permissions
# System Settings → Privacy & Security → Calendars
# Ensure Terminal or your app has access

# Specify calendar by name
gog calendar list --calendar "Work" 
```

---

### ❌ Morning briefing cron doesn't run

**Problem:** Cron not enabled or OpenClaw gateway not running

**Fix:**
```bash
# Check gateway status
openclaw gateway status

# If not running:
openclaw gateway start

# List cron jobs
openclaw cron list

# Enable specific job
openclaw cron update <job-id> --enabled true

# Test manually
openclaw cron run <job-id>
```

---

### ❌ Weather data not showing

**Problem:** Location not set or API issue

**Fix:**
- Ensure Location Services enabled: System Settings → Privacy & Security → Location Services
- Try specifying location explicitly: *"What's the weather in San Francisco?"*
- Check if weather API key needed (some providers require registration)

---

### Need More Help?

- **Template-specific issues:** See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- **Google Workspace auth:** https://github.com/prasmussen/google-oauth-go
- **Himalaya email client:** https://github.com/soywod/himalaya
- **macOS automation permissions:** https://support.apple.com/guide/mac-help/
- **Ask your agent:** *"Debug this error: [paste error message]"*

---

## Next Steps

1. ✅ Complete the first win exercise above
2. 🔗 Connect your Google account
3. 📝 Define your VIPs and preferences in AGENTS.md
4. ⏰ Enable morning briefing cron
5. 📊 Try a full day with your new assistant

---

*Questions? Ask your agent: "Help me set up my workflow optimizer"*
