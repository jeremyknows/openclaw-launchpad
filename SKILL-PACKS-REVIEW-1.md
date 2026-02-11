## Skill Packs Review — Cycle 1

### UX Issues

- **No validation on multi-select input**: User can type "1,2,3,4" and get packs 1-3 installed plus "skipped" message. The skip option (5) doesn't override other selections.
  - **Fix**: Check if "5" is present first, then exit immediately without processing other numbers. Or make it clear that 5 is mutually exclusive.

- **Empty input uses default "5"**: Pressing Enter skips all packs, which is fine, but this isn't explicitly stated in the prompt.
  - **Fix**: Add "(Enter to skip)" to the prompt text.

- **No feedback during installation**: Multi-pack installation happens silently with only "Installing X Pack..." messages. User doesn't know what succeeded/failed if errors occur.
  - **Fix**: Add individual pass/fail messages for each installation step (brew installs, AGENTS.md appends).

- **Skill pack descriptions don't match reality**: Quality Pack says it adds "Better debugging & code review" but only appends documentation — no actual skills are installed. Users might expect tools.
  - **Fix**: Clarify that Quality Pack adds "methodology guides" not tools. Or actually install/enable those skills if they exist.

- **Mixed terminology**: "Skills" vs "Packs" vs "Tools" — the user sees "systematic-debugging" mentioned but no clarity on whether it's a command, a methodology, or documentation.
  - **Fix**: Add a brief explainer: "Note: Skills marked with workflow icon are methodologies (not commands). Use them when planning work."

### Logic Issues

- **Brew tap not added before install**: Research Pack installs `steipete/tap/summarize` but never runs `brew tap steipete/tap`. This will fail on fresh systems.
  - **Fix**: Add `brew tap steipete/tap 2>/dev/null || true` before installing `summarize`.

- **Silent failures on brew installs**: All brew commands use `2>/dev/null || true` which swallows errors. User has no idea if ffmpeg or summarize actually installed.
  - **Fix**: Capture exit status and report. Example:
    ```bash
    if brew install ffmpeg 2>/dev/null; then
        pass "ffmpeg installed"
    else
        warn "ffmpeg install failed (might already be installed)"
    fi
    ```

- **AGENTS.md corruption risk**: Using `cat >> "$workspace_dir/AGENTS.md"` without checking if file exists or is writable. If step3_start() failed to create the file, this will create a malformed file.
  - **Fix**: Verify file exists and has content before appending. Or use a safer append with newline guarantee:
    ```bash
    [ -f "$workspace_dir/AGENTS.md" ] || die "AGENTS.md not found"
    echo "" >> "$workspace_dir/AGENTS.md"  # Ensure newline
    cat >> "$workspace_dir/AGENTS.md" << 'EOF'
    ```

- **No deduplication**: If user runs the script twice and selects same packs, AGENTS.md will have duplicate sections. No check for existing pack markers.
  - **Fix**: Add markers like `# === QUALITY PACK START ===` and check for them before appending. Or use idempotent logic.

- **Quality Pack references non-existent skills**: Lists "systematic-debugging", "verification-before-completion", "test-driven-development", "complete-code-review", "receiving-feedback" but these aren't installed or verified to exist.
  - **Fix**: Either install these skills (if they exist in openclaw registry), or make it clear these are guidelines to follow, not commands to run.

### Missing/Wrong

- **Wrong**: Research Pack description says "x-research (Twitter)" but installs skill name "x-research-skill" in the table. Inconsistent naming.

- **Missing**: No validation that the workspace directory is writable before attempting appends.

- **Missing**: No rollback or cleanup if installation partially fails. If pack 2 fails, pack 1's AGENTS.md changes remain.

- **Missing**: Home Pack mentions `imsg` and `wacli` need `brew install steipete/tap/*` but doesn't offer to install them or add the tap. User is left with incomplete instructions.

- **Missing**: No way to list installed packs later. User can't easily see what they've already added.

- **Wrong**: Media Pack says "Whisper needs OPENAI_API_KEY" but doesn't check if it's set or offer to configure it.

- **Wrong**: Video-frames skill is mentioned but nothing in the script installs or references video processing tools beyond ffmpeg.

- **Missing**: No guidance on skill precedence/conflicts. What if content-creator template already added similar skills?

### Recommendations

**Priority 1 (Blockers):**
1. **Fix brew tap issue**: Add `brew tap steipete/tap` before installing summarize in Research Pack.
2. **Fix skip logic**: Make option "5" immediately return without processing other numbers.
3. **Add AGENTS.md safety check**: Verify file exists and add deduplication markers.

**Priority 2 (Quality):**
4. **Add installation feedback**: Show pass/fail for each brew command with proper error handling.
5. **Clarify Quality Pack**: Either install actual skill tools or rename to "Methodology Pack" and make it clear these are guidelines.
6. **Fix skill name inconsistencies**: "x-research" vs "x-research-skill", decide on one.

**Priority 3 (Polish):**
7. **Add idempotency**: Check for existing pack markers before appending to prevent duplicates.
8. **Add post-install verification**: After installing a pack, verify the tools are actually available (`command -v summarize`).
9. **Better timing placement**: Consider offering skill packs BEFORE gateway start — if packs fail, user can retry without restarting gateway.
10. **Add pack manifest**: Create `~/.openclaw/workspace/.installed-packs.txt` to track what's installed for later reference.

**Priority 4 (Future):**
11. **Interactive install for dependencies**: For Home Pack, offer to run `brew tap` and install imsg/wacli interactively.
12. **Validate against AGENTS.md template**: If template already has research skills, don't duplicate in Research Pack.
13. **Add `openclaw packs list` command**: Let users see installed packs and manage them post-setup.

---

## Summary

The skill packs feature is a great idea but needs refinement:
- **Critical issues**: Missing brew tap, no input validation on skip option, AGENTS.md append safety
- **UX gaps**: Silent failures, confusing skill descriptions, no feedback loop
- **Architecture question**: Should this run before or after gateway start? Current placement means if packs fail, bot is already running but incomplete.

**Recommended next cycle**: Fix the three Priority 1 items, then test with fresh macOS install.
