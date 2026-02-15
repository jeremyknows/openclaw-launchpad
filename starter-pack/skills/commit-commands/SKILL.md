---
name: commit-commands
description: "Git workflow automation: /commit, /commit-push-pr, /clean_gone"
---

# Commit Commands

Streamline your git workflow with simple commands for committing, pushing, and creating pull requests.

## Commands

### /commit

Creates a git commit with an automatically generated commit message based on staged and unstaged changes.

**What it does:**
1. Gather context: `git status`, `git diff HEAD`, `git branch --show-current`, `git log --oneline -10`
2. Analyze both staged and unstaged changes
3. Match recent commit message style
4. Stage relevant files
5. Create the commit

**Process:**
```bash
# Gather context first
git status
git diff HEAD
git branch --show-current
git log --oneline -10
```

Based on the changes, create a single commit. Stage and commit in one action.

**Features:**
- Matches your repo's commit style
- Follows conventional commit practices
- Avoids committing secrets (.env, credentials.json)
- Includes attribution in commit message

---

### /commit-push-pr

Complete workflow: commit, push, and create a pull request.

**What it does:**
1. Gather context: `git status`, `git diff HEAD`, `git branch --show-current`
2. Create a new branch (if currently on main)
3. Stage and commit changes
4. **Confirm with user before pushing**
5. Push the branch to origin
6. Create a pull request using `gh pr create`
7. Provide the PR URL

**Process:**
```bash
# Gather context first
git status
git diff HEAD
git branch --show-current
```

⚠️ **IMPORTANT**: Before running `git push`, confirm with the user:
> "Ready to push branch `<branch-name>` and create PR? [y/n]"

Only proceed after user confirms.

**Features:**
- Analyzes all commits in branch for PR description
- Creates comprehensive PR descriptions with summary and test plan
- Handles branch creation automatically
- Uses GitHub CLI (`gh`) for PR creation

**Requirements:**
- GitHub CLI (`gh`) must be installed and authenticated
- Repository must have a remote named `origin`

---

### /clean_gone

Cleans up local branches that have been deleted from the remote.

**What it does:**
1. List branches to identify [gone] status
2. Identify worktrees for [gone] branches
3. Remove worktrees and delete [gone] branches
4. Report what was cleaned up

**Process:**
```bash
# Step 1: List branches
git branch -v

# Step 2: List worktrees
git worktree list

# Step 3: Clean up (only run if [gone] branches exist)
git branch -v | grep '\[gone\]' | sed 's/^[+* ]//' | awk '{print $1}' | while read branch; do
  echo "Processing branch: $branch"
  worktree=$(git worktree list | grep "\\[$branch\\]" | awk '{print $1}')
  if [ ! -z "$worktree" ] && [ "$worktree" != "$(git rev-parse --show-toplevel)" ]; then
    echo "  Removing worktree: $worktree"
    git worktree remove --force "$worktree"
  fi
  echo "  Deleting branch: $branch"
  git branch -D "$branch"
done
```

**When to use:**
- After PRs are merged and remote branches deleted
- When local branch list is cluttered
- Regular repository maintenance

---

## Best Practices

- **Review before commit**: Let the AI analyze changes and match style
- **Use /commit during dev**: Quick commits while working
- **Use /commit-push-pr when ready**: Minimize context switching at PR time
- **Run /clean_gone periodically**: Keep branch list tidy

## Requirements

- Git must be installed and configured
- For /commit-push-pr: GitHub CLI (`gh`) installed and authenticated
- Repository must have a remote
