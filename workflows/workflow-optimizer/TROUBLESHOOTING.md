# Workflow Optimizer Troubleshooting

Common issues and fixes for the Workflow Optimizer workflow template.

---

## Installation Issues

### ❌ Skills installation fails

**Symptoms:**
- `skills.sh` exits with errors
- Tools like `memo`, `gog`, or `remindctl` not found
- Permission errors during installation

**Causes:**
- Homebrew not installed or outdated
- macOS permissions blocking installation
- Network connectivity issues

**Solutions:**

```bash
# 1. Update Homebrew first
brew update
brew upgrade

# 2. Install tools one by one to identify issue
brew install [tool-name]

# 3. Check for permission errors
# If you see "Operation not permitted":
# System Settings → Privacy & Security → Full Disk Access
# Add Terminal.app

# 4. Verify installations
which memo && echo "✅ memo ready"
which gog && echo "✅ gog ready"
which remindctl && echo "✅ remindctl ready"
```

---

## macOS Permission Issues

### ❌ "Permission denied" for Apple Notes

**Symptoms:**
- "Not authorized to send Apple events to Notes" errors
- Can't create or read notes
- Automation access denied

**Solutions:**

**Step 1: Grant Automation Access**
1. Open **System Settings**
2. Go to **Privacy & Security** → **Automation**
3. Find **Terminal** (or your terminal app: iTerm, etc.)
4. Enable checkbox for **Notes**
5. Click OK and restart Terminal

**Step 2: If still not working**
```bash
# Reset automation permissions
tccutil reset AppleEvents

# Try the command again
# When prompted, click "Allow"
```

**Step 3: Alternative terminals**
- iTerm2, Warp, etc. need separate permissions
- Grant access for each terminal app you use
- Or use Terminal.app (built-in) which has fewer issues

---

### ❌ "Permission denied" for Apple Reminders

**Symptoms:**
- Can't create reminders
- "Reminders got an error" messages
- Automation blocked

**Solutions:**

**Same as Notes — grant Automation access:**
1. **System Settings** → **Privacy & Security** → **Automation**
2. Enable **Reminders** for your terminal app
3. Restart terminal
4. Try again

**Alternative: Use Calendar for tasks**
- Calendar often has fewer permission issues
- Can create "tasks" as calendar events
- Works with Google Tasks integration

---

### ❌ "Permission denied" for Calendar

**Symptoms:**
- Can't read or create calendar events
- "Calendar is not allowed" errors

**Solutions:**

1. **System Settings** → **Privacy & Security** → **Calendars**
2. Enable your terminal app
3. If using Google Calendar via `gog`:
   - Ensure Google auth completed successfully
   - Check `gog calendar list` works
4. Restart terminal

---

## Google Workspace Authentication Issues

### ❌ Google auth fails or keeps prompting for login

**Symptoms:**
- `gog auth login` opens browser but doesn't complete
- "Authentication failed" errors
- Token expired messages

**Solutions:**

**1. Clear existing auth and retry:**
```bash
# Logout completely
gog auth logout

# Remove cached credentials
rm -rf ~/.config/gog/

# Fresh login
gog auth login
```

**2. Browser-related issues:**
- Ensure popups aren't blocked
- Try different browser (Safari vs Chrome)
- Check for browser extensions interfering
- Use private/incognito window

**3. Manual authentication:**
```bash
# If browser doesn't auto-open:
gog auth login --no-browser

# 1. Copy the URL shown
# 2. Open manually in browser
# 3. Complete OAuth flow
# 4. Copy verification code
# 5. Paste back into terminal
```

**4. Corporate/Workspace accounts:**
- May require admin approval
- Check with IT department
- Some orgs block third-party apps
- Use personal Gmail account as fallback

---

### ❌ "Insufficient permissions" for Google services

**Symptoms:**
- Can read but can't write (emails, calendar events)
- "403 Forbidden" errors
- "Request had insufficient authentication scopes"

**Solutions:**

```bash
# 1. Check current scopes
gog auth status

# 2. Re-authenticate with full scopes
gog auth logout
gog auth login --scopes=https://mail.google.com/,https://www.googleapis.com/auth/calendar

# 3. For Gmail, may need "less secure app access"
# Google Workspace Admin console → Security → API Controls
# Enable "Allow users to manage their access to less secure apps"
```

---

## Email Configuration Issues (Himalaya)

### ❌ Email connection fails

**Symptoms:**
- "Could not connect to IMAP server" errors
- Authentication failures
- Timeout errors

**Solutions:**

**1. Check config file exists:**
```bash
cat ~/.config/himalaya/config.toml
```

**2. For Gmail, use App Password (not regular password):**

**Create App Password:**
1. Go to https://myaccount.google.com/apppasswords
2. Select "Mail" and your device
3. Generate password
4. Use in config.toml (not your regular password!)

**3. Sample Gmail config:**
```toml
[accounts.gmail]
default = true
email = "your-email@gmail.com"

[accounts.gmail.imap]
host = "imap.gmail.com"
port = 993
login = "your-email@gmail.com"
passwd.cmd = "echo 'your-app-password'"

[accounts.gmail.smtp]
host = "smtp.gmail.com"
port = 587
login = "your-email@gmail.com"
passwd.cmd = "echo 'your-app-password'"
```

**4. Test connection:**
```bash
himalaya accounts sync
himalaya list
```

---

### ❌ App-specific password not working

**Symptoms:**
- Created app password but still fails
- "Invalid credentials" errors

**Solutions:**

- **2-Step Verification must be enabled first**
  - Google Account → Security → 2-Step Verification → Turn On
  - Only then will "App passwords" option appear

- **Use the password exactly as shown**
  - No spaces
  - All 16 characters
  - Don't include username or domain

- **Password in command, not plain text:**
```toml
# ✅ Good (safer)
passwd.cmd = "echo 'abcd efgh ijkl mnop'"

# ⚠️ Works but less secure
passwd = "abcdefghijklmnop"
```

---

## Calendar Integration Issues

### ❌ Calendar events not showing up

**Symptoms:**
- `gog calendar list` returns empty
- Known events missing
- "No events found" when you know there are events

**Solutions:**

**1. Check you're querying the right calendar:**
```bash
# List all calendars
gog calendar list-calendars

# Specify calendar explicitly
gog calendar list --calendar "Work"
gog calendar list --calendar "primary"
```

**2. Check date range:**
```bash
# Default might not include today
gog calendar list --from today --to "+7 days"
```

**3. Verify permissions:**
- System Settings → Privacy & Security → Calendars
- Ensure terminal app has access

**4. Sync issues:**
- If using iCloud + Google Calendar
- They may be out of sync
- Check on web calendar to confirm events exist

---

### ❌ Can't create calendar events

**Symptoms:**
- Read-only access works
- "Permission denied" when creating events
- Events created in wrong calendar

**Solutions:**

```bash
# 1. Check write permissions
gog auth status
# Should show calendar write scope

# 2. Re-auth with write access
gog auth refresh --scopes=https://www.googleapis.com/auth/calendar

# 3. Specify target calendar
gog calendar create --calendar "primary" "Event Title" --when "tomorrow 2pm"
```

---

## Cron Job Issues

### ❌ Morning briefing doesn't run

**Symptoms:**
- No briefing at scheduled time
- Cron job exists but never executes
- Manual trigger works, automatic doesn't

**Solutions:**

**1. Check OpenClaw gateway is running:**
```bash
openclaw gateway status

# If stopped:
openclaw gateway start
```

**2. Verify cron is enabled:**
```bash
openclaw cron list

# Look for your job and check "enabled: true"
# If disabled:
openclaw cron update <job-id> --enabled true
```

**3. Check cron schedule syntax:**
```bash
# View job details
openclaw cron info <job-id>

# Common schedules:
# "0 7 * * *"      → Daily at 7:00 AM
# "30 7 * * 1-5"   → Weekdays at 7:30 AM  
# "*/30 * * * *"   → Every 30 minutes
```

**4. Test manually first:**
```bash
openclaw cron run <job-id>
# If this fails, fix the job before relying on schedule
```

**5. Check logs:**
```bash
openclaw cron logs <job-id>
# Shows recent execution attempts and errors
```

---

### ❌ Cron notifications not showing up

**Symptoms:**
- Job runs (check logs) but no notification
- Silent failures
- Notifications enabled but not received

**Solutions:**

**1. Check notification settings:**
- macOS System Settings → Notifications
- Ensure OpenClaw or Terminal has notifications enabled
- Check Do Not Disturb isn't blocking

**2. Verify output method:**
```bash
# Check cron job configuration
openclaw cron info <job-id>

# Should specify notification method:
# - Desktop notification
# - Message to channel
# - File output
```

**3. Test notification directly:**
```bash
# Send test notification
openclaw notify "Test message"

# If this doesn't show, OS permissions are the issue
```

---

## Task Management Issues

### ❌ Reminders not syncing across devices

**Symptoms:**
- Reminder created on Mac doesn't show on iPhone
- Old reminders still showing after completion
- Sync delays

**Solutions:**

**1. Check iCloud sync:**
- System Settings → Apple ID → iCloud
- Ensure Reminders is enabled
- Toggle off/on to force sync

**2. Wait for sync:**
- iCloud can take 1-5 minutes to propagate
- Not instant like Google services

**3. Use Google Tasks instead:**
```bash
# Create task in Google Tasks
gog tasks create "Task description" --due "Friday"

# Syncs faster, works cross-platform
```

---

### ❌ Duplicate reminders created

**Symptoms:**
- Same reminder appears multiple times
- Created both locally and remotely
- Sync conflicts

**Solutions:**

**1. Check which system you're using:**
- Apple Reminders (local + iCloud)
- Google Tasks (Google account)
- Don't mix both for same tasks

**2. Clear duplicates:**
```bash
# List all reminders
remindctl list

# Delete by ID
remindctl delete <reminder-id>
```

**3. Choose one system:**
- Personal tasks → Apple Reminders
- Work tasks → Google Tasks
- Or all in one place

---

## Weather Integration Issues

### ❌ Weather data not available

**Symptoms:**
- "Weather unavailable" errors
- Location not detected
- Outdated weather data

**Solutions:**

**1. Enable Location Services:**
- System Settings → Privacy & Security → Location Services
- Enable Location Services
- Enable for Terminal (or your terminal app)

**2. Specify location explicitly:**
```bash
# Instead of: "What's the weather?"
# Use: "What's the weather in San Francisco?"
```

**3. Check weather API:**
- Some weather services require API keys
- Check template config for required keys
- Free tier usually sufficient

---

## Platform-Specific Gotchas

### macOS

**Multiple terminal apps = multiple permission grants:**
- Terminal.app ≠ iTerm2 ≠ Warp
- Grant Automation access to each separately
- Or stick with one terminal

**iCloud sync delays:**
- Notes, Reminders, Calendar sync isn't instant
- 1-5 minute delays are normal
- Critical tasks: Use Google services (faster sync)

**Notifications require focus modes:**
- Check Focus mode settings
- "Do Not Disturb" blocks briefings
- Schedule exceptions for important notifications

---

### Google Workspace Enterprise

**Admin restrictions:**
- Company may block third-party app access
- Contact IT to allowlist OAuth app
- Or use personal Gmail for home tasks

**Shared calendars:**
- May have read-only access
- Can view but can't create events
- Check calendar permissions in Google Calendar web

---

## Recovery Procedures

### Full template reset

**If everything's broken and you want to start fresh:**

```bash
# 1. Backup current config
cp ~/.openclaw/workspace/AGENTS.md ~/.openclaw/workspace/AGENTS.md.backup

# 2. Clear all auth
gog auth logout
rm -rf ~/.config/gog/
rm -rf ~/.config/himalaya/

# 3. Reset macOS permissions
# System Settings → Privacy & Security → Automation
# Remove Terminal from all apps, then re-add when prompted

# 4. Reinstall skills
bash ~/Downloads/openclaw-setup/workflows/workflow-optimizer/skills.sh

# 5. Re-authenticate
gog auth login

# 6. Verify
gog auth status
gog calendar list
```

---

### Switching to a different template

**To switch from workflow-optimizer to another workflow:**

```bash
# 1. Disable workflow-optimizer crons
openclaw cron list | grep workflow
openclaw cron update <job-id> --enabled false

# 2. Archive current AGENTS.md
mv ~/.openclaw/workspace/AGENTS.md ~/.openclaw/workspace/AGENTS.workflow.md

# 3. Install new template
cd ~/Downloads/openclaw-setup/workflows/[new-template]/
bash skills.sh
cp AGENTS.md ~/.openclaw/workspace/

# 4. Keep useful skills
# gog, memo, remindctl are valuable for many workflows
```

---

### Nuclear option: Start completely fresh

**If permissions are hopelessly broken:**

```bash
# 1. Backup everything important
cp -r ~/.openclaw/workspace ~/Desktop/workspace-backup

# 2. Reset TCC database (macOS permissions)
tccutil reset All

# ⚠️ This resets ALL app permissions system-wide!
# You'll need to re-grant permissions for many apps

# 3. Reboot Mac

# 4. Fresh install
bash ~/Downloads/openclaw-setup/workflows/workflow-optimizer/skills.sh

# 5. When prompted for permissions, click "Allow"
```

---

## Getting More Help

**Google Workspace issues:**
- gog CLI docs: https://github.com/prasmussen/google-oauth-go
- Google Calendar API: https://developers.google.com/calendar
- Gmail API: https://developers.google.com/gmail/api

**Email client (Himalaya):**
- Documentation: https://pimalaya.org/himalaya/
- GitHub: https://github.com/soywod/himalaya

**macOS Automation:**
- AppleScript docs: https://developer.apple.com/library/archive/documentation/AppleScript/
- Automation permissions: https://support.apple.com/guide/mac-help/

**Ask your agent:**
> "Why isn't my Google Calendar connecting? Here's the error: [paste error]"
> "Help me debug email auth - authentication keeps failing"
> "My morning briefing cron isn't running, what should I check?"

**OpenClaw community:**
- GitHub issues: https://github.com/steipete/openclaw/issues
- Community discussions: [link if available]

---

**Last updated:** 2026-02-11
