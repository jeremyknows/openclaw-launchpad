# OpenClaw Foundation Playbook — Template

> **Version:** 1.2 (based on Watson Foundation Playbook v3, audited 2026-02-08)
> **Last verified with:** OpenClaw v2026.2.9-3 on macOS (Apple Silicon)
> **Purpose:** Systematic playbook for hardening, configuring, and optimizing an OpenClaw
> AI agent deployment. Works for any bot name, any channel setup, any use case.
>
> **New to OpenClaw?** Start with the [OpenClaw Setup Guide](OPENCLAW-SETUP-GUIDE.md) first.
> That guide walks you through installation, account creation, and getting a running gateway.
> Come back to THIS playbook once you have a working `openclaw dashboard`.
>
> **How to use:**
> 1. Fill out the **Configuration** section below with your details
> 2. Answer the **Pre-Flight Questions** — these shape the entire playbook
> 3. Work through phases in order, one phase per session
> 4. At each Phase Checkpoint: write to memory, then STOP
> 5. Have the bot owner review before starting the next phase
>
> **CRITICAL: One phase per session.** When you finish a phase, write a summary
> to `memory/YYYY-MM-DD.md` and MEMORY.md, then STOP. The owner kicks off
> the next phase in a new session. This prevents context window overload.

---

## Configuration

Fill these out before starting. Everything below references these values.

```yaml
# ─── Identity ───────────────────────────────────────────────
bot_name: "Maverick"                    # Your bot's name
bot_role: "AI assistant"                # e.g., "AI COO", "AI researcher", "AI ops manager"
owner_name: "Matt"                      # The human running this
owner_mac_user: ""                      # macOS admin username (e.g., "matt")
bot_mac_user: ""                        # macOS bot username (e.g., "maverick")

# ─── Infrastructure ─────────────────────────────────────────
hardware: "Mac Mini M4"                 # What it runs on
timezone: "America/New_York"            # System timezone (used for cron jobs)
openclaw_version: ""                    # Fill after running `openclaw --version`

# ─── Primary Channel ────────────────────────────────────────
# Which channel is the bot's primary workspace?
# Discord is recommended — rich formatting, topic channels, file sharing.
primary_channel: "discord"              # "discord", "telegram", "imessage", "dashboard"

# ─── Discord Config (if using Discord) ──────────────────────
discord_server_name: ""                 # Your Discord server name
discord_server_id: ""                   # Guild ID (from Discord Developer Portal)
discord_bot_token: ""                   # Bot token (KEEP SECRET)
                                        # WARNING: Do NOT commit this file to git after filling in tokens. Add it to .gitignore.
discord_owner_id: ""                    # Your Discord user ID (for DM allowlist)

# Discord channels — customize to your needs.
# The playbook creates these categories. Add/remove as needed.
discord_channels:
  general: "#general"                   # Primary working channel (shared session)
  logs: "#bot-logs"                     # Bot posts status updates here (output only)
  # ─── Topic channels (isolated sessions) ───────────────────
  # Add channels for your bot's domains. Examples:
  # project_a: "#project-alpha"
  # research: "#research"
  # ops: "#operations"
  # finances: "#finances"

# ─── Secondary Channels ─────────────────────────────────────
# These are lightweight — alerts, quick messages, mobile access.
# Set enabled: false for channels you don't use.
imessage:
  enabled: true                         # true/false
  role: "alerts"                        # "alerts" (notifications only) or "disabled"
telegram:
  enabled: true
  role: "alerts"
email:
  enabled: false
  address: ""                           # e.g., "maverick@gmail.com"

# ─── AI Provider ────────────────────────────────────────────
primary_model: ""                       # Recommended: "openrouter/moonshotai/kimi-k2.5" (budget-friendly default)
fallback_model: ""                      # Recommended: "anthropic/claude-sonnet-4-5" (premium fallback)
embedding_provider: "voyage"            # "voyage", "openai", "ollama"
embedding_model: "voyage-3"             # Model name for embeddings

# ─── Projects / Domains ─────────────────────────────────────
# What does your bot work on? List your domains/projects.
# These become filters, color codes, and channel mappings.
projects:
  # - name: "project-alpha"
  #   description: "Main business project"
  #   discord_channel: "#project-alpha"
  # - name: "research"
  #   description: "Research and analysis"
  #   discord_channel: "#research"
  # - name: "personal"
  #   description: "Personal tasks"
  # - name: "system"
  #   description: "Bot self-maintenance"

# ─── Owner Schedule (for calendar/cron awareness) ───────────
# Block times when the bot should NOT schedule meetings or interrupt.
blocked_times:
  # - label: "Morning standup"
  #   days: "MWF"
  #   time: "9:00-10:00 AM"
  # - label: "Focus time"
  #   days: "weekdays"
  #   time: "2:00-4:00 PM"
core_hours: "9 AM - 6 PM"              # When the owner is typically available
```

---

## Pre-Flight Questions

Answer these BEFORE starting Phase 1. Your answers shape the entire playbook.
If you're not sure, pick the conservative option — you can change later.

### Q1: What is your bot's primary job?
> _Example: "Help me manage my business operations — email triage, research, scheduling, and project tracking."_
>
> **Your answer:** _______________________________________________

### Q2: What permissions should your bot start with?
> Most people start restrictive and loosen over time as trust builds.

| Tier | Description | Recommended for |
|------|-------------|-----------------|
| **Tier 1** | Everything needs approval | New bots, first 2 weeks |
| **Tier 2** | Routine actions autonomous, big decisions need approval | After 2 weeks of stable Tier 1 |
| **Tier 3** | Full autonomy within defined boundaries | After 1+ month, strong trust |

> **Starting tier:** _______________

### Q2b: What access profile fits your use case?
> This controls what your bot **can** do (capabilities), while the Tier above controls
> what it needs **approval** for. Most founders experimenting should start with **Explorer**.

| Profile | What the bot can do | Trade-off | Best for |
|---------|-------------------|-----------|----------|
| **Explorer** (recommended) | All tools enabled: web browsing, shell commands, file access, messaging. OS-level user isolation constrains access; Docker sandbox optional. | Maximum capability. You monitor via logs and alerts. | Most founders learning what OpenClaw can do |
| **Guarded** | Web browsing and messaging enabled. Shell commands require approval. File writes limited to workspace. | Slightly less friction than Tier 1 approval, but blocks the riskiest tool outright. | Bots that process untrusted email or web content |
| **Restricted** | Messaging and memory only. No web, no shell, no file writes outside workspace. | Very safe, but limited. | Alert-only bots, notification relays |

> **Think of it this way:** The *Tier* is how much you supervise the bot.
> The *Profile* is what the bot is physically capable of doing. Most people
> want Explorer + Tier 1: the bot can do anything, but asks you first.
>
> **Access profile:** _______________

### Q3: How will your bot communicate with you?
> The playbook assumes Discord as primary. Check all that apply:

- [ ] Discord (recommended primary — rich formatting, channels, files)
- [ ] iMessage (good for mobile alerts)
- [ ] Telegram (good for mobile alerts)
- [ ] Email (for async communication)
- [ ] Dashboard chat only (minimal setup)

### Q4: What Discord channels do you need?
> Map your bot's responsibilities to channels. Each topic channel gets isolated context.

| Channel | Purpose | Session Type |
|---------|---------|-------------|
| `#general` | Primary working channel | Shared |
| `#bot-logs` | Bot status updates (output only) | N/A |
| `#___________` | ___________________________ | Isolated |
| `#___________` | ___________________________ | Isolated |
| `#___________` | ___________________________ | Isolated |

### Q5: What APIs and services does your bot need?
> Check all that apply. These get verified in Phase 1.

- [ ] OpenRouter — recommended (Kimi K2.5 default, 100+ models)
- [ ] Anthropic (Claude) — premium fallback for complex tasks
- [ ] OpenAI — GPT models
- [ ] Gmail / Email (IMAP)
- [ ] Google Calendar
- [ ] Google Drive
- [ ] GitHub
- [ ] Supabase / Database
- [ ] Web search (Brave, Tavily, etc.)
- [ ] Other: _______________

### Q6: What's your monthly budget for AI costs?
> Every API call costs tokens. Cron jobs running every 30 minutes add up.
> Setting a budget now prevents surprise bills. You can always adjust later.

| Budget | What it covers | Notes |
|--------|---------------|-------|
| **$25/month** | Light usage — a few cron jobs, occasional conversations | Good starting point |
| **$50-100/month** | Moderate — hourly cron jobs, daily briefings, active conversations | Most single-bot setups |
| **$200+/month** | Heavy — multi-agent, frequent automation, large context windows | For power users |

> **Monthly budget:** $_______________
> **Hard ceiling (never exceed):** $_______________

### Q7: Multi-agent plans? (Phase 8)
> Do you plan to run multiple specialized agents eventually?
> If yes, what specialists would be useful? (If not sure, pick "Not planning" — you can always add this later.)

- [ ] Not planning multi-agent (skip Phase 8)
- [ ] Yes — here are my ideas:
  - Specialist 1: _______________ (channel: #___________)
  - Specialist 2: _______________ (channel: #___________)
  - Specialist 3: _______________ (channel: #___________)

---

## Known Risks & Why We're Proceeding

OpenClaw is powerful but controversial. CrowdStrike, Trend Micro, and Cisco have published
security advisories. OpenClaw agents have filesystem access, can browse the web, read emails,
and execute code — that's a massive attack surface.

**Why it's worth it (with precautions):**
- Bot runs on a dedicated Mac user with no access to the owner's files or Keychain
- Only hand-built skills are installed (no ClawHub marketplace)
- API keys are cost-limited and scoped to minimum permissions
- This playbook hardens everything before trusting the bot

**The deal:** If any phase reveals a security issue that can't be mitigated,
STOP and reassess. The bot flags it to the owner immediately.

---

## Phase 1: Security Hardening (Do First)

Security is the foundation everything else sits on.

> **Used the autosetup script?** If you ran `openclaw-autosetup.sh`, the following
> items from Phase 1 are already done: version verification (1.1), Mac user isolation (1.4),
> home directory permissions, config file permissions, sleep prevention (1.11), auto-update
> disable (1.11), and access profile (1.12). You still need to complete: security audit (1.2),
> doctor check (1.3), skill audit (1.5), API key security (1.7), spending limits (1.8),
> network security (1.9), backup plan (1.10), macOS TCC permissions (1.13), and incident
> response (1.14).

### 1.1 Verify OpenClaw Version

**Why:** CVE-2026-25253 (CVSS 8.8) allows remote code execution via malicious links.
CVE-2026-25157 adds command injection vulnerabilities. Any bot that reads emails or
browses the web is exposed. Patched in version 2026.1.29, but **v2026.2.9+ is strongly
recommended** — it adds a VirusTotal-integrated safety scanner and credential redaction.

```bash
openclaw --version
```

- [ ] Version is **2026.2.9 or later** (recommended) — or at minimum 2026.1.29
- [ ] If not, update immediately

**Notes:** _______________

---

### 1.2 Run Security Audit

**Why:** OpenClaw has a built-in deep security scanner that catches common misconfigurations.

```bash
openclaw security audit --deep
```

- [ ] 0 critical findings
- [ ] All warnings reviewed and addressed (or documented as acceptable)
- [ ] Credentials directory permissions are 700 (not 755)

```bash
# Fix credentials permissions if needed
chmod 700 ~/.openclaw/credentials
```

**Findings:** _______________

---

### 1.3 Run Doctor & Status

```bash
openclaw doctor
openclaw status --all
```

If doctor reports fixable issues, you can auto-repair them:
```bash
openclaw doctor --fix
```

> **Note:** `--fix` applies changes without asking. Run `openclaw doctor` first
> (without `--fix`) to review the issues, then decide if auto-repair is appropriate.

- [ ] Doctor reports no critical issues
- [ ] All enabled channels show connected
- [ ] Gateway running as LaunchAgent
- [ ] Note any warnings for the owner to review

**Findings:** _______________

---

### 1.4 Verify Mac User Isolation (REQUIRES OWNER)

**Why:** The bot runs as a separate Mac user. This IS the security boundary.
Default macOS home directory permissions (755) allow any local user to read
files — this must be locked down.

**Bot runs these verification commands:**
```bash
whoami                              # Should show "{{bot_mac_user}}"
ls /Users/{{owner_mac_user}}/ 2>&1  # Should say "Permission denied"
security list-keychains 2>&1        # Should show bot's keychain only
```

- [ ] `whoami` returns `{{bot_mac_user}}` (not `{{owner_mac_user}}`)
- [ ] Cannot read owner's home directory — if FAILS, owner must fix:
  ```bash
  sudo chmod 700 /Users/{{owner_mac_user}}
  ```
- [ ] Keychain is bot's own, not owner's

**SECURITY NOTE:** If the bot CAN read the owner's home directory, this is a
**critical issue**. Stop and fix before continuing.

**Findings:** _______________

---

### 1.5 Audit Installed Skills

**Why:** 341 malicious skills were found on ClawHub (12% of 2,857 audited — the "ClawHavoc"
campaign). A separate Snyk audit found 13.4% of skills had critical security issues.
Skills are NOT sandboxed — they're executable code with full filesystem access.

```bash
ls ~/.openclaw/skills/
```

- [ ] Only recognized skills from the owner's approved set are installed
- [ ] No unknown third-party or ClawHub skills
- [ ] **Rule: NEVER install skills from ClawHub without owner's explicit approval**

**Installed skills:** _______________

---

### 1.6 Consider ACIP (Prompt Injection Resistance)

**Why:** Prompt injection attacks targeting OpenClaw have been found in email,
web pages, and social media. If the bot reads untrusted content, this matters.

**Reference:** https://github.com/Dicklesworthstone/acip

- [ ] Owner decides: Install ACIP / Skip for now
- [ ] If installed: configure and test

**Decision:** _______________

---

### 1.7 Verify API Key Security

```bash
# Check for exposed keys across common file types (exclude node_modules, .git)
grep -rE "sk-|pa-|eyJhbG|DISCORD.*TOKEN|BOT_TOKEN" ~/ \
  --include="*.md" --include="*.txt" --include="*.json" --include="*.env" \
  --include="*.sh" --include="*.zsh" --include="*.yaml" --include="*.toml" \
  --exclude-dir=node_modules --exclude-dir=.git 2>/dev/null | head -10

# Check .env files specifically
find ~/ -name ".env*" -not -path "*/node_modules/*" -exec ls -la {} \; 2>/dev/null
```

- [ ] No API keys in plaintext files (check md, txt, json, env, sh, yaml, toml)
- [ ] `.env` files have 600 permissions
- [ ] API keys in `openclaw.json` are in a file with restricted permissions
- [ ] Discord bot token is not exposed in any plaintext file
- [ ] Embedding provider API key is not exposed outside `openclaw.json`

**Credential rotation (set a calendar reminder):**
API keys should be rotated every 90 days. Longer they live, higher the risk if compromised.

| Credential | Rotate every | Where to rotate |
|-----------|-------------|-----------------|
| AI provider API keys (Anthropic, OpenRouter, OpenAI) | 90 days | Provider dashboard → API Keys → Generate new → Update `openclaw.json` → Delete old |
| Discord bot token | 90 days | Discord Developer Portal → Bot → Reset Token → Update `openclaw.json` |
| Embedding API key (Voyage, OpenAI) | 90 days | Provider dashboard |
| Gateway auth token | 90 days | `openclaw.json` |

- [ ] Calendar reminder set for first rotation (90 days from today: ___/___/___)

**Issues found:** _______________

---

### 1.8 Set API Spending Limits (Do This Now)

**Why:** A single runaway agent or misconfigured cron job can burn through API credits
fast. Set limits BEFORE enabling automation in Phase 4.

- [ ] Anthropic: Set monthly spending limit in dashboard (console.anthropic.com)
- [ ] OpenRouter: Set credit limit (openrouter.ai/settings)
- [ ] OpenAI: Set monthly budget (platform.openai.com)
- [ ] Embedding provider: Understand per-query cost (Voyage ~$0.06/1M tokens)
- [ ] Note: Each cron job execution = 1 isolated session = tokens consumed

**Rough cost awareness:**
- Email check every 30 min × 14 hours = 28 sessions/day
- Each session: ~2K-10K tokens depending on complexity
- Estimate: $1-5/day for basic cron automation

---

### 1.9 Verify Gateway Network Security

**Why:** The `openclaw security audit --deep` specifically checks for exposed endpoints.
If the gateway WebSocket is accessible from the network, anyone can connect.

```bash
openclaw security audit --deep | grep -i "gateway\|exposed\|network\|binding"
```

- [ ] Gateway binds to localhost only (not 0.0.0.0)
- [ ] No browser control endpoints (CDP) exposed
- [ ] If using a reverse proxy: authentication is required (CVE-2026-25253 exploit
      chain includes authentication bypass via reverse proxy misconfiguration)

---

### 1.10 Create Backup Plan

**Why:** A hardware failure or accidental deletion destroys everything. Even a basic
backup prevents catastrophic loss.

**Minimum backup (do now):**
```bash
# Copy critical files to a backup location
cp -r ~/.openclaw/openclaw.json /path/to/backup/
cp -r ~/.openclaw/workspace/ /path/to/backup/workspace/
cp -r ~/.openclaw/cron/ /path/to/backup/cron/
cp -r ~/.openclaw/skills/ /path/to/backup/skills/
```

**Git-based backup (recommended for workspace):**

If you're comfortable with git, version-tracking your workspace is the most reliable
backup strategy:

```bash
cd ~/.openclaw/workspace/
git init
git add -A
git commit -m "Initial workspace snapshot"
```

Commit periodically (weekly, or after major changes) to keep a full history of your
bot's configuration and memory.

> **WARNING: Never push this repository to a public GitHub repo.** Your workspace
> may contain API keys in MEMORY.md files, conversation logs, or other sensitive data.
> If you want remote backup, use a **private** repository.

- [ ] Backup location identified (iCloud, external drive, git repo)
- [ ] Initial backup created
- [ ] Plan for weekly backups (manual or automated)

---

### 1.11 Prevent Mac Sleep (REQUIRES OWNER)

**Why:** If the Mac sleeps, ALL cron jobs stop, ALL channels disconnect,
the bot goes silent. This is the #1 reason agents "randomly stop working."

**Bot checks current settings:**
```bash
pmset -g | grep -i sleep
```

**Owner runs (requires admin/sudo):**
```bash
sudo pmset -a sleep 0 standby 0 hibernatemode 0 powernap 0 displaysleep 15 disksleep 0
```

- [ ] System sleep disabled (`sleep 0`)
- [ ] Display sleep set to save energy (`displaysleep 15`)
- [ ] Power nap off (`powernap 0`)
- [ ] Standby off (`standby 0`)

**Also prevent automatic restarts from macOS updates:**
```bash
# Disable automatic macOS update restarts (sleep prevention alone doesn't cover this)
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool FALSE
```

- [ ] Auto-restart from updates disabled
- [ ] Gateway LaunchAgent configured to auto-start after unexpected reboots

**GOTCHA:** Sleep prevention (above) and update restarts are **separate systems**.
You can disable sleep perfectly but macOS will still restart for a system update
at 2 AM if auto-updates are enabled.

---

### 1.12 Configure Access Profile (From Q2b)

**Why:** This is where you set the boundaries on what your bot can physically do.
Think of it like childproofing a house — you're not saying the kid is bad, you're
making the environment safe for exploration.

**Explorer Profile** (recommended for most founders):
```json
"sandbox": {
  "mode": "off",
  "workspaceAccess": "rw"
},
"tools": {
  "notes": "All tools enabled. Monitor via logs channel."
}
```

**Guarded Profile** (for bots processing untrusted email/web content):
```json
"sandbox": {
  "mode": "off",
  "workspaceAccess": "rw"
},
"tools": {
  "deny": ["exec"],
  "notes": "Shell commands blocked. Web browsing and messaging allowed."
}
```

**Restricted Profile** (alert-only bots):
```json
"sandbox": {
  "mode": "off",
  "workspaceAccess": "ro"
},
"tools": {
  "deny": ["exec", "browser", "web_search", "web_fetch"],
  "notes": "Messaging and memory only. No web, no shell."
}
```

> **Sandbox mode values explained:**
> - `"off"` — No Docker container isolation. The bot runs directly on the host.
>   OS-level user isolation (separate macOS user, `chmod 700` home directories) and
>   tool deny lists provide your access control. **This is the right choice if you
>   don't have Docker installed.**
> - `"non-main"` — Sub-agents run inside Docker containers; the main agent does not.
>   Requires Docker Desktop.
> - `"all"` — Every agent session runs in a Docker container. Strongest isolation,
>   but heaviest on resources. Requires Docker Desktop.
>
> The official docs recommend `"non-main"` as the default for users with Docker —
> it sandboxes channel/cron sessions while keeping your main dashboard chat fast.
> Most founders without Docker should use `"off"` and rely on the macOS user
> isolation + tool deny lists set up in this playbook. If you install Docker later,
> you can upgrade to `"non-main"` or `"all"` for stronger sandboxing.
>
> **Note:** Sandboxed containers have **no network access by default.** If your bot
> needs to browse the web or call APIs from inside the sandbox, you must set
> `sandbox.docker.network` in your config. This is a deliberate security choice —
> but it surprises people who enable sandboxing and find their bot can't reach anything.

Add the appropriate block to `openclaw.json` under `agents.defaults`.

**⚠️ Before editing `openclaw.json`:** Always make a backup first. A single
missing comma or bracket will prevent the gateway from starting.
```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup
```
After editing, validate with:
```bash
openclaw doctor
```

- [ ] Access profile from Q2b applied to config
- [ ] `openclaw doctor` passes after config change
- [ ] Backup of original config saved

**You can change profiles later.** Starting with Explorer is fine — the approval
Tier from Q2 is your real safety net. The profile just sets the outer boundary.

---

### 1.12b Consider openclaw-shield (Optional Security Plugin)

**openclaw-shield** is a community security plugin that adds layered protection on top
of OpenClaw's built-in safety features. It's optional but worth evaluating if you want
extra visibility into what your bot is doing.

What it offers:
- **L1 — Audit Logger:** Logs every tool call, API request, and file access to a structured
  audit trail. Useful for reviewing what the bot did during a session.
- **L2 — Prompt Scanner:** Scans incoming messages for known prompt injection patterns
  before they reach the agent. Helpful if your bot reads untrusted email or web content.
- **L3 — Tool Blocker:** Intended to block specific tool calls based on rules. **Not yet
  functional** — the feature is in development. Don't rely on it for access control.

If you decide to install it, follow the project's README for setup. It installs as an
OpenClaw skill and doesn't require changes to your core config.

- [ ] Owner decision: Install openclaw-shield / Skip for now

---

### 1.13 Audit macOS Permissions (REQUIRES OWNER)

**Why:** macOS has its own permission system called TCC (Transparency, Consent, and
Control). Even if the bot user is isolated, macOS may grant it permissions like
Full Disk Access, Accessibility, or Screen Recording if someone clicks "Allow" on
a system dialog. Non-technical users tend to allow everything — each permission
should be a deliberate decision.

**Owner checks in System Settings → Privacy & Security:**

| Permission | Needed? | Why / Why Not |
|-----------|---------|---------------|
| Full Disk Access | **Only if using iMessage** | iMessage databases are in a protected location |
| Accessibility | **No** (unless specific skill requires it) | Allows keylogging and UI automation |
| Screen Recording | **No** | Allows capturing screen content |
| Camera / Microphone | **No** | Not needed for text-based bots |
| Files and Folders | **Workspace only** | Grant access to `~/.openclaw/workspace/`, deny others |
| Automation | **Case by case** | Only for skills that control other apps (e.g., Calendar) |

- [ ] Reviewed each TCC permission for bot user
- [ ] Denied everything not explicitly needed
- [ ] If iMessage enabled: Full Disk Access granted (document this trade-off)
- [ ] No Accessibility or Screen Recording permissions granted

**Rule of thumb:** If a macOS dialog pops up asking for permission, **deny it**
and check with the playbook or the owner before allowing.

---

### 1.14 Incident Response Basics

**Why:** Things will go wrong — API outages, runaway cron jobs, unexpected behavior.
Having a plan BEFORE the emergency prevents panic decisions.

**Emergency shutdown (memorize this):**
```bash
# Kill the gateway immediately — all channels disconnect, all cron stops
killall openclaw

# Or if that doesn't work:
pkill -9 -f openclaw
```

**If you suspect the bot did something wrong:**
1. **Kill the gateway** (command above)
2. **Don't delete anything** — logs are evidence
3. **Save logs before investigating:**
   ```bash
   cp -r /tmp/openclaw/ ~/openclaw-incident-$(date +%Y%m%d)/
   ```
4. **Rotate credentials** — change API keys for any service the bot has access to
5. **Review logs** in the saved directory to understand what happened
6. **Restart only after** you understand the issue and have mitigated it

**If spending is out of control:**
1. Go to your API provider dashboards immediately:
   - Anthropic: console.anthropic.com → Settings → Spending
   - OpenRouter: openrouter.ai/settings
   - OpenAI: platform.openai.com → Billing
2. Set hard spending limits (if not already set in Phase 1.8)
3. Kill the gateway to stop all automated API calls

- [ ] Owner knows the emergency shutdown command
- [ ] Owner knows where to find API spending dashboards
- [ ] Log backup location identified: _______________

---

### Phase 1 Checkpoint

**STOP.** Before Phase 2:
1. Write Phase 1 findings to `memory/YYYY-MM-DD.md`
2. Update MEMORY.md with security facts (version, audit results, skill inventory)
3. List anything blocked on the owner
4. Wait for owner to confirm manual items and approve Phase 2

---

## Phase 2: Memory & Persistence

The bot wakes fresh each session. Memory files are how identity persists.

### ⚠️ Config Editing Safety (Read Before Phases 2 & 3)

Several steps below require editing `openclaw.json`. This is a JSON file — it's
picky about syntax. A single missing comma or extra bracket will crash the gateway.

**Before every edit:**
```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup
```

**After every edit:**
```bash
openclaw doctor   # Validates your config — will tell you if something is wrong
```

**If the gateway won't start after an edit:**
```bash
# Restore your backup
cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json
```

**Common JSON mistakes:**
- Missing comma between items: `"key1": "value1" "key2": "value2"` ← needs comma after `"value1"`
- Trailing comma after last item: `"key": "value",` ← remove that final comma
- Using single quotes: `'value'` ← must be double quotes `"value"`

---

### 2.1 Enable memorySearch (DISABLED BY DEFAULT)

**Why:** This is the single most impactful setting. OpenClaw's memorySearch is
DISABLED by default. Without it, the bot writes to memory but can't intelligently
search it. Community consensus: this is the "aha moment" that makes agents useful.

```bash
grep -i "memorySearch" ~/.openclaw/openclaw.json 2>/dev/null
```

**If not configured, add to `openclaw.json` under `agents.defaults`** (remember to backup first!):
```json
"memorySearch": {
  "enabled": true,
  "provider": "{{embedding_provider}}",
  "model": "{{embedding_model}}",
  "sources": ["memory", "sessions"],
  "query": {
    "maxResults": 5,
    "minScore": 0.75
  }
}
```

**Provider-specific config:**
- **Voyage AI**: Add `"remote": { "apiKey": "your-key" }` — uses default endpoint
- **OpenAI**: Add `"remote": { "apiKey": "your-key" }` — uses default endpoint
- **Ollama (local)**: Add `"baseUrl": "http://127.0.0.1:11434/v1"` — **use 127.0.0.1, NOT localhost** (Node.js IPv6 resolution issue)

- [ ] memorySearch is enabled with a working embedding provider
- [ ] Test: ask the bot "what did we discuss yesterday?" — it should retrieve results

**GOTCHA:** If using local Ollama, always use `127.0.0.1` instead of `localhost`.
Node.js 18+ resolves `localhost` to IPv6 (`::1`) first, but Ollama only listens on IPv4.

---

### 2.2 Create & Verify Workspace Structure

**If you ran `openclaw-autosetup.sh`**, workspace files were copied automatically from `templates/workspace/` during Step 12. You can skip straight to the verification checklist below.

**If setting up manually**, create the workspace subdirectories and copy the template files:

```bash
# Create subdirectories
mkdir -p ~/.openclaw/workspace/memory
mkdir -p ~/.openclaw/workspace/cron
mkdir -p ~/.openclaw/workspace/plans
mkdir -p ~/.openclaw/workspace/scripts

# Copy templates (only if file doesn't already exist)
TEMPLATE_DIR="$HOME/Downloads/openclaw-setup/templates/workspace"
if [ -d "$TEMPLATE_DIR" ]; then
    for f in "$TEMPLATE_DIR"/*.md; do
        dest="$HOME/.openclaw/workspace/$(basename "$f")"
        [ ! -f "$dest" ] && cp "$f" "$dest" && echo "Created $(basename "$f")"
    done
else
    echo "Template directory not found at $TEMPLATE_DIR"
    echo "Ask your bot to create minimal stubs for AGENTS.md, MEMORY.md, and BOOTSTRAP.md"
fi
```

**Template files** (all sourced from `templates/workspace/`):
- **AGENTS.md** — primary operating instructions, loaded every session
- **BOOTSTRAP.md** — first-conversation personalization guide (self-deletes after use)
- **HEARTBEAT.md** — daily check-in schedule and routines
- **IDENTITY.md** — bot name, emoji, and self-concept
- **MEMORY.md** — persistent knowledge store (**Note:** only loads in private sessions, not group channels)
- **SOUL.md** — personality framework and operating principles
- **TOOLS.md** — tool usage guidelines and preferences
- **USER.md** — owner profile and preferences, loaded every session

**Verification checklist:**
- [ ] `~/.openclaw/workspace/` contains all 8 `.md` files listed above
- [ ] `memory/`, `cron/`, `plans/`, `scripts/` subdirectories exist
- [ ] All files are writable by the bot user (`ls -la ~/.openclaw/workspace/`)
- [ ] BOOTSTRAP.md exists (needed for the first-conversation flow in 2.2b)

---

### 2.2b First Conversation Protocol (BOOTSTRAP.md)

BOOTSTRAP.md is a self-deleting first-conversation guide. When the bot opens a new session and finds this file, it walks the owner through 9 personalization questions:

1. Bot name → updates IDENTITY.md
2. Personality style → updates SOUL.md
3. Emoji identity → updates IDENTITY.md
4. Communication preferences → updates SOUL.md
5. Owner name → updates USER.md
6. Timezone → updates USER.md + HEARTBEAT.md
7. Primary use case → updates USER.md
8. Success criteria → updates USER.md
9. Other preferences → updates SOUL.md + USER.md

After collecting answers, the bot fills in the template files and **deletes BOOTSTRAP.md**. This signals that first-run personalization is complete.

**How to trigger it:** Open a conversation with your bot (dashboard chat, Discord DM, or any private channel). If BOOTSTRAP.md exists in the workspace, the bot should automatically start the flow. If it doesn't, prompt: *"Please read BOOTSTRAP.md and follow the first-run process."*

**If BOOTSTRAP.md was already deleted** (first conversation already happened), skip this step — you're already personalized.

Don't stress about getting answers perfect. Preferences evolve over time and you can always edit USER.md, SOUL.md, and IDENTITY.md directly.

- [ ] First conversation completed (bot asked personalization questions)
- [ ] USER.md, SOUL.md, IDENTITY.md updated with your preferences
- [ ] BOOTSTRAP.md deleted by the bot (confirms flow completed)

---

### 2.3 Enable Memory Flush Before Compaction

**Why:** When conversations get long, OpenClaw auto-compacts the context.
Without memoryFlush, the bot loses everything from that session.

**Add to `openclaw.json` under `agents.defaults.compaction`:**
```json
"compaction": {
  "mode": "safeguard",
  "memoryFlush": {
    "enabled": true,
    "softThresholdTokens": 180000,
    "prompt": "Summarize key facts, decisions, tasks, commitments, deadlines, and carry-forward items before compaction. Preserve: (1) Action items and todos, (2) Decisions made and their rationale, (3) Deadlines and scheduled events, (4) Commitments or promises made, (5) Context needed for next session, (6) Anything marked as 'remember this'"
  }
}
```

**IMPORTANT:** OpenClaw validates config with Zod and rejects unknown keys — if the gateway
refuses to start after adding this, check the field names against `openclaw config schema`
or the official docs. The field names above are based on a working Watson deployment but
may change between OpenClaw versions. When in doubt, use `openclaw doctor` to validate config.

- [ ] memoryFlush is enabled
- [ ] Flush prompt captures decisions, tasks, commitments, deadlines

---

### 2.4 Evaluate Persistent Memory Options

**Research (don't install yet):**
- Mem0: https://mem0.ai/blog/mem0-memory-for-openclaw — powerful but adds dependency
- Penfield: Hybrid search (BM25 + vector + graph)
- **File-based (recommended for most setups):** Human-readable, portable, no extra dependencies

- [ ] Researched options
- [ ] Owner decision: _______________

---

### 2.5 Establish Memory Writing Discipline

**Protocol for every session:**
1. **Session start:** Read MEMORY.md + today's daily log + SOUL.md
2. **During session:** After any decision or important discussion, write to `memory/YYYY-MM-DD.md` immediately
3. **Before ending:** Write session summary to daily log
4. **Weekly:** Consolidate daily logs into MEMORY.md, archive old details

- [ ] Bot confirms understanding of protocol
- [ ] First daily log created
- [ ] Protocol added to operating instructions

---

### Phase 2 Checkpoint

**STOP.** Before Phase 3:
1. Write Phase 2 findings to `memory/YYYY-MM-DD.md`
2. Update MEMORY.md with memory architecture (file locations, search provider, flush config)
3. Test that memory search returns results
4. Wait for owner approval

---

## Phase 3: Communication Channels

### Channel Architecture

**The recommended model** (customize from Configuration section):

| Channel | Role | Session Type |
|---------|------|-------------|
| Discord `{{discord_channels.general}}` | **Primary working channel** | Shared |
| Discord `{{discord_channels.logs}}` | Bot status updates (output only) | N/A |
| Discord topic channels | Isolated work per domain/project | Isolated |
| iMessage | Alerts only (if enabled) | Shared (lightweight) |
| Telegram | Secondary mobile access (if enabled) | Shared (lightweight) |
| Dashboard chat | Fallback / admin access | Shared |

**Why Discord as primary:**
- Rich formatting (code blocks, tables, markdown)
- Topic channels provide natural context isolation
- File sharing works properly
- Mobile app for on-the-go access
- Guild channels auto-isolate in OpenClaw (no extra config needed)

### 3.1 Set Up Discord as Primary (REQUIRES OWNER for channel creation)

**Research:**
- [ ] How does OpenClaw map Discord channels to sessions?
- [ ] Verify guild channels auto-isolate (they should in recent versions)

**Owner creates channels in Discord server settings:**
Based on the Configuration section, create each channel listed under `discord_channels`.

**OpenClaw config (`openclaw.json`):**
```json
"discord": {
  "enabled": true,
  "token": "{{discord_bot_token}}",
  "groupPolicy": "allowlist",
  "dm": {
    "policy": "pairing",
    "allowFrom": ["{{discord_owner_id}}"]
  },
  "guilds": {
    "{{discord_server_id}}": {
      "slug": "{{discord_server_name}}",
      "channels": {
        "CHANNEL_ID_HERE": { "allow": true, "requireMention": false }
      }
    }
  }
}
```

**How to get Discord channel IDs** (needed for the config above):
1. In Discord, go to Settings → Advanced → turn on **Developer Mode**
2. Right-click any channel → **Copy Channel ID** — it's a numeric ID like `1234567890123456789`
3. Replace `"CHANNEL_ID_HERE"` in the config with the actual ID
4. Repeat for each channel you want the bot to access

**IMPORTANT:** In Discord Developer Portal → OAuth2, configure these:
- **Scopes:** `bot` and `applications.commands`
- **Bot Permissions:** Send Messages, Read Message History, Embed Links, Attach Files, Add Reactions, Use Slash Commands

**IMPORTANT:** Enable these in Discord Developer Portal → Bot settings:
- Message Content Intent
- Server Members Intent
- Presence Intent

If Message Content Intent is NOT enabled, the gateway will log error 4014 and Discord
will fail to connect. In older versions (pre-2026.2.x), this crashed the entire gateway
every ~10 seconds, taking down ALL channels. Newer versions handle it more gracefully
(Discord fails but other channels continue), but the intent still must be enabled.

- [ ] Discord channels created
- [ ] OpenClaw config updated with channel IDs
- [ ] Discord intents enabled in Developer Portal
- [ ] Bot responds in primary channel
- [ ] Tested: messages in topic channels stay isolated

---

### 3.2 Verify Primary Channel Works

- [ ] Multi-turn conversation works
- [ ] Code blocks, markdown, and file attachments render properly
- [ ] Bot can reference previous messages
- [ ] Test with a specific fact: "[owner's pet's name] is my pet" — bot remembers later

---

### 3.3 Configure Alert Channels (iMessage / Telegram)

If `imessage.enabled` or `telegram.enabled` is true in Configuration:

- [ ] Alert channel is connected and can send outbound messages
- [ ] Bot understands: alert channels are for **notifications only**, not long conversations
- [ ] If owner sends a complex request via alert channel, bot responds briefly and suggests continuing in Discord

**Add to bot's operating rules:**
> When {{owner_name}} messages via iMessage/Telegram, respond concisely. For anything
> requiring detailed discussion, code, or structured output, reply: "Got it — I'll have
> the details ready in {{discord_channels.general}} on Discord."

---

### 3.4 Email Channel (if enabled)

- [ ] Email account is accessible
- [ ] Can list inbox
- [ ] Can draft and send (with approval)
- [ ] App password configured (if Gmail)

---

### Phase 3 Checkpoint

**STOP.** Before Phase 4:
1. Write Phase 3 summary to `memory/YYYY-MM-DD.md`
2. Update MEMORY.md with channel architecture
3. List anything blocked on owner
4. Wait for owner approval

---

## Phase 4: Proactive Automation (Cron Jobs & Heartbeat)

This is what makes the bot proactive instead of reactive.

**Important:** Cron jobs run in ISOLATED sessions — they do NOT share context
with the main conversation. Use file-based handoff (write to files the main session reads).

### 4.0 Cron Prerequisites — Known Bugs (Read First!)

**Bug 1: Ghost cron jobs after deletion**
Deleted jobs can keep running because recovery logic prefers orphaned `.tmp` files.
```bash
rm ~/.openclaw/cron/jobs.json.*.tmp 2>/dev/null
```
- [ ] Cleaned up any ghost tmp files

**Bug 2: HEARTBEAT.md must have content**
Cron jobs with `wakeMode: "now"` get silently skipped if HEARTBEAT.md is empty.
- [ ] HEARTBEAT.md has non-comment content

**Bug 3: "every" scheduling syntax is unreliable**
Use 5-field cron expressions (e.g., `*/30 * * * *`), NOT "every 30 minutes" syntax.

> **What's a cron expression?** It's a 5-part schedule format: `minute hour day-of-month month day-of-week`.
> Examples: `*/30 * * * *` = every 30 minutes, `0 8 * * 1-5` = 8 AM weekdays, `0 */2 * * *` = every 2 hours.
> Use [crontab.guru](https://crontab.guru) to build and test expressions — paste one in and it tells you in plain English when it fires.

- [ ] All cron jobs use 5-field cron expressions

**Bug 4: Gateway must be running**
Cron jobs don't execute if the gateway process isn't active.
- [ ] Gateway is running (`openclaw status --all`)

**Bug 5: Timezone mismatch**
```bash
date +%Z  # Should match your timezone from Configuration
```
- [ ] System timezone matches Configuration (`{{timezone}}`)

**Bug 6: Don't let the AI write cron jobs directly**
Configure cron jobs manually via dashboard or config file. The bot should DESIGN
the jobs (name, schedule, action, output location), then the owner deploys them.

---

### 4.1 API Health Monitor

**Purpose:** Detect API failures before they cause silent outages.

**Spec:**
```
Name: api-health-check
Schedule: 0 */2 * * * (every 2 hours)
Timezone: {{timezone}}
Type: isolated
Action:
  1. Test each configured API (from Q5 answers)
  2. If ANY fail: send alert to {{primary_channel}} + alert channels
  3. Write results to cron/health-checks.md
```

- [ ] Spec reviewed by owner
- [ ] Deployed and tested

---

### 4.2 Morning Briefing

**Spec:**
```
Name: morning-briefing
Schedule: 0 8 * * 1-5 (8 AM weekdays, adjust to your schedule)
Timezone: {{timezone}}
Type: isolated
Action:
  1. Check email for overnight messages (if email enabled)
  2. Read yesterday's memory log for carry-forward items
  3. Check calendar (if configured)
  4. Post briefing to {{discord_channels.general}}
  5. Send short summary to alert channels
  6. Write full briefing to cron/morning-briefing-YYYY-MM-DD.md
```

- [ ] Owner approves timing and content
- [ ] Deployed and tested

---

### 4.3 Email Check (if email enabled)

**Spec:**
```
Name: email-check
Schedule: */30 8-20 * * * (every 30 min during business hours)
Timezone: {{timezone}}
Type: isolated
Action:
  1. Check inbox
  2. Classify: trusted senders vs unknown
  3. Trusted: summarize, post to {{discord_channels.general}} if urgent
  4. Unknown: log silently
  5. Write to cron/email-log.md
Trusted senders: [FILL IN YOUR LIST]
```

- [ ] Owner provides trusted sender list
- [ ] Deployed (start with enabled: false, enable after testing)

---

### 4.4 Evening Memory Consolidation

**Spec:**
```
Name: evening-memory
Schedule: 0 21 * * * (9 PM daily, adjust to your preference)
Timezone: {{timezone}}
Type: isolated
Action:
  1. Read today's memory log
  2. Check for gaps in coverage
  3. Write carry-forward section for tomorrow
  4. Fridays: consolidate week into MEMORY.md
```

- [ ] Deployed and tested

---

### 4.5 Evaluate Heartbeat

**Heartbeat vs Cron:**
| Aspect | Heartbeat | Cron |
|--------|-----------|------|
| Timing | Flexible (~30 min, drifts) | Exact |
| Session | Main (shared context) | Isolated |
| Best for | Batched periodic checks | Precise scheduled tasks |

**Recommendation:** Use both. Cron for time-critical tasks, Heartbeat for flexible awareness.

- [ ] Owner decides: Enable Heartbeat / Cron only / Both

---

### Phase 4 Checkpoint

**STOP.** Before Phase 5:
1. Write Phase 4 summary to `memory/YYYY-MM-DD.md`
2. Update MEMORY.md with cron job inventory
3. Verify cron jobs actually fired at least once
4. Wait for owner approval

---

## Phase 5: Isolated Sessions (Architecture)

### 5.1 Document Session Architecture

Research and document:
- [ ] How OpenClaw defines session boundaries
- [ ] What triggers new vs continuing sessions
- [ ] How isolated sessions interact with shared memory
- [ ] How guild (Discord) channels map to sessions

---

### 5.2 Formalize Session Mapping

Based on Q4 answers and channel setup:

| Context | Session Type | Why |
|---------|-------------|-----|
| Discord `{{discord_channels.general}}` | Shared | Primary channel, needs continuity |
| Discord topic channels | Isolated | Domain-specific, prevents context pollution |
| Discord `{{discord_channels.logs}}` | Output only | Status updates, no input |
| iMessage / Telegram | Shared (lightweight) | Alerts, quick messages |
| All cron jobs | Isolated | Background tasks |

- [ ] Owner reviews and approves
- [ ] Configuration applied
- [ ] Tested: isolated sessions don't leak into shared context

---

### 5.3 File-Based Handoff Between Sessions

Isolated sessions can't see each other. Files bridge the gap.

**Handoff locations:**
```
~/.openclaw/workspace/
├── cron/
│   ├── health-checks.md          ← API health monitor writes here
│   ├── morning-briefing-DATE.md  ← Morning briefing writes here
│   ├── email-log.md              ← Email check writes here
│   └── error-log.md              ← Error monitor writes here
├── memory/
│   ├── YYYY-MM-DD.md             ← Daily logs
│   └── discord/                  ← Per-channel session summaries (optional)
└── MEMORY.md                     ← Long-term memory
```

- [ ] Handoff directory structure created
- [ ] Tested: cron writes, main session reads

---

### Phase 5 Checkpoint

**STOP.** Before Phase 6:
1. Write Phase 5 summary to `memory/YYYY-MM-DD.md`
2. Update MEMORY.md with session architecture and handoff file locations
3. Wait for owner approval

---

## Phase 6: Skill Installation & Verification

### 6.1 Install Owner's Approved Skills

**Where do skills come from?** Skills are folders containing a `SKILL.md` file and
optional scripts. Sources include:
- **Your own skills** — custom-built for your use case (safest)
- **Trusted community skills** — from people you know, verified source code
- **NEVER from ClawHub** without a full code review (see Phase 1.5 — 12% malware rate)

```bash
# Copy skills from owner's approved location (e.g., a git repo, iCloud folder, etc.)
cp -r /path/to/your/approved-skills/* ~/.openclaw/skills/

# Verify count
ls ~/.openclaw/skills/ | wc -l
```

- [ ] All approved skills copied
- [ ] Each has a valid SKILL.md with frontmatter
- [ ] Owner has reviewed the source code of every installed skill

### 6.2 Verify Skill Loading

```bash
openclaw skills list 2>/dev/null
```

- [ ] OpenClaw recognizes all installed skills
- [ ] No loading errors in logs
- [ ] Test one skill trigger

### 6.3 Add `requires` Fields

Skills that depend on external tools should declare them. Check your OpenClaw version's
expected format — older versions use a simple list, newer versions use `requires.bins`:
```json
"requires": { "bins": ["python3", "bash"] }
```
Or in SKILL.md YAML frontmatter (if supported by your version):
```yaml
requires:
  bins:
    - python3
    - bash
```

- [ ] Skills with dependencies have `requires` fields
- [ ] OpenClaw warns if a required tool is missing

### 6.4 Triage Domain-Specific Skills

Some skills may only be useful when working on specific projects.
- [ ] Identified which skills map to which projects
- [ ] Confirmed required repos/tools are available for active skills
- [ ] Dormant skills documented (harmless, will activate when prerequisites are met)

---

### Phase 6 Checkpoint

**STOP.** Before Phase 7:
1. Write Phase 6 summary to `memory/YYYY-MM-DD.md`
2. Update MEMORY.md with skill inventory
3. Wait for owner approval

---

## Phase 7: Monitoring & Resilience

### 7.1 Error Alerting

- [ ] Configure error log monitoring (cron job or heartbeat)
- [ ] Errors trigger: alert to {{discord_channels.logs}} + alert channels
- [ ] Spec designed and deployed

### 7.2 Status Dashboard

**Recommended: Use {{discord_channels.logs}} channel.**

Design what the bot posts and how often:
- Hourly heartbeat ("All systems OK" or specific issues)
- Cron job execution results
- Error summaries
- Daily stats (events, tasks completed, API usage)

- [ ] Posting schedule designed
- [ ] Mechanism deployed (cron job or heartbeat task)
- [ ] First status update posted

### 7.3 Document the Final Architecture

**Create `ARCHITECTURE.md` in workspace documenting:**
- All active channels and session types
- All cron jobs and schedules
- Memory file structure and handoff locations
- Installed skills inventory
- API integrations and health status
- Known limitations and workarounds

This is the single source of truth for debugging.

- [ ] ARCHITECTURE.md created
- [ ] Owner has reviewed it

---

### Phase 7 Checkpoint

**STOP.** Before Phase 8:
1. Write Phase 7 summary to `memory/YYYY-MM-DD.md`
2. Update MEMORY.md with monitoring setup
3. **HARD GATE: Do NOT start Phase 8 until Phases 1-7 have been stable for at least 1 full week.**
4. Wait for owner to explicitly approve Phase 8

---

## Phase 8: Multi-Agent Architecture (Optional — Advanced)

> **Hard gate:** Only start after 1 week of stability on Phases 1-7.
> Multi-agent on an unstable foundation wastes time and money.

### Multi-Agent Design Questionnaire

Before building anything, answer these questions. They define your multi-agent architecture.

#### 8.1 What specialists does your bot need?

Think about your bot's responsibilities (from Q1). Which ones would benefit from
a dedicated agent with its own context, memory, and skills?

**Good candidates for specialist agents:**
- Responsibilities that are noisy (lots of context that pollutes other work)
- Responsibilities that need deep domain knowledge
- Responsibilities that run on their own schedule
- Responsibilities where mistakes in one area shouldn't affect another

| Specialist | Responsibility | Discord Channel | Type |
|-----------|---------------|-----------------|------|
| ___________ | _________________________ | #____________ | Persistent / On-demand |
| ___________ | _________________________ | #____________ | Persistent / On-demand |
| ___________ | _________________________ | #____________ | Persistent / On-demand |

#### 8.2 What's the communication model?

```
{{bot_name}} (orchestrator)
  ├── Specialist A (____________)
  │     ├── Monitors: _______________
  │     ├── Writes to: memory/specialist-a/
  │     └── Alerts: {{discord_channels.logs}} + alert channels
  ├── Specialist B (____________)
  │     ├── Monitors: _______________
  │     ├── Writes to: memory/specialist-b/
  │     └── Reports to: {{bot_name}} via file handoff
  └── [On-demand workers] — spawned for complex requests
```

#### 8.3 What are the autonomy boundaries?

| Action | Orchestrator | Persistent Specialist | On-Demand Worker |
|--------|-------------|----------------------|------------------|
| Read files | Yes | Own directory only | Task-scoped only |
| Write files | Yes | Own dir + handoff | Output file only |
| Message owner | Yes | Urgent alerts only | No (reports to orchestrator) |
| Browse web | Yes | If in scope | If in scope |
| Spawn sub-agents | Yes | No | No |
| Install skills | Ask owner | No | No |

#### 8.4 What are the success criteria?

For each specialist, define how you'll know it's working:

| Specialist | Success Metric | Trial Period |
|-----------|---------------|--------------|
| ___________ | _________________________________ | 1 week |
| ___________ | _________________________________ | 1 week |

### Build Order (if proceeding)

**Start with ONE specialist.** Prove the pattern works before adding more.

**Recommended first specialist:** The one with the most bounded, verifiable responsibility
(email triage is a common choice — clear inputs, clear outputs, easy to verify).

1. Define specialist's SOUL.md (personality, scope, escalation rules)
2. Create its memory directory (`memory/specialist-name/`)
3. Configure as a separate agent
4. Connect to its Discord channel
5. Run for 1 week, assess
6. If stable: add second specialist
7. Repeat

**Anti-patterns to avoid:**
- Too many agents too fast (coordination overhead > productivity)
- Agents with overlapping scope (who handles what?)
- Agents that can't be observed (every agent must log actions)
- Agents that only communicate through the orchestrator (peer handoff is OK for specific cases)

**Cost governance:**
- [ ] Per-agent API spending limits set
- [ ] Orchestrator tracks total team spend
- [ ] Kill switch defined (orchestrator can shut down any agent)
- [ ] Weekly cost report planned

---

## Completion Checklist

| Phase | Status | Verified By |
|-------|--------|-------------|
| 1. Security Hardening | [ ] Complete | Bot + Owner |
| 2. Memory & Persistence | [ ] Complete | Bot |
| 3. Communication Channels | [ ] Complete | Bot + Owner |
| 4. Proactive Automation | [ ] Complete | Bot + Owner |
| 5. Isolated Sessions | [ ] Complete | Bot + Owner |
| 6. Skill Installation | [ ] Complete | Bot |
| 7. Monitoring & Resilience | [ ] Complete | Bot + Owner |
| 8. Multi-Agent (Optional) | [ ] Complete | Bot + Owner |

**When all phases are complete:** Bot posts a full summary to {{discord_channels.general}}
and sends a short alert to confirm the foundation is solid.

---

## Appendix: Community-Sourced Gotchas

These are the most common issues reported by the OpenClaw community. They're
addressed throughout the playbook but collected here for quick reference.

1. **memorySearch disabled by default** — the biggest "aha moment" (Phase 2.1)
2. **Mac sleep kills all cron jobs silently** — must disable system sleep (Phase 1.11)
3. **Ghost cron job .tmp files** — deleted jobs keep running (Phase 4.0)
4. **HEARTBEAT.md empty file bug** — cron jobs silently skipped (Phase 4.0)
5. **"every" cron syntax unreliable** — use 5-field expressions (Phase 4.0)
6. **Don't let AI write its own cron configs** — configure manually (Phase 4.0)
7. **Treat agent like a new employee** — be explicit about everything (Phase 2.5)
8. **Discord Message Content Intent** — must be enabled or Discord fails to connect (Phase 3.1)
9. **Node.js IPv6/IPv4 with Ollama** — use `127.0.0.1` not `localhost` (Phase 2.1)
10. **Evening memory consolidation** — prevents compaction data loss (Phase 4.4)
11. **Timezone mismatch** — cron jobs fire at wrong times (Phase 4.0)
12. **Credentials dir at 755** — should be 700 (Phase 1.2)
13. **MEMORY.md is private-session only** — not loaded in group/channel contexts (Phase 2.2)
14. **Config validation rejects unknown keys** — Zod schema validation will crash gateway on typos (Phase 2.3)
15. **AGENTS.md is the most important workspace file** — controls agent behavior, loaded every session (Phase 2.2)
16. **Reverse proxy auth bypass** — CVE-2026-25253 exploit chain includes this (Phase 1.9)
17. **Cron jobs consume tokens** — 28+ sessions/day adds up fast, set spending limits first (Phase 1.8)
18. **"Hacker News" content filter bug** — SystemEvents containing this text are silently dropped (GitHub #2081)
19. **macOS auto-updates restart the machine** — sleep prevention doesn't cover update restarts; disable auto-install separately (Phase 1.11)
20. **Discord rate limiting** — too many messages from cron + heartbeat + alerts can get the bot rate-limited or temporarily banned by Discord; space out message sending
21. **File-based handoff race conditions** — cron job writing to a file while the main session reads it can produce a partial/corrupt read; use atomic writes (write to `.tmp`, then `mv` to final name)
22. **Always backup `openclaw.json` before editing** — a single JSON syntax error crashes the gateway; the playbook has you edit this file 3+ times (Phase 2 safety note)
23. **Sandbox containers have no network by default** — enabling Docker sandbox (`"non-main"` or `"all"`) creates containers with `network: "none"`. Your bot won't be able to browse the web, call APIs, or install packages unless you explicitly set `sandbox.docker.network` (Phase 1.12)
24. **`openclaw doctor --fix` applies changes without asking** — it auto-repairs config issues silently. If you want to review before fixing, run `openclaw doctor` first (without `--fix`), review the output, then decide (Phase 1.3)
25. **The onboarding wizard preserves existing config on re-run** — you can safely re-run `openclaw onboard` to reconfigure channels or auth without losing your existing setup, unless you explicitly choose Reset

---

## Research Sources

- **Official docs:** docs.openclaw.ai (memory, cron, skills, compaction, troubleshooting, security)
- **Security advisories:** CrowdStrike, Cisco, The Register, Koi Security, Trend Micro, VirusTotal, SOCRadar, Adversa AI
- **CVEs:** NVD (CVE-2026-25253, CVE-2026-25157)
- **Skill audits:** Koi Security (ClawHavoc, 341 malicious skills), Snyk (ToxicSkills, 13.4% critical), SC Media
- **Reddit:** r/openclaw, r/clawdbot, r/AI_Agents, r/LocalLLaMA, r/myclaw
- **X/Twitter:** @benjaminsehl, @ivaavimusic, @herbertyang, @chris_cozmos, @AxiomBot, @svpino
- **Web:** Medium, freeCodeCamp, Codecademy, GitHub issues, DeepWiki, snowan.gitbook.io
- **GitHub issues:** #2217 (HEARTBEAT.md bug), #2081 (content filter bug), PR #5564 (4014 fix), PR #3335 (ghost cron fix)

---

*Generated from Watson Foundation Playbook v3. Adapted as a general-purpose template.*
