# Skill Pack UX Patterns Research

**Date:** 2026-02-11  
**Purpose:** Research how other tools handle optional feature/plugin selection during setup

---

## Executive Summary

Modern CLI tools and development environments use several proven patterns for optional feature selection:

1. **Workspace Recommendations** (VS Code) — Non-intrusive, contextual suggestions
2. **Interactive Prompts with Checkboxes** (Inquirer.js, Vite) — Progressive disclosure, sensible defaults
3. **Walkthrough Checklists** (VS Code Extensions) — Multi-step onboarding with visual progress
4. **Grouped Installs** (Homebrew Bundle, npm) — Declarative file-based configuration
5. **Post-Install Recommendations** — Deferred suggestions based on usage patterns

---

## 1. VS Code Extension Recommendations

### How It Works

VS Code uses a **passive recommendation pattern** via `.vscode/extensions.json`:

```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode"
  ],
  "unwantedRecommendations": [
    "old.deprecated-extension"
  ]
}
```

### UX Pattern

- **Non-blocking banner notification** in bottom-right corner: "This workspace has extension recommendations"
- **Two-click access**: "Show Recommendations" → View filtered list
- **Visual indicators**: Shows which are already installed vs. need installation
- **Opt-out friendly**: Can dismiss or ignore individual recommendations
- **No interruption**: Never blocks workflow, always defer-able

### Why It Works

✅ **Context-aware**: Recommendations appear when opening a workspace  
✅ **Low pressure**: Soft nudge, not a hard requirement  
✅ **Transparent**: Clear list of what's recommended and why (can add descriptions)  
✅ **Reversible**: Easy to install later via Extensions panel

### Terminal Equivalent

```
🔧 Setup Complete!

📦 Optional skills available for this workflow:
  → opclaw skill install --recommended     (5 recommended skills)
  → opclaw skill list --recommended        (see details)
  → Skip for now                            (install anytime)

Tip: Run 'opclaw skills' to explore all available features
```

---

## 2. Interactive CLI Prompts (Inquirer.js / Vite)

### Pattern: Progressive Framework Selection

**Vite's `npm create vite` flow:**

```
? Project name: › my-app
? Select a framework: › 
  → Vanilla
    Vue
    React        ← Arrow keys to navigate
    Preact
    Lit
    Svelte

? Select a variant: ›
  → TypeScript
    TypeScript + SWC
    JavaScript
```

### Pattern: Checkbox Multi-Select (Inquirer.js)

```javascript
// @inquirer/checkbox pattern
{
  type: 'checkbox',
  message: 'Select skill packs to install:',
  choices: [
    { name: '📧 Email & Calendar', value: 'comms', checked: true },
    { name: '🤖 Discord Bot', value: 'discord' },
    { name: '📱 Mobile Integration', value: 'mobile' },
    new Separator(),
    { name: '🎨 Image Generation (requires API key)', value: 'images', disabled: true }
  ]
}
```

### UX Principles

✅ **Sensible defaults**: Pre-check commonly needed options (`checked: true`)  
✅ **Visual hierarchy**: Use separators and symbols to group related items  
✅ **Show cost/requirements**: Indicate if something requires additional setup  
✅ **Keyboard-friendly**: Space to toggle, Enter to submit, arrows to navigate  
✅ **Skip escape hatch**: Always allow empty selection or "None"

### Common Patterns

**Grouped Toggles:**
```
npm package: prompt-checkbox supports group toggles

? Select features:
  ○ All Communication Tools    ← Toggle entire group
    ☑ Email
    ☑ Calendar
    ☑ Discord
  ○ All Media Tools
    ☐ Camera
    ☐ Text-to-Speech
```

**Short summaries on selection:**
```
Once prompt is done, show condensed summary:
✓ Installed: email, calendar, discord (3 skills)
```

---

## 3. VS Code Walkthroughs (Multi-Step Onboarding)

### Pattern

Extensions can contribute **Getting Started checklists** that appear in the welcome screen:

```json
{
  "contributes": {
    "walkthroughs": [{
      "id": "sample-walkthrough",
      "title": "Get Started with Extension X",
      "description": "Set up your workspace in 3 steps",
      "steps": [
        {
          "id": "install-dependencies",
          "title": "Install Dependencies",
          "description": "Install required packages",
          "media": { "image": "setup-step1.svg" },
          "completionEvents": ["onCommand:extension.installDeps"]
        }
      ]
    }]
  }
}
```

### UX Principles

✅ **Visual progress**: Checkmarks as steps complete  
✅ **Rich media**: Images/diagrams for context  
✅ **Action-oriented**: Each step has a clear CTA button  
✅ **Auto-tracking**: Steps mark complete based on events  
✅ **Skippable**: User can close and return anytime

### Terminal Equivalent

```
🚀 OpenClaw Setup Walkthrough

Getting Started (1/3 complete):
  ✓ Core installation
  → Link calendar & email     [Run Setup]
  ○ Install mobile companion  [Learn More] [Skip]

Run 'openclaw setup continue' to resume anytime
```

---

## 4. Homebrew Bundle (Declarative Grouped Installs)

### Pattern

**Note:** Homebrew Bundle was merged into main `brew` — but the pattern remains instructive.

Users create a `Brewfile` listing packages in logical groups:

```ruby
# Development Tools
brew "git"
brew "node"

# Optional: Databases (commented out by default)
# brew "postgresql"
# brew "redis"

# GUI Apps
cask "visual-studio-code"
cask "docker"

# Mac App Store
mas "1Password", id: 1333542190
```

Then: `brew bundle install`

### UX Principles

✅ **Declarative**: File-based, version-controllable  
✅ **Grouped by purpose**: Comments provide context  
✅ **Opt-in by uncommenting**: Low friction to enable later  
✅ **Idempotent**: Re-running is safe (only installs missing items)

### OpenClaw Equivalent

**Option A: Interactive select during setup**
```
? Enable Discord integration? (Y/n)
? Enable calendar sync? (Y/n)
```

**Option B: Config file with optional sections**
```yaml
# .openclaw/profile.yml
skills:
  core: [exec, web, files]
  optional:
    - discord   # Uncomment to enable
    # - calendar
    # - mobile
```

---

## 5. Post-Install Recommendations

### Pattern: Contextual Suggestions After First Use

**Git hooks example:**
```
$ git commit
✓ Commit created

💡 Tip: Install pre-commit hooks to auto-lint?
   Run: git config --local core.hooksPath .githooks
   Learn more: https://...
   
   [Don't show again]
```

**npm example:**
```
$ npm install express

+ express@4.18.2

📦 You might also like:
  - body-parser (commonly used with Express)
  - helmet (security middleware)
  
Run: npm install --save body-parser helmet
```

### UX Principles

✅ **Contextual timing**: Suggest when user is already in the workflow  
✅ **Low friction**: Single command to accept suggestion  
✅ **Educational**: Explain *why* the suggestion is relevant  
✅ **Dismissible**: Clear way to opt-out permanently

### OpenClaw Equivalent

```
$ openclaw discord send "#general" "Hello!"

✓ Message sent

💡 You might also like:
  → 'reactions' skill for emoji reactions
  → 'threads' skill for thread management
  
  Run: openclaw skill install reactions threads
  
  [Show later] [Don't suggest again]
```

---

## Best Practices Summary

### For Terminal UIs

#### ✅ DO

1. **Use symbols/emoji sparingly** for visual scanning (✓, →, ○, •)
2. **Group related items** with separators or headers
3. **Show defaults clearly** (e.g., `[Y/n]` means Yes is default)
4. **Provide escape hatches**: "Skip all", "Customize later", "None"
5. **Respect TTY width**: Keep lines under 80 chars when possible
6. **Make it resumable**: Save state, allow `setup continue`

#### ❌ DON'T

1. **Overwhelm with choices** — 5-7 options max per screen
2. **Block without escape** — Always allow skip/defer
3. **Hide consequences** — Show disk space, API requirements, etc.
4. **Lose context on error** — If install fails, explain and allow retry
5. **Forget about color-blind users** — Use shapes/text, not just color

---

## Packs vs. Individual Items

### When to Use "Packs"

✅ When items are **commonly used together**  
✅ For **role-based workflows** (e.g., "Developer Pack", "Content Creator Pack")  
✅ When items have **shared dependencies**  
✅ To **reduce decision fatigue** for beginners

**Example:**
```
Communication Pack:
  - Email integration (Gmail, Outlook)
  - Calendar sync
  - Discord bot
  - SMS/iMessage relay
```

### When to Use Individual Selection

✅ When users have **specific needs**  
✅ For **advanced configuration**  
✅ When items are **independent** (no shared deps)  
✅ After initial setup (for customization)

**Example:**
```
Available Skills:
  ○ Camera access
  ○ Text-to-speech
  ○ Web browsing
  ○ Code execution
  ...
```

### Hybrid Approach (Recommended)

Offer **both** during setup:

```
? Choose setup mode:
  → Quick Start (recommended packs)
    Custom (pick individual skills)
    Minimal (core only, add later)
```

**Quick Start flow:**
```
? Select packs to install: (Space to toggle, Enter to continue)
  ☑ Communication Essentials (email, calendar, SMS)
  ☐ Content Creation (image gen, TTS, video)
  ☐ Developer Tools (git, exec, code review)
  ☐ Home Automation (camera, smart home, location)
```

**Custom flow:**
```
? Select skills: (20 available)
  ☐ email
  ☑ calendar
  ☐ discord
  ...
```

---

## Skip/Defer Patterns

### Pattern 1: "Install Anytime" Command

```
Setup complete! Core features ready.

Optional skills can be installed anytime:
  → opclaw skill install <name>
  → opclaw skill browse
```

### Pattern 2: Lazy Loading with Prompts

```
$ opclaw camera snap

⚠ Camera skill not installed.

? Install camera skill now? (Y/n)
  [Yes, install now]
  [Show info first]
  [No, remind me later]
```

### Pattern 3: Recommendation File

Generate a `.openclaw/recommended-skills.txt` during setup:

```
# Recommended skills for your workflow
# Install with: opclaw skill install --file recommended-skills.txt

discord    # For chat integration
calendar   # For scheduling
camera     # For visual monitoring
```

User can edit and install when ready.

### Pattern 4: "Setup Later" Checklist

```
$ opclaw setup status

OpenClaw Setup Progress:
  ✓ Core installation
  ✓ User profile
  → Optional Skills (0/5 recommended)
    - Discord integration [Install]
    - Calendar sync [Install]
    ...
  
Run 'openclaw setup complete' to finish configuration
```

---

## Terminal UI Examples

### Example 1: Compact Multi-Select

```
╭─ Install Optional Skills ────────────────────────────╮
│                                                       │
│  Use ↑↓ to navigate, Space to toggle, Enter to save │
│                                                       │
│  Communication:                                       │
│    ☑ Email & Calendar                                │
│    ☑ Discord                                          │
│    ☐ SMS/iMessage                                     │
│                                                       │
│  Media:                                               │
│    ☐ Camera Access                                    │
│    ☐ Text-to-Speech                                   │
│                                                       │
│  [A] Select All  [N] None  [Enter] Continue          │
╰───────────────────────────────────────────────────────╯
```

### Example 2: Progressive Disclosure

```
? Enable Communication features? (Y/n) y
  
  ☑ Email integration
  ☑ Calendar sync
  ? Also enable Discord? (y/N) n
  ? Also enable SMS relay? (y/N) n

? Enable Media features? (y/N) n
  [Skipped]

? Enable Developer tools? (y/N) y
  
  ☑ Code execution
  ☑ Git integration
  ? Also enable database access? (y/N) n
```

### Example 3: Summary with Defer

```
╭─ Setup Complete! ──────────────────────────╮
│                                             │
│  ✓ Core features installed                 │
│  ✓ 3 skills enabled:                       │
│     - email                                 │
│     - calendar                             │
│     - discord                              │
│                                             │
│  5 recommended skills not installed:       │
│     - camera (for visual monitoring)       │
│     - tts (for audio responses)            │
│     - sms (for mobile alerts)              │
│     - exec (for system automation)         │
│     - location (for geo features)          │
│                                             │
│  ? Install recommended skills now? (y/N)   │
│    [y] Install all                         │
│    [c] Customize                           │
│    [n] Skip (install anytime)              │
│                                             │
╰─────────────────────────────────────────────╯
```

---

## Implementation Recommendations

### For OpenClaw Setup

1. **Start simple**: Offer 3-5 curated packs (Communication, Media, Developer, Home)
2. **Show value clearly**: Brief one-liner for each pack
3. **Default to recommended**: Pre-check common packs, let users uncheck
4. **Make it resumable**: Save choices to config, allow `openclaw setup continue`
5. **Post-install hints**: After first command, suggest related skills
6. **Low-friction activation**: `openclaw skill install <name>` should "just work"

### Technical Considerations

- **Check prerequisites**: Warn if skill needs API key, system permission, etc.
- **Graceful degradation**: Core features work even if optional skills fail
- **Clear error messages**: If installation fails, explain *why* and how to fix
- **Idempotent operations**: Re-running setup should be safe
- **State persistence**: Store enabled skills in `.openclaw/config.yml`

---

## Tools & Libraries Referenced

- **Inquirer.js**: Node.js library for interactive CLI prompts ([github.com/SBoudrias/Inquirer.js](https://github.com/SBoudrias/Inquirer.js))
- **@inquirer/checkbox**: Checkbox selection prompt ([npmjs.com/package/@inquirer/checkbox](https://www.npmjs.com/package/@inquirer/checkbox))
- **prompt-checkbox**: Grouped checkbox prompts ([npmjs.com/package/prompt-checkbox](https://www.npmjs.com/package/prompt-checkbox))
- **Vite (create-vite)**: Fast framework scaffolding ([vitejs.dev](https://vitejs.dev))
- **VS Code Walkthroughs API**: Extension onboarding ([code.visualstudio.com/api/ux-guidelines/walkthroughs](https://code.visualstudio.com/api/ux-guidelines/walkthroughs))
- **VS Code extensions.json**: Workspace recommendations ([code.visualstudio.com/docs](https://code.visualstudio.com/docs))

---

## Related Patterns in Other Tools

### Docker Desktop
- Offers "Resource Packs" (Kubernetes, WSL, etc.) post-install
- Shows each feature's resource cost
- Can enable/disable without reinstalling

### Rust (rustup)
- Installs core toolchain by default
- Suggests components based on first `cargo` command
- `rustup component add <name>` for opt-in features

### Cursor IDE
- Shows "Recommended Extensions" banner for workspace
- One-click "Install All" or individual selection
- Extensions load lazily (don't slow startup)

---

## Key Takeaways

1. **Non-blocking > Blocking**: Let users defer decisions
2. **Contextual > Upfront**: Suggest skills when relevant, not all at once
3. **Packs for beginners, individuals for experts**: Offer both paths
4. **Show value, not features**: "Email alerts" > "IMAP integration"
5. **Make it reversible**: Easy to install, easy to uninstall
6. **Progress indicators**: Users need to know "where am I in this process?"
7. **Skip should be obvious**: "Skip", "Later", "None" as first-class options

---

**End of Research**  
**Next Steps**: Design OpenClaw skill pack UX based on these patterns
