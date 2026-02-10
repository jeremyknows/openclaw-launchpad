<!-- OpenClaw Setup Package - Workspace Template
     This file is part of the OpenClaw Setup Package.
     Personalize this file during your first session with BOOTSTRAP.md
     or manually edit the [bracketed] placeholders. -->

# Daily Heartbeat: Scheduled Checks and Routine Monitoring

This file defines my daily rhythm—when I check in, what I look for, and when I notify you. It's designed to keep me from interrupting while making sure nothing important slips through.

All times use your timezone: [From USER.md]

---

## Overview

The heartbeat is a set of batched checks that run during your active hours. Unlike cron jobs (which run at exact times in isolation), heartbeat checks happen when I'm actively in your context, and results are shared immediately.

Think of it as a routine walk through your information landscape—I notice what's changed, what needs attention, and what can wait.

---

## Check Schedule

### Morning Checks

**Run time:** [08:00 owner timezone—adjust if you start work later]

**Duration:** [Typically 5-10 minutes of checking, summarized in 2-3 minutes of reading]

**What I check:**
- Calendar for today: meetings, deadlines, time blocks
- Email summary: new messages, flagged items, responses needed
- Overnight alerts: anything critical that happened while you slept
- System health: any errors or issues from the previous evening

**How I report:**
- Calendar: "3 meetings today (9am, 1pm, 4pm). No conflicts. 2 have agendas waiting."
- Email: "12 new messages. 3 need responses (from [person], [person], [person]). 2 flagged for review."
- Alerts: "Gateway restarted at 3:47am (watchdog caught it). No other issues."
- System: "All systems normal. Disk at 72%. No errors in logs."

**Why this matters:** You start the day oriented and aware of what's urgent.

---

### Midday Checks

**Run time:** [12:00 owner timezone—adjust if you prefer different time]

**Duration:** [Typically 3-5 minutes of checking, summarized in 1-2 minutes of reading]

**What I check:**
- Mentions and messages: anything calling for your attention
- Critical logs: errors, warnings, anything unexpected
- System health: resource usage, process status, any changes
- Meeting readiness: upcoming meetings in next 2 hours with any prep needed

**How I report:**
- Mentions: "[Person] mentioned you in #channel," or "No new mentions."
- Logs: "1 warning in auth module (same as yesterday). 0 errors."
- System: "Disk at 73%. Gateway running normally. API latency normal."
- Meetings: "15-min prep time before next meeting. No new agenda updates."

**Why this matters:** You stay aware of what's happening without constant interruption.

---

### Evening Checks

**Run time:** [19:00 owner timezone—adjust if you work later]

**Duration:** [Typically 5-10 minutes of checking, plus memory work]

**What I check:**
- Day summary: what you accomplished, what's pending
- Memory consolidation: what should I remember from today?
- Cron job status: did scheduled jobs run successfully?
- Next-day prep: anything I should flag for tomorrow morning?

**How I report:**
- Day summary: "Completed: [projects touched]. In progress: [projects that need follow-up]. New issues: [things to address]."
- Memory: "Added 3 lessons learned, updated active project status. Consolidating when next review hits."
- Cron jobs: "Weekly backup at 22:00—will let you know if it completes successfully."
- Next day: "Tomorrow: 4 meetings, 2 time-sensitive emails. Gateway watchdog running normally."

**Why this matters:** You end the day with closure and clarity about what's next.

---

## Alert Decision Tree

Not everything that happens requires an immediate alert. This tree helps me decide when to proactively message you vs. when to include it in scheduled checks.

```
Did something important happen?
│
├─ YES: Is it time-sensitive and needs immediate action?
│  │
│  ├─ YES: Can I fix it automatically, or does it need you?
│  │  │
│  │  ├─ I can fix it: Fix it, note it in daily log, mention at next check
│  │  │  Examples: Restart crashed service, retry failed API call, clear alert
│  │  │
│  │  └─ You need to decide: ALERT immediately
│  │     Examples: Deployment failure, security warning, customer issue
│  │
│  └─ NO: Include in next scheduled check
│     Examples: New project task added, email needs response by Thursday, code review comment
│
└─ NO: Nothing to report
   Examples: Routine health checks passing, normal monitoring data, no new items
```

### What Triggers Immediate Alerts

I message you proactively (outside of scheduled checks) for:

- **Security events:** Unusual access patterns, failed auth attempts, suspicious behavior
- **Critical errors:** Services down, data loss risk, system failures
- **Owner mentions:** Someone mentioned you directly (in urgent context)
- **Urgent email:** Emails marked urgent, or from [priority senders you define]
- **Time-sensitive issues:** Deadlines in next 2 hours, calendar conflicts, urgent Slack mentions

### What Stays Quiet Until Scheduled Check

I don't alert for:
- Routine health checks passing (disk OK, processes running, no errors)
- Non-urgent emails (will mention in morning/midday check)
- Routine log entries (will summarize in midday check)
- General notifications that can wait (will include in evening summary)
- Informational events (will include in daily notes)

### Silence Rule

If nothing urgent happened since the last check, I don't send a message. No "all clear" reports. No redundant notifications. You hear from me when there's something worth hearing about.

---

## Check Customization

### Change the Schedule

If the default times don't work:
- **Later start:** Change morning check to [your time]
- **More frequent:** Add additional check at [specific time]
- **Less frequent:** Remove or consolidate checks
- **Weekends:** Different schedule on Saturdays/Sundays? Note it here.

### Change What I Check

If there's something I should monitor that's not listed:
- Add it to the relevant check section
- Explain what you want to know about it
- Tell me how to report it

If something in the checks isn't useful:
- Remove it
- Tell me why—I'll learn what matters to you

### Active Hours

**Default:** 08:00 - 23:00 owner timezone

If you work different hours (night shift, variable schedule, etc.):
- Morning check: [your time]
- Midday check: [your time]
- Evening check: [your time]
- Or different schedule on different days

---

## Gateway Watchdog

The gateway process is critical to your workspace. Here's how I monitor it.

**Process to monitor:** [Path or name—fill in during setup]

**Check frequency:** Every 10 minutes during active hours

**If it's down:**
1. Log the time it went down
2. Attempt auto-restart (if enabled)
3. If auto-restart succeeds: Note it in daily log, mention in next check
4. If auto-restart fails: ALERT immediately
5. Keep attempting restart every minute until you respond

**If it keeps dying:**
- Stop auto-restart after 3 failures (to avoid thrashing)
- Alert you that manual intervention is needed
- Include recent logs and context in the alert

**Status tracking:**
- Last confirmed running: [Will be updated by heartbeat]
- Last restart: [Will be updated if watchdog restarts it]
- Auto-restart: [enabled / disabled]
- Current status: [Will show running/stopped/error]

---

## Memory Consolidation (Evening Check)

As part of the evening check, I consolidate what happened today into long-term memory.

**What I consolidate:**
- Lessons learned from today (add to MEMORY.md with date)
- System state changes (update in MEMORY.md)
- Project updates (mark completed, update progress)
- New patterns noticed (add to Lessons Learned)

**Format:**
- Date each entry: [YYYY-MM-DD]
- Keep entries concise but meaningful
- Include reasoning if relevant ("Why this matters: [...]")

**When I consolidate into MEMORY.md:**
- Daily: Updated notes from today's check
- Weekly: Review of entire week, consolidate key items
- Monthly: Archive old consolidations, keep recent (6 months)

---

## Notes and Adjustments

**Last configured:** [YYYY-MM-DD during BOOTSTRAP]

**Adjustments made:**
- [Date]: [What changed and why]
- [Date]: [What changed and why]

**How it's working:**
- [Are the check times right? Do you actually read the summaries? Is something missing?]
- [Feedback on what's helping and what's not]

---

## Quick Reference

**Morning:** [Time] — Calendar, email, overnight alerts, system health

**Midday:** [Time] — Mentions, critical logs, system health, meeting prep

**Evening:** [Time] — Day summary, memory consolidation, cron status, next-day prep

**Immediate alerts:** Security, critical errors, owner mentions, urgent email, time-sensitive issues

**Silence rule:** If nothing urgent, I don't message you

**Gateway watchdog:** Monitoring [process], auto-restart [enabled/disabled], alerts if down

This file is your heartbeat configuration. Adjust it if it's not serving you well.
