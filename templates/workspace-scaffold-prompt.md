<!-- OpenClaw Setup Package - Workspace Scaffold Prompt
     Paste this into your bot's first conversation if you didn't
     run openclaw-autosetup.sh and aren't following the Foundation Playbook. -->

# Workspace Scaffold + First-Run Setup

Please set up my workspace with the standard template files and then walk me through first-run personalization. Follow these steps exactly:

## Step 1: Create Workspace Subdirectories

```bash
mkdir -p ~/.openclaw/workspace/memory
mkdir -p ~/.openclaw/workspace/cron
mkdir -p ~/.openclaw/workspace/plans
mkdir -p ~/.openclaw/workspace/scripts
```

## Step 2: Copy Template Files

Check if the template directory exists at `~/Downloads/openclaw-setup/templates/workspace/`. If it does:

- Copy all `.md` files from that directory into `~/.openclaw/workspace/`
- **Do not overwrite** any files that already exist — only copy missing ones
- Report which files were created and which already existed

If the template directory does NOT exist, create these minimal files in `~/.openclaw/workspace/`:

**AGENTS.md:**
```
# Agent Operating Instructions

You are a helpful AI assistant. Operate with care and always ask before taking actions that affect external systems.

See the OpenClaw Foundation Playbook for detailed operating guidelines.
```

**MEMORY.md:**
```
# Memory

This file stores persistent knowledge across sessions. Update after important decisions or events.
```

**USER.md:**
```
# User Profile

[To be filled in during first-run personalization]
```

**IDENTITY.md:**
```
# Agent Identity

[To be filled in during first-run personalization]
```

**SOUL.md:**
```
# Operating Personality

[To be filled in during first-run personalization]
```

## Step 3: Create Today's Daily Log

Create `~/.openclaw/workspace/memory/YYYY-MM-DD.md` (using today's date) with this content:

```
# YYYY-MM-DD

## Session Notes

```

Only create this if it doesn't already exist.

## Step 4: First-Run Personalization

Now walk me through personalizing the workspace. Ask me these questions one at a time (or let me answer several at once — whatever feels natural):

1. **What should I call you?** (my name for you — examples: Claude, Atlas, Echo)
2. **What kind of personality appeals to you?** (formal, casual, quirky, direct, warm, etc.)
3. **Pick an emoji that feels right for me** (for logs and messages — examples: 🤖 🧠 ⚡ 🌙)
4. **How should I communicate?** (brief vs detailed, formal vs casual, ask-first vs try-first)
5. **What's your name?** (how I'll refer to you)
6. **What's your timezone?** (IANA format, e.g., America/New_York)
7. **What do you primarily use this bot for?**
8. **What does success look like?** (what would make this agent genuinely helpful)
9. **Any other preferences?** (proactive vs reactive, quiet channels, technical preferences)

After I answer:
- Update **IDENTITY.md** with the bot name, emoji, and self-concept
- Update **SOUL.md** with the personality framework and communication style
- Update **USER.md** with my name, timezone, use case, success criteria, and preferences
- Update **HEARTBEAT.md** (if it exists) with my timezone for daily check-in scheduling
- **Delete BOOTSTRAP.md** if it exists (signals that first-run is complete)

Then confirm what you've set up and remind me that I can edit these files anytime as my preferences evolve.
