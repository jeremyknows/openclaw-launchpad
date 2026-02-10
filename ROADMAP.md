# OpenClaw Setup Guide — Roadmap

> Maintainer roadmap — not a user-facing document.

---

## Pre-Publish Checklist

- [ ] Configure git identity for the repository
- [ ] Choose repo name and visibility (public/private)
- [ ] Push to GitHub
- [ ] Browser QA testing in Safari, Chrome, Firefox (reference the QA checklist in commit history)
- [ ] Run `openclaw-verify.sh` on the target Mac
- [ ] Confirm all cross-file references are consistent (CVEs, version numbers, API key prefixes, access profiles)

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

---

## Known Limitations

- **autosetup.sh installs software on admin before creating bot user.** This is by design — Homebrew's initial install requires admin privileges, and `/opt/homebrew` is accessible to all users on Apple Silicon. The bot user inherits these tools after account switch.
- **OpenAI tier in HTML guide uses placeholder model names.** The model IDs have not been ground-truthed against a live OpenAI-routed deployment. Users selecting the OpenAI provider should verify model availability on their account.
