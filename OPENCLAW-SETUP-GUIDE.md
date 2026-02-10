# OpenClaw Setup Guide — From Zero to Running Gateway

> **Version:** 1.1 (2026-02-09)
> **Audience:** Non-technical founders who want a personal AI agent on a dedicated Mac.
> **Time:** 45-90 minutes. 8 steps — all admin work in Step 1, then you switch
> to the bot user and stay there.
> **What you'll have at the end:** A running AI agent you can talk to via Discord
> or the browser dashboard.
>
> **Already have OpenClaw installed?** Skip to the
> [Foundation Playbook](OPENCLAW-FOUNDATION-PLAYBOOK-TEMPLATE.md) for hardening
> and configuration.
>
> **Want the fast path?** Run `bash openclaw-autosetup.sh --minimal` for automated
> setup that handles ~80% of the work. See [Quick Setup](#quick-setup) below.

---

## Quick Setup

For users comfortable with Terminal, the autosetup script handles most of the work:

```bash
# Minimal setup (gateway only, no Discord)
bash openclaw-autosetup.sh --minimal

# Full interactive setup (all services, guided prompts)
bash openclaw-autosetup.sh

# Resume after interruption
bash openclaw-autosetup.sh --resume
```

The script automates environment detection, installation, permissions, sleep prevention,
and verification. Human checkpoints pause for steps that need browser interaction (API keys,
Discord portal). Logs are saved to `~/.openclaw/autosetup-TIMESTAMP.log`.

After the script completes, run the verification script:
```bash
bash openclaw-verify.sh
```

**Prefer the manual path?** Continue reading below for the step-by-step walkthrough.

---

## What Is OpenClaw?

OpenClaw is an open-source AI agent framework. It turns an LLM (like Claude or GPT)
into a persistent assistant that lives on your machine, connects to your chat apps
(Discord, iMessage, Telegram, WhatsApp), reads email, browses the web, runs scheduled
tasks, and remembers conversations across sessions.

Think of it as giving an AI a body — your Mac Mini becomes the brain, and chat apps
become the mouth and ears.

**What makes it different from ChatGPT or Claude.ai:**
- It runs 24/7 on YOUR hardware, not in a browser tab
- It can be proactive — checking email, posting morning briefings, monitoring things
- It has persistent memory across conversations
- It connects to multiple chat platforms simultaneously
- It can run code, browse the web, and interact with APIs

**The trade-off:** All that power means real security responsibility. The Foundation
Playbook (the next document after this one) handles hardening. This guide just gets
you to a running gateway.

---

## What You'll Need

- **A Mac** (Mac Mini M4 recommended for 24/7 use — ~$600)
- **An AI provider account** — we recommend [OpenRouter](https://openrouter.ai) ($5-50/mo)
- **Terminal** — you'll paste commands into Terminal.app
- **30-90 minutes** — depending on how fast you move

> **Not on a Mac?** Linux and cloud VMs work too — see [docs.openclaw.ai/install](https://docs.openclaw.ai/install).

Create your accounts now so you're ready for Step 4:
1. **[OpenRouter](https://openrouter.ai)** — sign up and add $5-10 in credits
2. **[Discord](https://discord.com)** — if you want your bot in Discord (recommended)
3. **[Voyage AI](https://www.voyageai.com)** — optional, for memory search (~$0-5/mo)

---

## Before You Start: Understand the Risks

Running an AI agent on your Mac is powerful, but it comes with real security
responsibilities. Here are the four main risks and how this guide addresses each one:

> **Host risk — the bot can run commands on your Mac.**
> An AI agent isn't just a chatbot — it can execute shell commands, read files, and
> browse the web. That's what makes it useful, but it also means a misbehaving agent
> could delete files or change settings. **How we address it:** You'll create a separate
> macOS user account (Step 1). The bot literally cannot touch your personal files,
> Keychain, or browser data.

> **Agency risk — the bot might take unintended actions.**
> AI agents sometimes misinterpret instructions or take actions you didn't expect —
> like sending a message you didn't approve or modifying the wrong file.
> **How we address it:** Access profiles (Explorer, Guarded, Restricted) let you control
> what tools the bot can use. Start with Explorer + manual approval, then loosen over
> time as trust builds.

> **Credential risk — API keys stored in config could be stolen.**
> Your config file contains API keys that cost real money if misused.
> **How we address it:** File permissions (`chmod 600/700`) lock down the config so only
> the bot user can read it. Spending limits on every provider cap your exposure. The
> Foundation Playbook covers 90-day key rotation.

> **Persistent memory risk — payloads can hide in memory files.**
> The bot reads MEMORY.md files at the start of every session. If someone (or something)
> injects malicious instructions into a memory file, the bot will follow them next time
> it wakes up — a "time bomb" attack. **How we address it:** The separate user account
> prevents other users from writing to memory files. The Foundation Playbook covers
> periodic memory audits and the `openclaw security audit --deep` command.

These aren't hypothetical — they're the same risks flagged by CrowdStrike and Cisco
in their AI agent security advisories. The good news: this guide and the Foundation
Playbook address all four. Just follow the steps.

---

## Step 1: Prepare Your Mac (15 min, admin account)

> **Everything in this step happens on your normal admin account.** You'll
> switch to the bot user at the end and stay there for the rest of the guide.

### 1a: Create a Bot User

Your bot will be able to browse the web, run code, and access files. A separate
macOS user means it literally *cannot* touch your personal files, Keychain, or
browser history. This is the most important security step.

1. Open **System Settings** → **Users & Groups**
2. Click the **+** button to add a new user
3. Fill in:
   - **Name:** Your bot's name (e.g., "Maverick", "Atlas", "Watson")
   - **Account name:** Lowercase version (e.g., "maverick") — this becomes the macOS username
   - **Password:** Set a strong password and save it somewhere secure
   - **Account type:** Standard (NOT Administrator)
4. Click **Create User**
5. **Log into the new account once** (to initialize the home directory), then switch back

### 1b: Lock Down Home Directories

Still on your admin account, open Terminal and run both commands:
```bash
# Prevent the bot from reading YOUR files
sudo chmod 700 /Users/$(whoami)

# Prevent anyone from reading the bot's files
chmod 700 /Users/YOUR_BOT_USERNAME
```
Replace `YOUR_BOT_USERNAME` with whatever you named the bot account (e.g., `maverick`).

> `chmod 700` = "only the owner of this folder can access it." By default,
> macOS lets any local user browse your home directory — this closes that gap.

### 1c: Keep Your Mac Awake

If your Mac sleeps, the bot stops. This is the #1 reason agents "randomly stop working."

```bash
sudo pmset -a sleep 0 standby 0 hibernatemode 0 powernap 0 displaysleep 15 disksleep 0
```

> This tells your Mac: never go to sleep, but turn the screen off after 15
> minutes to save energy. The bot keeps running either way.

Also prevent macOS from auto-restarting for updates (which kills the bot):
```bash
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool FALSE
```

### 1d: Copy Setup Files to the Bot User

These setup files are on your admin account. The bot user needs them too (especially the autosetup script). Copy them over before switching:

```bash
sudo cp -R ~/Downloads/openclaw-setup /Users/YOUR_BOT_USERNAME/Downloads/
sudo chown -R YOUR_BOT_USERNAME /Users/YOUR_BOT_USERNAME/Downloads/openclaw-setup
```

The first command copies this folder to the bot user's Downloads. The second makes the bot user the owner of the copy.

### 1e: Enable macOS Firewall

Security researchers (Censys) found over 30,000 AI agent instances exposed to the
internet — meaning anyone could connect to them. Your bot only needs *outbound*
connections (to call AI providers). Block all inbound connections:

```bash
# Enable the macOS firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Enable stealth mode (your Mac won't respond to network probes)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
```

> **Stealth mode** makes your Mac invisible to port scanners. It won't respond to
> ping requests or connection attempts from unknown sources. The bot's outbound
> connections (API calls, Discord, etc.) still work normally.

You can verify the firewall is on in **System Settings → Network → Firewall**.

### 1f: Switch to the Bot User

You're done with admin tasks. Switch to the bot user for the rest of the guide:
- **Fast User Switching:** System Settings → Control Center → Show in Menu Bar
- Or just **log out** and log back in as the bot user

Then open this guide again from the bot user's copy.

> **Everything from here runs as the bot user, not your admin account.**

---

## Check: macOS Privacy Permissions (TCC)

macOS has a built-in privacy system called **TCC** (Transparency, Consent, and Control).
It controls which apps and users can access your camera, microphone, files, screen
recording, and more. Even with a separate bot user, macOS might grant permissions if
someone clicks "Allow" on a system dialog.

**What to check:**

Go to **System Settings → Privacy & Security** and review each category for the bot
user. The bot user should have **zero grants** — with one possible exception:

| Permission | Should be granted? | Why |
|-----------|-------------------|-----|
| Full Disk Access | **Only if using iMessage** | iMessage databases are in a protected location |
| Accessibility | **No** | Allows keylogging and UI automation |
| Screen Recording | **No** | Allows capturing screen content |
| Camera / Microphone | **No** | Not needed for a text-based bot |
| Files and Folders | **No** (workspace access is automatic) | The bot already has access to its own home directory |
| Automation | **No** (unless a specific skill needs it) | Allows controlling other apps |

> **Rule of thumb:** If a macOS dialog pops up asking for permission while the bot is
> running, **deny it** and investigate. The bot should never need camera, microphone,
> screen recording, or accessibility access. If you see unexpected grants, revoke them
> immediately.

---

## Step 2: Install Node.js (5 min)

The bot user needs Node.js 22 or newer.

**Check if Node.js is already installed:**
```bash
node --version
```

If it shows `v22.x.x` or higher, skip to Step 3.

**Install Node.js:**

The simplest method on macOS:
```bash
# Install Homebrew first (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js 22
brew install node@22
```

**Verify:**
```bash
node --version   # Should show v22.x.x or higher
npm --version    # Should show 10.x.x or higher
```

> **Alternative:** If you don't want Homebrew, download the macOS installer from
> [nodejs.org](https://nodejs.org). Pick the "LTS" version (22.x).

---

## Step 3: Install OpenClaw (5 min)

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

**Verify:**
```bash
openclaw --version
```

You should see something like `OpenClaw 2026.x.x`. If the version is older than
**2026.1.29**, you're vulnerable to known security issues. Update immediately:
```bash
openclaw update
```

> **Why version matters:** Versions before 2026.1.29 had serious security bugs
> that have been fixed. Version 2026.2.9+ adds additional safety features.
> The Foundation Playbook covers the details (CVE-2026-25253, CVE-2026-25157).

---

## Step 4: Get Your API Keys Ready (10 min)

API keys let OpenClaw talk to AI models. You'll paste them into the wizard in the
next step. If you already created accounts in "What You'll Need," just grab your keys.

> **Which provider should I pick?** Start with **OpenRouter** — it's one key for 100+
> models, and the default model (Kimi K2.5) is budget-friendly. Add Anthropic later
> if you want premium quality for complex tasks. You can switch anytime.

### OpenRouter (recommended)

1. Go to [openrouter.ai](https://openrouter.ai)
2. Sign up or log in
3. **Add credits** ($5-10 to start)
4. Go to **API Keys** → **Create Key**
5. Copy the key (starts with `sk-or-v1-...`)
6. **Set a spending limit** in Settings (e.g., $10-25/month)

> Default model: `openrouter/moonshotai/kimi-k2.5` — budget-friendly and capable.

### Anthropic (optional premium fallback)

1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Sign up or log in
3. Go to **Billing** → Add at least $5 in credits to start
4. Go to **API Keys** → **Create Key**
5. Copy the key (starts with `sk-ant-...`) — you'll only see it once
6. **Set a spending limit:** Billing → Limits → Set monthly limit (e.g., $25)

### Voyage AI (for memory search — recommended)

1. Go to [voyageai.com](https://www.voyageai.com)
2. Sign up → Get an API key
3. Copy the key (starts with `pa-...`)

> **Store keys securely.** Use a password manager (1Password, Bitwarden) or at minimum
> a local file with restricted permissions (`chmod 600`). Never put API keys in
> shared documents, Slack messages, or emails.

---

## Step 5: Run the Onboarding Wizard (15 min)

This is where OpenClaw sets itself up. The wizard walks you through everything
interactively.

```bash
openclaw onboard --install-daemon
```

The wizard will ask about:

1. **Model/Auth** — Paste your API key, choose your default model
   - Recommended: `openrouter/moonshotai/kimi-k2.5` (budget-friendly default)
   - Premium fallback: `anthropic/claude-sonnet-4-5` or `anthropic/claude-opus-4-6`

2. **Workspace** — Where the bot stores its files
   - Default `~/.openclaw/workspace` is fine for most people

3. **Gateway** — The background service that keeps the bot alive
   - Default port 18789 is fine
   - Token auth will be auto-generated — save the displayed token

4. **Channels** — Which chat apps to connect
   - For now, just enable Discord (or whichever you're using)
   - You can add more channels later

5. **Daemon** — Installs a LaunchAgent so the gateway starts automatically
   - Say **yes** — this is what keeps your bot running 24/7

6. **Health check** — The wizard verifies everything works

7. **Skills** — Optional add-ons
   - You can skip this for now — the Foundation Playbook covers skills

> **If something goes wrong during the wizard:** You can safely re-run
> `openclaw onboard` — it preserves existing config and only changes what you
> explicitly update.

---

## Step 6: Verify the Gateway (2 min)

```bash
openclaw gateway status
```

You should see:
- `Service: LaunchAgent (loaded)`
- `Runtime: running`
- `RPC probe: ok`

If it says "not running," try:
```bash
openclaw gateway restart
```

Still not working? Check the logs:
```bash
tail -20 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

**Open the dashboard** to verify you can chat with your bot:
```bash
openclaw dashboard
```

This opens a browser window at `http://127.0.0.1:18789/`. Type a message — if the
bot responds, your gateway is working.

---

## Step 7: Create a Discord Bot (15 min)

> **Skip this step** if you're using a different primary channel (Telegram, WhatsApp, etc.)
> or just using the dashboard for now.

Discord is the recommended primary channel because it supports rich formatting,
topic channels for context isolation, file sharing, and a mobile app.

### 7a: Create a Discord Server

If you don't already have one:
1. Open Discord → Click the **+** icon on the left sidebar
2. Choose **Create My Own** → **For me and my friends**
3. Name it (e.g., "Maverick HQ")
4. Create channels: `#general`, `#bot-logs`, and any topic channels you want

### 7b: Create a Discord Bot Application

1. Go to [discord.com/developers/applications](https://discord.com/developers/applications)
2. Click **New Application** → Name it (your bot's name)
3. Go to **Bot** in the left sidebar:
   - Click **Reset Token** → Copy the token (save it securely — you won't see it again)
   - Enable **Message Content Intent** (CRITICAL — without this, the bot can't read messages)
   - Enable **Server Members Intent**
   - Enable **Presence Intent**
4. Go to **OAuth2** → **URL Generator**:
   - Scopes: check `bot` and `applications.commands`
   - Bot Permissions: check `Send Messages`, `Read Message History`, `Embed Links`,
     `Attach Files`, `Add Reactions`, `Use Slash Commands`
   - Copy the generated URL
5. Paste the URL in your browser → Select your server → **Authorize**

The bot should now appear in your server (offline — we'll connect it next).

### 7c: Get Channel IDs

1. In Discord: **Settings** → **Advanced** → Turn on **Developer Mode**
2. Right-click each channel you want the bot in → **Copy Channel ID**
3. Save these — you'll need them for the config

### 7d: Get Your User ID and Server ID

- Right-click the **server name** → **Copy Server ID** (this is the Guild ID)
- Right-click **your own name** → **Copy User ID** (for the DM allowlist)

### 7e: Add Discord to OpenClaw Config

Edit `~/.openclaw/openclaw.json` and add the Discord channel config. **Back up first:**
```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup
```

Add this under the `"channels"` section (replace the placeholder values):
```json
"discord": {
  "enabled": true,
  "token": "YOUR_BOT_TOKEN_HERE",
  "groupPolicy": "allowlist",
  "dm": {
    "policy": "pairing",
    "allowFrom": ["YOUR_DISCORD_USER_ID"]
  },
  "guilds": {
    "YOUR_SERVER_ID": {
      "slug": "your-server-name",
      "channels": {
        "GENERAL_CHANNEL_ID": { "allow": true, "requireMention": false },
        "BOT_LOGS_CHANNEL_ID": { "allow": true, "requireMention": false }
      }
    }
  }
}
```

**Validate your config:**
```bash
openclaw doctor
```

If doctor reports errors, your JSON probably has a syntax issue. Common mistakes:
- Missing comma between items
- Trailing comma after the last item in a list
- Using single quotes instead of double quotes

If stuck, restore your backup: `cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json`

### 7f: Restart and Test

```bash
openclaw gateway restart
```

Wait 5 seconds, then check:
```bash
openclaw health
```

You should see `Discord: ok (@YourBotName)`. Send a message in your `#general`
channel — the bot should respond.

---

## Step 8: Final Check (2 min)

Lock down your config file (it contains API keys) and run the diagnostic:
```bash
chmod 600 ~/.openclaw/openclaw.json
chmod 700 ~/.openclaw/
openclaw doctor
```

> `chmod 600` = only you can read this file. `chmod 700` = only you can enter
> this folder. This protects your API keys from other users on the Mac.

You want to see:
- No critical issues
- Your channels showing connected
- Gateway running

If `openclaw doctor` reports issues, address them before continuing.

---

## You Did It

Your AI agent is alive. Here's what you have:

- A dedicated Mac user (security boundary — the bot can't touch your files)
- OpenClaw installed with a running gateway (auto-starts on reboot)
- At least one AI provider connected
- A communication channel working (Discord, dashboard, or other)
- Mac locked down (sleep prevention, directory permissions, config protection)

**Your bot is running 24/7.** You can close this guide.

---

## What's Next (Optional)

The **[Foundation Playbook](OPENCLAW-FOUNDATION-PLAYBOOK-TEMPLATE.md)** makes your
bot smarter and more secure over time. It's 8 phases — **do one per week at your
own pace.** Only Phase 1 (security audit) is urgent.

| Phase | What It Adds | Priority |
|-------|-------------|----------|
| 1. Security Hardening | Audit keys, verify isolation | Do this week |
| 2. Memory & Persistence | Bot remembers across conversations | High — this is the "wow" moment |
| 3. Communication Channels | Multi-channel setup | When ready |
| 4. Proactive Automation | Morning briefings, email checks | When ready |
| 5. Isolated Sessions | Separate contexts per topic | When ready |
| 6. Skill Installation | New capabilities (carefully) | When ready |
| 7. Monitoring | Error alerts, status dashboard | When ready |
| 8. Multi-Agent | Specialist bots (advanced) | Optional |

---

## Troubleshooting Quick Reference

| Problem | Fix |
|---------|-----|
| `openclaw: command not found` | Restart terminal, or add to PATH: `export PATH="$HOME/.openclaw/bin:$PATH"` |
| Gateway won't start | `openclaw doctor` → fix reported issues |
| Gateway starts then stops | Check both `/tmp/openclaw/` and `~/.openclaw/logs/` for log files |
| Discord shows offline | Check token, verify intents are enabled in Discord Developer Portal |
| Discord error 4014 | Message Content Intent not enabled (Developer Portal → Bot → toggle on) |
| Bot doesn't respond | Check channel is allowlisted in config, `requireMention` is `false` |
| `node: command not found` | Install Node.js 22+ (see Step 2) |
| Config validation error | Restore backup: `cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json` |
| Multiple issues at once | Run `openclaw doctor --fix` to auto-repair common problems (review output after) |

> **Advanced: Non-standard home directories.** If your OpenClaw config isn't in the
> default `~/.openclaw/` location (e.g., you're using a shared drive or custom path),
> set the `OPENCLAW_HOME` environment variable in your shell profile:
> ```bash
> export OPENCLAW_HOME="/path/to/your/openclaw"
> ```
> Add this line to `~/.zshrc` to make it permanent. Available in v2026.2.9+.

**For more help:**
- Official docs: [docs.openclaw.ai](https://docs.openclaw.ai)
- Troubleshooting: [docs.openclaw.ai/help/troubleshooting](https://docs.openclaw.ai/help/troubleshooting)
- Gateway issues: [docs.openclaw.ai/gateway/troubleshooting](https://docs.openclaw.ai/gateway/troubleshooting)

---

## Break Glass: Emergency Shutdown

If something goes wrong — the bot is acting strangely, spending is out of control,
or you just need to stop everything immediately — follow these five steps.

### 1. Kill the Process

```bash
killall openclaw
```

This stops the gateway, disconnects all channels, and halts all cron jobs. If that
doesn't work: `pkill -9 -f openclaw`

### 2. Save the Logs

Before investigating, copy the logs so you don't accidentally lose them:

```bash
# Save gateway logs from both locations
cp -r /tmp/openclaw/ ~/openclaw-incident-$(date +%Y%m%d)/
cp -r ~/.openclaw/logs/ ~/openclaw-incident-$(date +%Y%m%d)/app-logs/
```

### 3. Disable Your API Keys

Go to each provider's dashboard and disable or delete the compromised keys:

- **OpenRouter:** https://openrouter.ai/settings/keys
- **Anthropic:** https://console.anthropic.com/settings/keys
- **Discord:** https://discord.com/developers/applications (Bot → Reset Token)
- **Voyage AI:** https://dash.voyageai.com/api-keys

> Disabling keys stops any further API charges immediately, even if the process
> is somehow still running.

### 4. Review Recent Activity

Check the saved logs to understand what happened:

```bash
# Look at the most recent gateway log
ls -t ~/openclaw-incident-*/openclaw-*.log | head -1 | xargs tail -100
```

Look for: unexpected commands, unusual API calls, errors you don't recognize,
or actions the bot took that you didn't request.

### 5. Restart When Ready

Once you understand what happened and have fixed the issue:

```bash
# Generate new API keys from provider dashboards, update config
nano ~/.openclaw/openclaw.json

# Restart the gateway
openclaw gateway start
```

If you're not sure what went wrong, reach out to the OpenClaw community before
restarting: [docs.openclaw.ai/help](https://docs.openclaw.ai/help)

---

## Glossary

| Term | What It Means |
|------|---------------|
| **Gateway** | The background process that keeps your bot alive. Think of it as the bot's "engine." |
| **LaunchAgent** | macOS's way of running programs in the background. It auto-restarts the gateway if it crashes or after a reboot. |
| **Channel** | A chat platform connection (Discord, iMessage, Telegram, etc.) |
| **Session** | A conversation context. Each session has its own memory of what was discussed. |
| **Workspace** | The folder where your bot stores its files, memory, and configuration. Default: `~/.openclaw/workspace/` |
| **Cron job** | A scheduled task that runs automatically (e.g., "check email every 30 minutes"). |
| **Skill** | A plugin that gives the bot new capabilities (e.g., "summarize YouTube videos"). |
| **MEMORY.md** | The bot's long-term memory file. Loaded at the start of private sessions. |
| **AGENTS.md** | The bot's operating instructions. Loaded every session. |
| **Sandbox** | Optional Docker-based isolation that restricts what the bot can access on your machine. |
| **Token** | An authentication credential. The gateway token lets you access the dashboard; API tokens let the bot call AI providers. |

---

*Companion to the [OpenClaw Foundation Playbook](OPENCLAW-FOUNDATION-PLAYBOOK-TEMPLATE.md).
Both documents are based on real-world deployment experience and community-sourced lessons.*
