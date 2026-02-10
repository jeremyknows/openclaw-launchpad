# OpenClaw Setup Guide — Roadmap

> Maintainer roadmap — not a user-facing document.

---

## Completed (Security Hardening)

These items were implemented across `openclaw-autosetup.sh` and `openclaw-verify.sh`:

- [x] **C1: Shell injection fix** — All 22 Python-embedded blocks rewritten to use `sys.argv` + `<< 'PYEOF'` single-quoted heredocs (prevents arbitrary code execution via crafted filenames/values)
- [x] **C2/C3: Secrets migration** — New `step_harden_secrets()` function migrates 7 known secret paths from plaintext to `${VAR_NAME}` env var references, stores values in LaunchAgent plist
- [x] **H1: mDNS/Bonjour disable** — `OPENCLAW_DISABLE_BONJOUR=1` added to plist EnvironmentVariables
- [x] **H2: Explorer profile browser deny** — `tools.deny: ["browser"]` applied to Explorer access profile
- [x] **H3: requireMention defaults** — Primary Discord channel gets `false`, all others get `true`
- [x] **H4: Cryptographic gateway token** — `openssl rand -hex 32` generates 64-char hex token if missing or weak (<32 chars)
- [x] **H5: FileVault check** — New section 13 in verify.sh checks `fdesetup status`
- [x] **M5: Backup file permissions** — `cp -p` preserves permissions on config backups
- [x] **Discord config builder** — Rewritten with sys.argv, input validation for numeric IDs
- [x] **Step count updates** — Full: 19 steps (was 18), Minimal: 17 (was 16)
- [x] **Completion message** — Added Foundation Playbook Phase 1 reminder + gateway rewrite gotcha warning

---

## Remaining: Open-Source Readiness

### Must-do before first public release

- [x] **Doc content gap: security features** — All 6 security features documented across all 5 doc files, voice-adapted per audience (Session 5)
- [x] **Remove review artifacts** — `.gitignore` updated; `REVIEW-*.md` and `IMPLEMENTATION-PLAN.md` excluded from repo (Session 5)
- [x] **Git identity + repo setup** — Pushed to `github.com/jeremyknows/openclaw-for-beginners` (private), 4 commits on main (Session 5)
- [ ] **Browser QA testing** — Safari, Chrome, Firefox for HTML guide
- [ ] **Fresh Mac QA** — Run `openclaw-autosetup.sh` end-to-end on a clean macOS install
- [ ] **Run `openclaw-verify.sh`** on the target Mac after autosetup
- [ ] **Cross-file consistency audit** — Verify CVEs, version numbers, API key prefixes, access profiles are consistent across all 7 content files (use `/multi-document-consistency-audit` skill)

### Should-do before v1.0

- [ ] **CONTRIBUTING.md** — Contributor guidelines, how to run scripts, how to test changes
- [ ] **SECURITY.md** — Threat model, known limitations (gateway plaintext rewrite), responsible disclosure process
- [ ] **workspace-scaffold-prompt.md** — Add "skip this if you ran autosetup" header
- [ ] **Foundation Playbook TOC** — Add table of contents with anchors (it's 1,500 lines)

---

## Deferred Items

| Item | Priority | Notes |
|------|----------|-------|
| Tailscale remote access guidance | P1 | How to SSH/VNC into the bot Mac securely from anywhere |
| Mem0 / Cognee memory plugins | P2 | Long-term memory integrations for agent sessions |
| Model routing / cost optimization guide | P2 | When to use which model, cost projections, routing strategies |
| DigitalOcean 1-click deployment | P2 | Cloud alternative to running on a physical Mac |
| Command allowlists | P2 | Granular control over which shell commands agents can execute |
| iOS companion app documentation | P2 | Mobile monitoring and quick-reply setup |
| Firewall verification in `openclaw-verify.sh` | P2 | Add check: `socketfilterfw --getglobalstate` should report "enabled" |
| Split Foundation Playbook | P2 | Phase 1 (security, mandatory) separate from Phases 2-8 (optional) |
| Shorten file names | P3 | Drop `OPENCLAW-` prefix for cleaner tree (controversial — may break existing references) |
| Deduplicate AGENTS.md/SOUL.md safety rules | P3 | Both contain overlapping safety boundaries |

---

## Known Limitations

- **autosetup.sh installs software on admin before creating bot user.** This is by design — Homebrew's initial install requires admin privileges, and `/opt/homebrew` is accessible to all users on Apple Silicon. The bot user inherits these tools after account switch.
- **OpenAI tier in HTML guide uses placeholder model names.** The model IDs have not been ground-truthed against a live OpenAI-routed deployment. Users selecting the OpenAI provider should verify model availability on their account.
- **Gateway rewrites `${VAR_NAME}` back to plaintext.** OpenClaw resolves env var references and writes resolved values back to `openclaw.json` on restart. The LaunchAgent plist is the canonical secret store. This is OpenClaw behavior, not a script bug.
- **Discord `requireMention` for primary channel defaults to `false`.** This means the bot responds to every message in its primary channel without being @mentioned. Users with busy primary channels should consider setting it to `true`.
