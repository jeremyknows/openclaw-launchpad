# Troubleshooting: Workflow Optimizer Template

Common issues and solutions for the Workflow Optimizer workflow.

---

## macOS Permission Issues

### "Apple Notes/Reminders not responding"
**Problem:** macOS Automation permissions not granted.

**Solution:**
1. Go to **System Settings → Privacy & Security → Automation**
2. Find **Terminal** (or your terminal app)
3. Enable access for **Notes**, **Reminders**, and **Calendar**

If the toggle doesn't appear:
```bash
# Trigger the permission prompt
memo list
remindctl list
```

---

### "Permission denied" after granting access
**Problem:** Terminal needs restart after permission change.

**Solution:**
1. Quit Terminal completely (Cmd+Q)
2. Reopen Terminal
3. Try the command again

---

## Google Workspace Issues

### "gog auth login opens browser but nothing happens"
**Problem:** OAuth callback not completing.

**Solution:**
1. Make sure you complete the Google sign-in in the browser
2. Allow all requested permissions
3. If it times out, try again with:
   ```bash
   gog auth logout
   gog auth login
   ```

---

### "Calendar shows no events but I have meetings"
**Problem:** Wrong calendar selected or API quota exceeded.

**Solution:**
1. Check which calendars are visible:
   ```bash
   gog calendar list --all-calendars
   ```
2. If using Google Workspace (not personal Gmail), ensure the calendar is shared with your account

---

### "Email commands fail with auth error"
**Problem:** OAuth token expired.

**Solution:**
```bash
gog auth logout
gog auth login
```

---

## Email (Himalaya) Issues

### "himalaya: No accounts configured"
**Problem:** Email not set up yet.

**Solution:**
Create `~/.config/himalaya/config.toml`:
```toml
[accounts.main]
default = true
email = "you@gmail.com"

[accounts.main.imap]
host = "imap.gmail.com"
port = 993
login = "you@gmail.com"
# Use App Password, not regular password
passwd = { cmd = "echo 'your-app-password'" }

[accounts.main.smtp]
host = "smtp.gmail.com"
port = 465
login = "you@gmail.com"
passwd = { cmd = "echo 'your-app-password'" }
```

For Gmail, you need an [App Password](https://support.google.com/accounts/answer/185833).

---

### "IMAP connection refused"
**Problem:** Firewall or wrong server settings.

**Solution:**
- Verify IMAP is enabled in your email settings
- Check server/port match your provider
- Try port 143 (non-SSL) if 993 fails

---

## Cron Job Issues

### "Morning briefing never arrives"
**Problem:** Cron job not enabled or timezone wrong.

**Solution:**
1. Check if job exists:
   ```bash
   openclaw cron list
   ```
2. If missing, add it:
   ```bash
   openclaw cron add --name "morning-briefing" \
     --cron "30 7 * * 1-5" --tz "America/New_York" \
     --session isolated --announce \
     --message "Morning briefing: calendar, priority emails, due tasks."
   ```
3. Verify timezone matches your location

---

### "Cron runs but doesn't include my calendar"
**Problem:** Isolated sessions don't inherit auth.

**Solution:**
Ensure Google auth is stored in OpenClaw config, not just environment:
```bash
# Re-authenticate with gog
gog auth logout
gog auth login
```

---

## Folder Issues

### "Cannot save daily review"
**Problem:** Workspace folders don't exist.

**Solution:**
```bash
mkdir -p ~/.openclaw/workspace/inbox
mkdir -p ~/.openclaw/workspace/calendar
mkdir -p ~/.openclaw/workspace/tasks
mkdir -p ~/.openclaw/workspace/daily
mkdir -p ~/.openclaw/workspace/weekly
```

---

## Getting More Help

- **Ask your agent:** "Help me troubleshoot [issue]"
- **Check skill docs:** Each skill has a SKILL.md with details
- **OpenClaw docs:** https://docs.openclaw.ai
- **Community Discord:** https://discord.com/invite/clawd

---

*Last updated: 2026-02-11*
