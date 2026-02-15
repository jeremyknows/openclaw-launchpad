# markdown-fetch

Fetch web content as clean markdown using the markdown.new proxy. 80% fewer tokens than raw HTML.

## What It Does

- Converts any webpage to clean markdown automatically
- Uses Cloudflare's three-tier conversion pipeline
- Works on ANY website, not just Cloudflare-enabled ones
- Includes token estimation in response headers

## Install

### Claude Code / OpenClaw

```bash
# Clone to your skills directory
git clone https://github.com/jeremyknows/markdown-fetch.git ~/.openclaw/skills/markdown-fetch
```

### Cursor / Other Agents

Add to your skills configuration or copy `SKILL.md` to your agent's skills directory.

## Usage

### Natural Language

Just ask your agent:

> "Research the Cloudflare markdown for agents announcement"

> "Read the Next.js app router documentation"

> "Summarize this article: https://example.com/post"

The agent will automatically use markdown.new for efficient fetching.

### Direct Usage

Prepend `markdown.new/` to any URL:

```
web_fetch url="https://markdown.new/https://example.com/article"
```

## When to Use

| Scenario | Use markdown.new? |
|----------|-------------------|
| Research / reading articles | ✅ Yes |
| Documentation lookup | ✅ Yes |
| News analysis | ✅ Yes |
| API endpoints | ❌ No (already JSON) |
| HTML scraping | ❌ No (need structure) |
| Raw files (.md, .txt) | ❌ No (already clean) |

## Token Savings

Real-world example from Cloudflare's blog:

| Format | Tokens |
|--------|--------|
| HTML | 16,180 |
| Markdown | 3,150 |
| **Savings** | **80%** |

## How It Works

markdown.new uses a three-tier pipeline:

1. **Primary:** Cloudflare's native `Accept: text/markdown` (instant)
2. **Fallback 1:** Workers AI `toMarkdown()` conversion (fast)
3. **Fallback 2:** Browser Rendering API (for JS-heavy pages)

## Two Ways to Use

### System-Level (Recommended)

Add the AGENTS.md snippet from SKILL.md to make markdown-first your agent's default behavior. Every web fetch will use markdown.new automatically.

### Selective

Reference this skill for specific tasks. The agent reads SKILL.md and applies the pattern for that session only.

## Privacy & Security

**markdown.new is Cloudflare's proxy.** Every URL passes through their infrastructure.

| Safe | Avoid |
|------|-------|
| Public docs, blogs, news | Internal company URLs |
| Open source repos | Authenticated sessions |
| Research / articles | Sensitive data |

If privacy matters, fetch directly and accept the token cost.

## Limitations

- Some sites block proxy requests (rare)
- Very dynamic/JS-heavy pages may take longer
- Not suitable when you need HTML structure
- Can't bypass paywalls or authentication
- **Don't use for internal/private URLs** — all traffic passes through Cloudflare

## References

- [Cloudflare: Markdown for Agents](https://blog.cloudflare.com/markdown-for-agents/)
- [markdown.new](https://markdown.new)

## License

MIT
