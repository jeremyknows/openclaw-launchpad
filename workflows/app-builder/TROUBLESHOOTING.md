# Troubleshooting: App Builder Template

Common issues and solutions for the App Builder workflow.

---

## GitHub CLI Issues

### "gh: command not found"
**Problem:** GitHub CLI not installed or not in PATH.

**Solution:**
```bash
brew install gh
```

If already installed but not found:
```bash
# Add Homebrew to PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
```

---

### "gh auth login hangs"
**Problem:** Browser can't open or callback failing.

**Solution:**
Use token-based auth instead:
```bash
gh auth login --with-token < ~/.github_token
```

Or paste token directly:
```bash
gh auth login
# Choose "Paste an authentication token"
# Get token from: https://github.com/settings/tokens
```

---

### "You don't have permission to access this repository"
**Problem:** Auth scope insufficient or wrong account.

**Solution:**
1. Check current auth:
   ```bash
   gh auth status
   ```
2. Re-auth with correct scopes:
   ```bash
   gh auth refresh -s repo,read:org
   ```

---

### "API rate limit exceeded"
**Problem:** Too many GitHub API requests.

**Solution:**
- Wait ~1 hour for limit reset
- Use authenticated requests (check `gh auth status`)
- For heavy usage, consider GitHub Enterprise

---

## Code Editing Issues

### "Agent says it edited file but changes aren't there"
**Problem:** Agent may have edited wrong path or changes weren't saved.

**Solution:**
1. Check the exact file path in agent's response
2. Use `git diff` to see actual changes
3. Ask agent: "Show me the current contents of [file]"

---

### "Syntax errors after agent edit"
**Problem:** Agent made incomplete edit.

**Solution:**
1. Check git diff for the problematic section
2. Ask agent: "There's a syntax error on line X. Please fix it."
3. Use `git checkout -- <file>` to revert if needed

---

## CI/CD Issues

### "CI status shows 'not found'"
**Problem:** No GitHub Actions configured or wrong repo.

**Solution:**
1. Verify repo has `.github/workflows/`:
   ```bash
   ls -la .github/workflows/
   ```
2. Check you're in the right repository:
   ```bash
   gh repo view
   ```

---

### "CI monitor cron never alerts"
**Problem:** Cron running but no failures to report.

**Solution:**
1. Verify cron is running:
   ```bash
   openclaw cron list
   openclaw cron runs ci-monitor
   ```
2. Intentionally break a test to verify alerts work
3. Check `--announce` is enabled

---

## Tool Issues

### "jq: command not found"
**Problem:** jq not installed.

**Solution:**
```bash
brew install jq
```

---

### "ripgrep (rg) slow on large repos"
**Problem:** Searching without exclusions.

**Solution:**
Add `.rgignore` to your repo:
```
node_modules/
.git/
dist/
build/
```

---

### "tmux: session not found"
**Problem:** tmux session doesn't exist yet.

**Solution:**
```bash
# Create a new session
tmux new-session -s dev

# Or attach if it exists
tmux attach -t dev
```

---

## Project Context Issues

### "Agent doesn't understand my codebase"
**Problem:** No CLAUDE.md or project context.

**Solution:**
Create `CLAUDE.md` in your project root:
```markdown
# Project Name

## Tech Stack
- [Your framework]
- [Your language]

## Commands
- `npm test` — Run tests
- `npm run build` — Build

## Conventions
- [Your coding style]
```

---

### "Agent suggests wrong patterns"
**Problem:** Agent using generic patterns, not your project's.

**Solution:**
1. Point to existing code: "Look at src/utils/ for our patterns"
2. Add examples to CLAUDE.md
3. Be specific: "We use [X] pattern, not [Y]"

---

## Getting More Help

- **Ask your agent:** "Why isn't [command] working?"
- **GitHub CLI docs:** https://cli.github.com/manual/
- **OpenClaw docs:** https://docs.openclaw.ai
- **Community Discord:** https://discord.com/invite/clawd

---

*Last updated: 2026-02-11*
