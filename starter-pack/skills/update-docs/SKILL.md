---
name: update-docs
description: |
  Use when: (1) user says "update docs", "docs are stale", or "/update-docs",
  (2) user asks to document a codebase, create a README, or generate a codebase map,
  (3) user wants CLAUDE.md, AGENTS.md, or agent-focused documentation,
  (4) user says "map this codebase" or "cartographer",
  (5) user is onboarding to a new project and needs architecture overview,
  (6) after significant code changes that may have made existing docs outdated.
  Works with any language or project type.
license: MIT
metadata:
  author: jeremyknows
  version: "1.0.0"
  openclaw:
    requires:
      bins: ["python3"]
---

# Update Docs

## Step 1: Determine Mode

Check the project root and `docs/` directory for existing documentation:

- Look for `docs/CODEBASE_MAP.md` — if it exists, read its YAML frontmatter for `last_mapped` timestamp
- Look for `CLAUDE.md` and `README.md` at the project root

Based on findings, select a mode:

| Condition | Mode |
|-----------|------|
| No `docs/CODEBASE_MAP.md` exists | **Full** — generate all docs from scratch |
| `CODEBASE_MAP.md` exists with `last_mapped` | **Update** — scope changes since last map |
| User specifically asked for "codebase map" only | **Map-only** — generate only `docs/CODEBASE_MAP.md` |

Default to **Full** when ambiguous.

## Step 2: Scan the Codebase

Run the bundled scanner to get file tree with token counts:

```bash
uv run {skill_dir}/scripts/scan-codebase.py . --format json
```

Where `{skill_dir}` is the directory containing this SKILL.md (resolve from the skill's own file path).

If `uv` is not available, fall back to:
```bash
python3 {skill_dir}/scripts/scan-codebase.py . --format json
```

Parse the JSON output to extract:
- `files` — list of `{path, tokens, size_bytes}` for each file
- `directories` — list of directory paths
- `total_tokens` — sum of all file tokens
- `total_files` — count of scanned files
- `skipped` — files that were too large, binary, or unreadable

From the scan results, identify:
- **Project type** (web app, CLI tool, library, monorepo, etc.)
- **Primary language and framework**
- **Module groupings** (group files by top-level directory)

**Update mode only:** Also run:
```bash
git log --oneline --since="{last_mapped}"
```
Use the output to identify which modules/directories have changed. Scope subagent work to changed modules only; preserve existing docs for unchanged modules.

## Step 3: Plan & Spawn Subagents

**Token budget:** 150,000 tokens per Sonnet subagent.

Group files by directory/module. Balance token counts across subagents:
- **Small codebases** (<100k total tokens): 1 subagent
- **Medium codebases** (100k–300k): 2–3 subagents
- **Large codebases** (300k+): 4–6 subagents

**CRITICAL: Opus orchestrates, Sonnet reads.** Do NOT read codebase files directly from this orchestrating context. ALL file reading is delegated to subagents.

**CRITICAL: Spawn ALL subagents in a SINGLE message.** Subagents need read-only file access. In Claude Code, use the Task tool with `subagent_type: "Explore"` and `model: "sonnet"`.

Each subagent prompt must include:

1. **File list** — the specific files assigned to this subagent, with their token counts
2. **Per-file analysis request:**
   - Purpose and responsibility
   - Key exports (functions, classes, constants)
   - Key imports and dependencies
   - Patterns and conventions used
   - Gotchas or non-obvious behavior
3. **Per-module analysis request:**
   - How files within the module connect to each other
   - Entry points and public API
   - Data flow through the module
   - Internal patterns unique to this module
4. **Two summary types:**
   - **Agent-focused:** Dense, scannable — exports, patterns, constraints, file relationships
   - **User-focused:** Narrative — what this module does, why it exists, how it fits in the system
5. **Navigation entries:** "To add/modify/debug X in this module, touch these files"

**Update mode:** Include existing doc sections for assigned modules in the subagent prompt. Ask the subagent to report what has changed vs. what remains accurate.

## Step 4: Synthesize Outputs

After all subagents return, merge their reports into documentation files.

Load `{skill_dir}/references/doc-templates.md` for output format templates and mermaid conventions.

Get the actual timestamp (never estimate):
```bash
date -u +"%Y-%m-%dT%H:%M:%SZ"
```

### Files to Write

**`docs/CODEBASE_MAP.md`** (always)
- YAML frontmatter: `last_mapped`, `total_files`, `total_tokens`
- System overview mermaid diagram (flowchart TB, max 20 nodes)
- Annotated directory tree from scan results
- Module guide with key files tables
- Data flow sequence diagrams for key interactions
- Conventions section (naming, errors, config, testing)
- **Navigation guide** — minimum 4 "To do X: touch these files" entries

**`CLAUDE.md`** (Full and Update modes)
- Dense agent reference: stack, commands, structure, patterns, constraints, env vars
- 50–200 lines, scannable
- Links to `docs/CODEBASE_MAP.md` for full architecture
- If CLAUDE.md exists: update stale sections, preserve accurate content

**`README.md`** (Full mode, or Update mode if README is stale)
- User-facing narrative with progressive disclosure
- If README exists: respect existing structure, only update stale sections
- Do NOT add sections the user hasn't chosen to include

**`AGENTS.md`** (only for projects with 4+ distinct modules)
- Module index table
- Per-module: public API, internal patterns, gotchas

**Update mode:** Preserve unchanged sections. Merge new subagent analysis into existing docs. Update the `last_mapped` timestamp.

## Step 5: Sanity Check

After writing all files, verify:

1. **File paths** — every path referenced in generated docs points to a file that actually exists in the codebase (use Glob to spot-check)
2. **Mermaid syntax** — no unclosed subgraphs, node IDs are alphanumeric + underscores only, all `end` keywords present
3. For deeper cross-document auditing, suggest: "Run `/multi-document-consistency-audit` for a full consistency check"

## Step 6: Report

Summarize what was done:

- List each file: created, updated, or unchanged
- Note any issues found during sanity check
- Remind the user to review changes before committing
- Do NOT commit any changes

## Rules

1. **Opus orchestrates, Sonnet reads.** Never read codebase files directly from this context. Always delegate to subagents. Even for small projects.
2. **Respect existing docs.** Update stale sections; don't replace accurate content or restructure what works.
3. **Do NOT commit.** Leave all changes uncommitted for user review.
4. **Navigation guides are mandatory.** Every CODEBASE_MAP.md must include "To do X: touch these files" entries. This is the most actionable documentation for agents.
