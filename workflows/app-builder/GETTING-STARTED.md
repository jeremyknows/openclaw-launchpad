# Getting Started: App Builder

Welcome! This template gives you an AI assistant optimized for software development. Let's get you coding faster in 10 minutes.

## Prerequisites

Before you start, make sure you have:
- ✅ **macOS** (these templates are Mac-specific)
- ✅ **Homebrew** installed ([get it here](https://brew.sh) if not)
- ✅ **OpenClaw** running (gateway started)
- ✅ **GitHub account** (for issue/PR management)
- ✅ **Terminal comfort** (you're a developer!)

## Quick Setup (5 minutes)

### 1. Install Skills
```bash
bash ~/Downloads/openclaw-setup/workflows/app-builder/skills.sh
```

### 2. Authenticate GitHub
```bash
gh auth login
# Follow the browser OAuth flow
```

### 3. Copy Agent Instructions
```bash
cp ~/Downloads/openclaw-setup/workflows/app-builder/AGENTS.md ~/.openclaw/workspace/
```

### 4. Add Project Context
Create a `CLAUDE.md` in your project root with:
- Tech stack overview
- Coding standards
- Test commands
- Deployment process

## ✅ Verify Your Setup

Run these commands to confirm everything works:

```bash
# 1. Check skills installed
which gh && echo "✅ GitHub CLI ready"
which jq && echo "✅ jq ready"
which rg && echo "✅ ripgrep ready"

# 2. Check GitHub auth
gh auth status && echo "✅ GitHub authenticated"

# 3. Test a simple command
gh repo list --limit 3 && echo "✅ GitHub API working"
```

**What success looks like:**
```
✅ GitHub CLI ready
✅ jq ready
✅ ripgrep ready
✓ Logged in to github.com as yourusername
✅ GitHub authenticated
owner/repo1
owner/repo2
owner/repo3
✅ GitHub API working
```

## Your First Win (5 minutes)

Try these to see immediate value:

### Check GitHub Status
> "Show me open PRs in steipete/openclaw"

### Create an Issue
> "Create an issue in [repo]: Bug - login button doesn't respond on mobile"

### Get Code Help
> "Help me write a TypeScript function that debounces API calls with a 300ms delay"

### Research an API
> "Summarize the Stripe API docs for creating subscriptions"

## Sample Workflows

### PR Review Assistance
1. "Show me the diff for PR #42"
2. "Summarize what this PR changes"
3. "Are there any obvious issues with this approach?"
4. "Draft review comments for the issues found"

### Bug Investigation
1. "What's failing in CI?"
2. "Read the test file and explain what it's testing"
3. "Check if there are related issues in the repo"
4. "Help me fix the failing test"

### Documentation Sprint
1. "Generate JSDoc for all functions in src/utils/"
2. "Update the README with the new API endpoints"
3. "Create a CLAUDE.md for this project"

### Feature Development
1. "Read the existing auth code and explain the pattern"
2. "Help me add OAuth2 support following the same pattern"
3. "Write tests for the new auth flow"
4. "Create a PR description for this change"

## Recommended Cron Jobs

| Job | Frequency | Purpose |
|-----|-----------|---------|
| ci-monitor | Every 30m | Alert on CI failures |
| pr-review-reminder | Daily 9 AM | List PRs awaiting review |
| dependency-check | Weekly | Flag outdated dependencies |

**To enable them**, ask your agent:
> "Set up the ci-monitor cron job from ~/Downloads/openclaw-setup/workflows/app-builder/crons/ci-monitor.json"

Or add manually via CLI:
```bash
openclaw cron add --name "ci-monitor" \
  --every "30m" --session isolated --announce \
  --message "Check CI status for my main repos. Only alert on failures."
```

## Project Setup Best Practices

### Create CLAUDE.md in Each Project
```markdown
# Project Name

## Tech Stack
- Next.js 15, TypeScript, Tailwind
- Prisma + Supabase
- Vitest for testing

## Commands
- `npm run dev` — Development server
- `npm test` — Run tests
- `npm run build` — Production build

## Coding Standards
- Prefer functional components
- Use absolute imports (@/)
- Test business logic, mock external services

## Deployment
- Push to main → Auto-deploy to Vercel
- Run migrations manually: `npx prisma migrate deploy`
```

### Folder Structure Conventions
Tell your agent about your project structure:
> "Our API routes are in src/app/api/, components in src/components/, utilities in src/lib/"

## Tips for Success

### Be Specific About Context
> "Look at src/auth/oauth.ts and help me add Google provider following the same pattern as GitHub"

### Let It Read First
> "Read the existing tests in tests/api/ and write similar tests for the new endpoints"

### Use for First Drafts
Your agent excels at scaffolding. Let it generate, then you refine.

### Trust But Verify
Always run tests before claiming code works:
> "Run the tests for the changes we made"

## Model Selection

| Task | Best Model | Why |
|------|-----------|-----|
| Code generation | Sonnet | Best quality/cost |
| Quick lookups | gpt-nano | Fast and cheap |
| Architecture decisions | Opus | Worth it for big choices |
| PR summaries | Sonnet | Needs full context |

Switch models with `/model sonnet` or `/model gpt-nano` in chat.

## Common Integrations

### VS Code
Your agent can read your project files directly. Just tell it what to look at.

### CI/CD
> "Set up a GitHub Action to run tests on PR"

### Linting
> "Configure ESLint with our team's rules"

## Troubleshooting

### ❌ "Permission denied" when running gh command

**Problem:** GitHub CLI not authenticated or permissions revoked

**Fix:**
```bash
# Check auth status
gh auth status

# If not logged in:
gh auth login

# Follow the browser OAuth flow
```

**Still not working?** Try manual token:
```bash
gh auth login --with-token < your-token.txt
```

---

### ❌ "command not found: gh"

**Problem:** GitHub CLI not in PATH or not installed

**Fix:**
```bash
# Check if installed
which gh

# If not installed:
brew install gh

# Verify installation
gh --version
```

---

### ❌ API rate limit exceeded

**Problem:** Too many GitHub API calls

**Fix:**
- Authenticated users get 5,000 requests/hour (vs 60 for unauthenticated)
- Check rate limit status: `gh api rate_limit`
- Wait for reset time shown in error message
- Use `--paginate` carefully (can consume many requests)

---

### ❌ Skills script fails partway through

**Problem:** Homebrew formula not available or dependency conflict

**Fix:**
```bash
# Update Homebrew first
brew update

# Try installing one tool at a time
brew install gh
brew install jq
brew install ripgrep

# Check for conflicting versions
brew list | grep [tool-name]
```

---

### ❌ Agent doesn't follow coding style

**Problem:** CLAUDE.md missing or incomplete in project

**Fix:**
1. Create `.claude/CLAUDE.md` or `CLAUDE.md` in project root
2. Include specific examples of your style:
   ```markdown
   ## Code Style
   - Use arrow functions, not function keyword
   - Prefer const/let, never var
   - Max line length: 100 characters
   - Test files: *.test.ts (not *.spec.ts)
   ```
3. Tell agent: *"Read CLAUDE.md and follow those standards"*

---

### ❌ Can't access private repositories

**Problem:** GitHub CLI scopes don't include repo access

**Fix:**
```bash
# Re-authenticate with full repo scope
gh auth login --scopes repo

# Or add scopes to existing auth:
gh auth refresh -s repo
```

---

### Need More Help?

- **Template-specific issues:** See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- **General OpenClaw issues:** Check main documentation
- **GitHub CLI docs:** https://cli.github.com/manual/
- **Ask your agent:** *"Help me debug this error: [paste error]"*

---

## Next Steps

1. ✅ Complete the first win exercise above
2. 🔐 Authenticate with GitHub
3. 📝 Create CLAUDE.md in your main project
4. ⏰ Enable CI monitor cron
5. 🚀 Try a real development task

---

*Questions? Ask your agent: "Help me set up my app builder workflow"*
