---
name: markdown-fetch
description: |
  Fetch web content as clean markdown using markdown.new proxy. Use when:
  (1) researching any topic online, (2) reading documentation or blog posts,
  (3) analyzing webpage content, (4) any web_fetch where you need the text content.
  Reduces token usage by 80% compared to raw HTML. Skip only for API endpoints,
  raw files, or when you specifically need HTML structure for scraping.
license: MIT
metadata:
  author: jeremyknows
  version: "1.0.0"
---

# Markdown Fetch

Fetch web content as clean markdown, not HTML bloat.

**TL;DR:** Prepend `markdown.new/` to any URL → 80% fewer tokens.

## Why This Matters

HTML wastes tokens. A typical blog post:
- **HTML:** 16,000 tokens
- **Markdown:** 3,000 tokens
- **Savings:** 80% reduction

More content fits in your context window. Lower costs. Better results.

## How It Works

**markdown.new** is a universal proxy that converts any webpage to markdown:

1. **Primary:** Tries Cloudflare's native `Accept: text/markdown` content negotiation
2. **Fallback 1:** Workers AI `toMarkdown()` conversion
3. **Fallback 2:** Browser Rendering API for JS-heavy pages

Every request gets the best possible markdown.

## Usage

### Basic Pattern

Prepend `markdown.new/` to any URL:

```
# Instead of:
web_fetch url="https://docs.example.com/guide"

# Use:
web_fetch url="https://markdown.new/https://docs.example.com/guide"
```

### Examples

**Research a topic:**
```
web_fetch url="https://markdown.new/https://blog.cloudflare.com/markdown-for-agents/"
```

**Read documentation:**
```
web_fetch url="https://markdown.new/https://nextjs.org/docs/app/building-your-application"
```

**Analyze a news article:**
```
web_fetch url="https://markdown.new/https://www.nytimes.com/2026/02/15/technology/ai-agents.html"
```

## When to Skip markdown.new

Use raw fetch (without markdown.new) when:

- **API endpoints** — Already return JSON/text, no conversion needed
- **Raw files** — `.txt`, `.md`, `.json`, `.csv` files
- **HTML scraping** — Need specific elements, attributes, or form structure
- **Binary content** — Images, PDFs (though markdown.new handles these too)
- **Internal/private URLs** — Don't proxy sensitive content through external services
- **Paywalled content** — markdown.new can't bypass authentication

## Response Format

markdown.new returns clean markdown with metadata:

```markdown
Title: Page Title Here

URL Source: https://original-url.com/page

Markdown Content:
# Heading

The actual content in clean markdown...
```

## Token Estimation

The response includes an `x-markdown-tokens` header with estimated token count. Use this for:
- Context window management
- Chunking decisions
- Cost estimation

## Troubleshooting

| Issue | Solution |
|-------|----------|
| 500 error from markdown.new | Site may block proxies — try direct fetch |
| Content looks incomplete | JS-heavy page — markdown.new uses browser rendering as fallback |
| Need HTML structure | Skip markdown.new, use raw `web_fetch` |
| Rate limited | Space out requests, markdown.new has generous limits |

## Privacy & Security

**markdown.new is an external proxy.** All URLs you fetch pass through Cloudflare's infrastructure.

- ✅ Fine for: Public docs, blogs, news, research
- ❌ Avoid for: Internal company URLs, authenticated sessions, sensitive data

If privacy is critical, fetch directly and accept the token overhead.

## Background

Cloudflare's "Markdown for Agents" (February 2026) enables sites to serve markdown directly via content negotiation. markdown.new extends this to ANY website on the internet — even those that haven't enabled the feature.

**Reference:** https://blog.cloudflare.com/markdown-for-agents/

## Two Ways to Use This

### Option 1: System-Level Default (Recommended)

Add this to your `AGENTS.md` to make markdown-first the default for all web fetching:

```markdown
## 🌐 Web Content: Markdown First

**The Rule:** Always prefer markdown over HTML when fetching web content.

**Why:** HTML wastes tokens. A typical blog post: 16,000 tokens as HTML → 3,000 as markdown. **80% reduction.**

**The Protocol:**
1. **First choice:** Use `markdown.new/{url}` proxy — works on ANY website
2. **Direct fetch:** If using `web_fetch`, the tool handles markdown extraction
3. **Raw HTML:** Only when you specifically need HTML structure (forms, attributes, scraping)

**How to use markdown.new:**
\`\`\`
# Instead of:
web_fetch url="https://example.com/article"

# Prefer:
web_fetch url="https://markdown.new/https://example.com/article"
\`\`\`

**When markdown.new is overkill:**
- URLs you know return clean text/JSON (APIs, raw files)
- Sites that already support `Accept: text/markdown` (Cloudflare-enabled)
- When you need specific HTML elements for scraping
- Internal/private URLs (don't proxy through external services)

**Cost of skipping:** 3-5x more tokens per page = faster context exhaustion, higher costs.
```

This makes it a protocol your agent follows automatically.

### Option 2: Selective Use (This Skill)

Reference this skill when you want markdown fetching on specific tasks without changing system behavior. The agent will read this SKILL.md and apply the pattern for that session only.

**The Rule:** Default to markdown.new for all web content fetching. Skip only when you have a specific reason (APIs, scraping, raw files, private URLs).
