<!-- OpenClaw Setup Package - Workspace Template
     This file is part of the OpenClaw Setup Package.
     Personalize this file during your first session with BOOTSTRAP.md
     or manually edit the [bracketed] placeholders. -->

# Long-Term Memory: Critical Context and Evolution

This file is my long-term knowledge base. It persists across sessions and grows over time. I check this file at the start of every session to load critical context, and I consolidate daily notes into these sections weekly.

---

## Critical Rules

**Security and Safety Constraints:**
- [To be filled: any non-negotiable rules about your data, privacy, or integrations]
- [Example: "Never save credentials in plaintext," "Don't access personal financial data without asking," "This workspace is air-gapped"]

**Approval Gates:**
- External API calls: [require approval / use pre-approved list]
- Sensitive files: [require approval / use whitelist]
- System modifications: [require approval / use safe defaults]
- [Add any other gates specific to your setup]

**Off-Limits:**
- [Example: "Don't modify production configs," "Don't touch the database without explicit approval," "Ask before accessing shared team docs"]

---

## Owner Profile

**Name:** [From BOOTSTRAP]

**Pronouns:** [From BOOTSTRAP]

**Timezone:** [From BOOTSTRAP—used for scheduling and time interpretation]

**Communication Preference:** [From BOOTSTRAP—brief/detailed, formal/casual]

**Key Needs for This Bot:**
- [From BOOTSTRAP—what they primarily use this bot for]
- [Secondary needs, if any]

**Success Metric:**
- [From BOOTSTRAP—what would make this agent genuinely helpful]
- [Any other measurements of success]

**Working Style:**
- [Example: "Prefers direct feedback to hints," "Works late into evenings," "Likes context before decisions," "Moves fast, iterates"]
- [Timezone-specific notes if relevant]

---

## Projects & Context

This section tracks what you're currently working on, so I understand the context of requests.

**Active Projects:**
- [Project name]: [Brief description, key files/systems involved, deadlines if relevant]
  - Updated: [date]
  - Status: [active, paused, completed]

**Key Systems:**
- [System name]: [What it does, how I interact with it, any constraints]
  - Updated: [date]

**Important Relationships:**
- [Person/Team]: [How they relate to your work, any communication guidelines]

---

## Preferences

### Technical Choices

- **Language/Framework preference:** [If relevant to recommendations]
- **File format preference:** [Markdown vs. structured, verbosity level]
- **Version control philosophy:** [Commit frequency, message style, branch strategy]
- **Documentation approach:** [Inline comments, separate docs, README-first, etc.]
- **Error reporting:** [Verbose, concise, specific format preferred]

### Automation Philosophy

- **Proactive vs. reactive:** [Should I monitor and alert, or wait to be asked?]
- **Batch vs. real-time:** [Collect info and report together, or notify immediately?]
- **Approval model:** [Ask every time, approve once (per session/week), whitelist approach]
- **Failure handling:** [Alert immediately, log and summarize, auto-retry with limits]

### Communication Preferences

- **Alert frequency:** [Real-time, daily digest, weekly summary]
- **Channel preference:** [Where to send alerts or findings]
- **Escalation policy:** [What warrants an immediate message vs. scheduled delivery]

---

## Lessons Learned

This section accumulates insight about what works and what doesn't. Each entry includes a date so I can see how understanding evolves.

**Format:** `[YYYY-MM-DD] [Category] - [Lesson] [Brief explanation]`

**Examples of categories:** "Communication," "Workflow," "Automation," "Architecture," "Performance," "Reliability"

- [YYYY-MM-DD] Communication - [What we learned about how to communicate effectively]
- [YYYY-MM-DD] Automation - [A pattern that worked or didn't work]
- [YYYY-MM-DD] Workflow - [How you actually work vs. how we initially assumed]

---

## Active Automations

This section tracks recurring checks, cron jobs, and monitoring systems.

**Heartbeat Checks** (run on schedule in main session):
- Morning checks (08:00 owner timezone): calendar, email summary, overnight alerts
  - Status: [enabled/disabled]
  - Last run: [YYYY-MM-DD HH:MM]

- Midday checks (12:00 owner timezone): mentions, critical logs, system health
  - Status: [enabled/disabled]
  - Last run: [YYYY-MM-DD HH:MM]

- Evening checks (19:00 owner timezone): consolidation prep, cron status, next-day prep
  - Status: [enabled/disabled]
  - Last run: [YYYY-MM-DD HH:MM]

**Cron Jobs** (isolated, time-based):
- [Job name]: [Frequency and time, what it does, where it logs output]
  - Status: [enabled/disabled]
  - Last run: [YYYY-MM-DD HH:MM]
  - Next scheduled: [YYYY-MM-DD HH:MM]

**Gateway Watchdog:**
- Process: [gateway process name/path]
- Check frequency: [How often we verify it's running]
- Auto-restart: [enabled/disabled]
- Last restart: [YYYY-MM-DD HH:MM, if applicable]
- Status: [running/stopped/error]

---

## System State

Snapshot of your current environment. Update this when major changes happen.

**Hardware:**
- [Example: "MacBook Pro 2021, 16GB RAM, M1 Max"]

**Software Versions:**
- [Example: "Python 3.11, Node 18.12, Docker 24.0"]
- [Any other critical versions]

**Storage:**
- [Example: "Local SSD 512GB, Cloud sync enabled to Dropbox"]

**Credentials & Access:**
- [What systems does this workspace have access to?]
- [Example: "GitHub (read/write to repo X), Slack (read-only), Local file system"]

**Network:**
- [Example: "Internet-connected, no VPN required"]

---

## Channel Architecture

How your workspace is organized and isolated.

**Isolation Model:**
- [Example: "Per-channel isolation (separate context per channel)," "Shared context across channels," "Hybrid (shared for reading, isolated for writing)"]

**Channels in Use:**
- Main: [Primary workspace, loads full MEMORY.md at startup]
  - Purpose: [Day-to-day work, decision-making, learning]
  - Access: [Full context and memory]
  - Last session: [YYYY-MM-DD]

- [Other channels]: [Purpose, access level, when used]

**Session Architecture:**
- Each channel session starts by reading SOUL.md and USER.md
- Main channel session also loads full MEMORY.md and today's daily notes
- Secondary channels load context-specific excerpts only
- Daily notes at `memory/YYYY-MM-DD.md` stay private to that day until consolidated

---

## Session Architecture

How information flows across time and contexts.

**Daily Notes:** `memory/YYYY-MM-DD.md`
- Format: [Markdown, dated entries with timestamps]
- Content: [Decisions made, patterns noticed, things to follow up on, system state changes]
- Lifecycle: Live for 7 days, then consolidated into long-term MEMORY.md
- Consolidation: Every Sunday (or [your preferred frequency])

**Long-Term Consolidation:**
- Review previous week's daily notes
- Extract key lessons and add to "Lessons Learned"
- Note any system state changes and update "System State"
- Archive old daily notes (keep for reference, don't load by default)

**Context Loading:**
- First session of the day: Load SOUL.md, USER.md, MEMORY.md, today's daily notes
- Subsequent sessions: Load SOUL.md, USER.md, today's daily notes (MEMORY.md already cached)
- Secondary channels: Load SOUL.md, USER.md, channel-specific context only

---

## Notes

This section is for meta-observations about how this memory system is working.

- **Last review:** [YYYY-MM-DD]
- **System health:** [Is this file getting too large? Do we need to archive older sections?]
- **Consolidation notes:** [Any patterns in how daily notes translate to long-term memory?]
- **Refinements needed:** [Changes to this structure that would help]

---

## Quick Reference

**Owner:** [Name from USER.md]

**Agent:** [Name from IDENTITY.md]

**Timezone:** [From USER.md—affects all scheduling]

**Critical Success Metric:** [From Owner Profile above]

**Safe to explore:** [Read-only files, documentation, local system]

**Must ask before:** [External API calls, system modifications, sensitive data access]

This file is the bridge between individual sessions. When in doubt, check here for context.
