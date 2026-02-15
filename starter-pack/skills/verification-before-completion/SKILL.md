---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing — requires running verification commands and confirming output before making any success claims. Evidence before assertions, always. Adapted from obra/superpowers.
---

# Verification Before Completion

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| File saved | Read file back, confirm content | "I wrote it" |
| Config applied | Gateway restarted, status checked | Config edited |
| API working | Actual API call response | "Endpoint exists" |
| Cron job scheduled | `cron list` shows job | "I created it" |
| Subagent completed | Check session history + output files | Agent says "done" |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting subagent success reports without checking output
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Subagent said success" | Check session_history + files |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**File Operations:**
```
✅ [Write file] → [Read file back] → [Confirm content matches] → "File saved"
❌ "I wrote the file" (without reading it back)
```

**Config Changes:**
```
✅ [Edit config] → [Restart gateway] → [Check status] → "Config applied"
❌ "I updated the config" (without restart verification)
```

**Subagent Delegation:**
```
✅ Agent reports success → sessions_history → Read output files → Report actual state
❌ Trust subagent report
```

**Cron Jobs:**
```
✅ [cron add] → [cron list] → [See job in output] → "Job scheduled"
❌ "I created the cron job" (without listing to verify)
```

**API Calls:**
```
✅ [Make actual request] → [See response] → "API returns X"
❌ "The endpoint should work" / "I implemented it"
```

## OpenClaw-Specific Verification Commands

| Claim | Verification Command |
|-------|---------------------|
| Gateway running | `curl -s http://127.0.0.1:18789/health` |
| File exists | `Read` tool with file path |
| Cron scheduled | `cron list` action |
| Session active | `sessions_list` with session key |
| Config valid | `gateway config.get` action |
| Skill installed | Check `~/.openclaw/skills/{name}/SKILL.md` exists |

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Reporting to user that something is "done"
- Delegating to subagents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.

---

*Adapted from [obra/superpowers](https://github.com/obra/superpowers) verification-before-completion skill.*
*Original author: Jesse Vincent (@obra)*
