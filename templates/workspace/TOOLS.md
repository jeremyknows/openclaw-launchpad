<!-- OpenClaw Setup Package - Workspace Template
     This file is part of the OpenClaw Setup Package.
     Fill in the sections below to document your environment-specific
     infrastructure. This helps the bot understand what services are
     available and how to use them. -->

# Tools and Infrastructure

This file documents the external services, APIs, communication channels, and devices
available in this environment. The bot reads this file to understand what it can
connect to and how.

---

## API Providers

List the AI and utility providers configured for this bot.

| Provider | Purpose | Key Prefix | Spending Limit | Dashboard |
|----------|---------|------------|---------------|-----------|
| OpenRouter | Primary AI models | `sk-or-v1-` | $___/month | openrouter.ai |
| Anthropic | Premium fallback | `sk-ant-` | $___/month | console.anthropic.com |
| Voyage AI | Memory search embeddings | `pa-` | ~$0-5/month | dash.voyageai.com |

> Add or remove rows as needed. Never put actual API keys in this file — just note
> which providers are configured and their purpose.

---

## Communication Channels

List the channels the bot uses to communicate.

| Channel | Role | Session Type | Notes |
|---------|------|-------------|-------|
| Discord `#general` | Primary workspace | Shared | Main conversations |
| Discord `#bot-logs` | Status updates | Output only | Bot posts here |
| Dashboard | Fallback / admin | Shared | http://127.0.0.1:18789 |

> Add topic channels, iMessage, Telegram, email, or other channels as configured.
> See AGENTS.md for session isolation rules.

---

## Connected Devices

List any hardware or services the bot has access to.

| Device / Service | Access | Notes |
|-----------------|--------|-------|
| Mac (host machine) | Full (via bot user) | Dedicated user account |

> Examples of things to add: smart home APIs, network-attached storage, printers,
> IoT devices, calendar services, etc.

---

## Custom Tools

List any custom skills, scripts, or integrations available to the bot.

| Tool | Location | Purpose | Requires |
|------|----------|---------|----------|
| (none yet) | | | |

> As you install skills (Foundation Playbook Phase 6) or build custom integrations,
> document them here. Include the skill's location, what it does, and any
> dependencies it needs (e.g., `python3`, `ffmpeg`).

---

## Environment Variables

List any environment variables the bot depends on (names only, not values).

| Variable | Purpose | Set in |
|----------|---------|--------|
| `PATH` | Includes `~/.openclaw/bin` | `~/.zshrc` |

> If you set `OPENCLAW_HOME` for a non-standard config location, document it here.

---

*This file is optional but recommended. Keep it updated as your infrastructure evolves.*
