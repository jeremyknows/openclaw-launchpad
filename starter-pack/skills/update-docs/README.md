# update-docs

Generate and maintain architecture documentation for any codebase. Produces `CLAUDE.md`, `docs/CODEBASE_MAP.md`, `README.md`, and `AGENTS.md` with mermaid diagrams, annotated file trees, and navigation guides.

- Works with **any language or project type** (not limited to TypeScript/JavaScript)
- Scans codebase with token counting to plan parallel analysis
- Spawns parallel subagents for large codebases (stays within context limits)
- Detects existing docs and runs in **update mode** (only refreshes stale sections)
- Generates **navigation guides** — "To add a new X: touch these files" — the most actionable documentation for AI agents

## Install

### Claude Code

```bash
# Clone to your skills directory
git clone https://github.com/jeremyknows/update-docs.git ~/.claude/skills/update-docs
```

### OpenClaw

```bash
cd ~/.openclaw/skills
git clone https://github.com/jeremyknows/update-docs.git
```

### Other Agents (Cursor, Windsurf, etc.)

Clone the repo and point your agent's skill loader at the `SKILL.md` file:

```bash
git clone https://github.com/jeremyknows/update-docs.git ~/update-docs
```

## Setup

### Prerequisites

- **Python 3.9+** (ships with macOS, most Linux distros)
- **[uv](https://docs.astral.sh/uv/)** (recommended) — handles dependencies automatically

```bash
# Verify Python 3.9+
python3 --version

# Install uv (optional but recommended)
curl -LsSf https://astral.sh/uv/install.sh | sh
```

If `uv` is not installed, the scanner falls back to `python3` (requires `pip install tiktoken` manually).

### Verify Installation

```bash
# Test the scanner
uv run ~/.claude/skills/update-docs/scripts/scan-codebase.py . --format tree
```

You should see a file tree with token counts.

## Usage

### Natural Language

Just tell Claude what you need:

- "Update the docs for this project"
- "Create a CLAUDE.md and codebase map"
- "Map this codebase"
- "My docs are stale, refresh them"
- "I need architecture documentation"
- "Generate a README"

### CLI Command

```bash
# In any project directory
/update-docs
```

## What It Generates

| File | Purpose | When |
|------|---------|------|
| `docs/CODEBASE_MAP.md` | Full architecture map with mermaid diagrams, directory tree, module guide, data flow, navigation guide | Always |
| `CLAUDE.md` | Dense agent reference (50–200 lines) — stack, commands, patterns, constraints | Full + Update modes |
| `README.md` | User-facing documentation | Full mode (or when stale) |
| `AGENTS.md` | Deep module reference | Only for projects with 4+ modules |

### Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Full** | No existing `docs/CODEBASE_MAP.md` | Generate all docs from scratch |
| **Update** | Existing map with `last_mapped` timestamp | Scope to changed files since last map |
| **Map-only** | User specifically asks for codebase map | Generate only `docs/CODEBASE_MAP.md` |

## How It Works

1. **Scan** — Runs `scan-codebase.py` to get file tree with token counts (respects `.gitignore`)
2. **Plan** — Groups files by module, balances token budgets across subagents
3. **Analyze** — Spawns parallel Sonnet subagents to read and analyze code (orchestrator never reads files directly)
4. **Synthesize** — Merges subagent reports into documentation using templates from `references/doc-templates.md`
5. **Verify** — Checks all file path references exist and mermaid syntax is valid
6. **Report** — Lists what was created/updated, leaves changes for user review (never commits)

## Configuration

No configuration needed. The skill auto-detects project type, language, and framework from the scan results.

### Scanner Options

```bash
# JSON output (used by the skill)
uv run scripts/scan-codebase.py . --format json

# Tree view with token counts
uv run scripts/scan-codebase.py . --format tree

# Compact view sorted by token count
uv run scripts/scan-codebase.py . --format compact

# Increase max tokens per file (default: 50,000)
uv run scripts/scan-codebase.py . --max-tokens 100000

# See all options
uv run scripts/scan-codebase.py --help
```

## Coexistence with generate-docs

| Scenario | Use |
|----------|-----|
| TypeScript/JavaScript project needing inline JSDoc | `generate-docs` |
| Any project needing CLAUDE.md, README, codebase map | `update-docs` |
| TypeScript project needing both | Run both — `generate-docs` for JSDoc, `update-docs` for architecture |

`update-docs` does NOT generate inline code comments. It generates standalone documentation files.

## Limitations

- **Subagent-only architecture** — The orchestrator never reads codebase files directly. For very small projects (< 10 files), this adds overhead but keeps the approach consistent.
- **Token estimation** — Uses `tiktoken` with `cl100k_base` encoding. Accurate for Claude models but may over/under-count for other model families.
- **No inline comments** — Generates standalone `.md` files only. Use `generate-docs` for JSDoc/TSDoc.
- **Git dependency for update mode** — Update mode requires a git repo to detect changes since last mapping. Falls back to full mode if not a git repo.
- **Max file size** — Scanner skips files over 1MB or 50,000 tokens (configurable with `--max-tokens`).
- **Root .gitignore only** — Only reads the root-level `.gitignore`. Nested `.gitignore` files in subdirectories are not parsed.
- **No .gitignore negation** — `.gitignore` negation patterns (`!pattern`) are not supported; negated files will still be excluded.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `ERROR: tiktoken not installed` | `uv` not available and `tiktoken` not installed | Install uv: `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Scanner returns 0 files | All files matched ignore patterns | Check `.gitignore`; scanner respects it plus built-in excludes |
| Mermaid diagrams don't render | Node IDs contain special characters | File an issue — the sanity check should catch this |
| Update mode maps everything | No `last_mapped` in frontmatter | Previous map was manually created without frontmatter; delete and re-run in full mode |
| `Permission denied` on scanner | Script not executable | `chmod +x scripts/scan-codebase.py` |

## File Structure

```
update-docs/
├── SKILL.md                  # Main skill — orchestration instructions
├── README.md                 # This file
├── LICENSE.txt               # MIT (skill + scanner attribution)
├── .gitignore
├── scripts/
│   └── scan-codebase.py      # Codebase scanner with token counting (from Cartographer, MIT)
└── references/
    └── doc-templates.md      # Output templates + mermaid conventions
```

## Credits

- **[Cartographer](https://github.com/kingbootoshi/cartographer)** by Bootoshi — `scan-codebase.py` is bundled from this project (MIT license). The "Opus orchestrates, Sonnet reads" pattern and navigation guide concept also originate from Cartographer.

## License

MIT — see [LICENSE.txt](LICENSE.txt)
