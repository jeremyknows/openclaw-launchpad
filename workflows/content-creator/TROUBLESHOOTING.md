# Content Creator Troubleshooting

Common issues and fixes for the Content Creator workflow template.

---

## Installation Issues

### ❌ Skills installation fails or incomplete

**Symptoms:**
- `skills.sh` exits with errors
- Tools like `summarize` or `gifgrep` not found
- API dependencies missing

**Causes:**
- Missing Homebrew
- Python/Node.js version issues
- Network connectivity problems

**Solutions:**

```bash
# 1. Ensure Homebrew is installed
which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Update Homebrew
brew update

# 3. Check available disk space
df -h ~

# 4. Install tools individually
brew install ffmpeg      # For video/audio processing
brew install imagemagick  # For image manipulation
pip3 install yt-dlp      # For YouTube downloads (if needed)

# 5. Verify installations
which ffmpeg && echo "✅ ffmpeg ready"
which convert && echo "✅ imagemagick ready"
```

---

## API Key Issues

### ❌ "No API key - summarize won't work"

**Symptoms:**
- Summarization fails
- "API key not found" errors
- Video transcription doesn't work

**Solutions:**

**Option 1: Gemini API (Recommended - Free tier available)**

```bash
# 1. Get API key from Google AI Studio
# Visit: https://aistudio.google.com/app/apikey

# 2. Set environment variable
export GEMINI_API_KEY="your-key-here"

# 3. Make it permanent
echo 'export GEMINI_API_KEY="your-key-here"' >> ~/.zshrc
source ~/.zshrc

# 4. Verify
echo $GEMINI_API_KEY
```

**Option 2: OpenAI API**

```bash
# 1. Get API key from OpenAI Platform
# Visit: https://platform.openai.com/api-keys

# 2. Set environment variable
export OPENAI_API_KEY="sk-your-key-here"

# 3. Make it permanent
echo 'export OPENAI_API_KEY="sk-your-key-here"' >> ~/.zshrc
source ~/.zshrc

# 4. Verify
echo $OPENAI_API_KEY
```

**Both set?** The tool will use Gemini first (cheaper), fall back to OpenAI if needed.

---

### ❌ API quota exceeded or billing errors

**Symptoms:**
- "Quota exceeded" errors
- "Billing not enabled" messages
- Rate limit errors

**Solutions:**

**For Gemini:**
- Free tier: 60 requests/minute
- Check usage: https://aistudio.google.com/app/apikey
- Upgrade to paid tier if needed

**For OpenAI:**
- Add payment method: https://platform.openai.com/account/billing
- Check usage: https://platform.openai.com/usage
- Set usage limits to avoid surprises

**Rate limiting:**
- Spread requests over time (don't batch 50 videos at once)
- Use cheaper models for simple tasks
- Cache results when possible

---

## Media Processing Issues

### ❌ Audio transcription fails

**Symptoms:**
- "Unsupported file format" errors
- Transcription hangs or times out
- Garbled or empty transcription results

**Solutions:**

**1. Check file format:**
```bash
# Supported: mp3, mp4, mpeg, mpga, m4a, wav, webm
# Check your file:
file your-audio.aiff  # Shows actual format

# Convert if needed:
ffmpeg -i input.aiff -ar 16000 output.mp3
```

**2. Check file size:**
- OpenAI Whisper limit: 25 MB
- For larger files, split them:
```bash
ffmpeg -i large-file.mp3 -f segment -segment_time 600 -c copy output%03d.mp3
```

**3. Verify API key:**
```bash
echo $OPENAI_API_KEY
# Should start with sk-
```

**4. Try with a known-good file first:**
- Download a short test MP3
- Verify the tool works before debugging your file

---

### ❌ Video download fails (YouTube, etc.)

**Symptoms:**
- "Video unavailable" errors
- Download hangs or times out
- Partial downloads

**Solutions:**

```bash
# 1. Update yt-dlp (if using for downloads)
pip3 install --upgrade yt-dlp

# 2. Check video is actually accessible
# Try opening URL in browser first

# 3. Some videos are geo-restricted or private
# Use videos you have permission to download

# 4. For age-restricted content, use cookies:
yt-dlp --cookies-from-browser chrome [URL]
```

**Platform-specific issues:**
- **YouTube:** Changes API frequently, update yt-dlp often
- **Twitter/X:** May require authentication
- **TikTok:** Use specific yt-dlp format selectors

---

### ❌ Image generation produces poor results

**Symptoms:**
- Images don't match description
- Distorted or low-quality output
- Wrong aspect ratio or style

**Solutions:**

**1. Be more specific in prompts:**

❌ Bad: "a house"
✅ Good: "A modern minimalist house with large windows, surrounded by trees, photographed at golden hour, architectural photography style"

**2. Use negative prompts:**
```
Prompt: "Cozy coffee shop interior, warm lighting, plants"
Negative: "no people, no text, no watermarks, no logos"
```

**3. Specify style explicitly:**
- "in the style of [artist/movement]"
- "photograph" vs "illustration" vs "3D render"
- "minimalist" vs "detailed" vs "abstract"

**4. Try multiple variations:**
> "Generate 3 variations of: [your prompt]"

**5. Iterate on what works:**
> "The second one is close! Make it more [adjustment]"

---

### ❌ GIF search returns nothing or wrong results

**Symptoms:**
- "No GIFs found" errors
- Results don't match search term
- Broken GIF links

**Solutions:**

**1. Try broader search terms:**
- ❌ "ecstatic joy celebration confetti"
- ✅ "celebration" or "excited"

**2. Verify term on GIPHY:**
- Visit: https://giphy.com/search/[your-term]
- If nothing there, refine your search

**3. Check internet connection:**
```bash
ping giphy.com
```

**4. Try alternative phrasing:**
- "shocked" vs "surprised"
- "laughing" vs "funny"
- "fail" vs "mistake"

**5. Some terms are restricted:**
- GIPHY filters certain content
- Try related but family-friendly terms

---

## File Organization Issues

### ❌ Generated images/files hard to find

**Symptoms:**
- Files scattered across folders
- No consistent naming
- Lost track of what's been created

**Solutions:**

**1. Create organized structure:**
```bash
mkdir -p ~/.openclaw/workspace/images/2026-02
mkdir -p ~/.openclaw/workspace/content/{ideas,drafts,published}
mkdir -p ~/.openclaw/workspace/transcripts
```

**2. Use consistent naming:**
- Date prefix: `2026-02-11-topic.png`
- Topic-based: `product-launch-hero.png`
- Sequential: `episode-42-thumbnail-v3.png`

**3. Ask agent to organize:**
> "Save all today's images to ~/.openclaw/workspace/images/2026-02/ with descriptive names"

**4. Use git for version control:**
```bash
cd ~/.openclaw/workspace
git init
git add .
git commit -m "Content work for [date]"
```

---

## Content Quality Issues

### ❌ Summaries miss key points

**Symptoms:**
- Important details omitted
- Summary too shallow
- Misses context or nuance

**Solutions:**

**1. Request specific format:**
> "Summarize with:
> - Main thesis
> - 3-5 key points with timestamps
> - Quotable moments
> - Controversial takes"

**2. For long content, process in chunks:**
> "Read first 10 minutes, summarize, then continue"

**3. Ask for depth:**
> "Give me a detailed summary, not just bullet points"

**4. Iterate on output:**
> "Good start, but you missed the part about [topic]. Add that."

---

### ❌ Generated content doesn't match brand voice

**Symptoms:**
- Too formal or too casual
- Wrong tone
- Doesn't sound like you

**Solutions:**

**1. Update AGENTS.md with specific voice guidance:**
```markdown
## Brand Voice
- Casual but authoritative
- Use short sentences (10-15 words max)
- Minimalist — no unnecessary adjectives
- Tech-focused, slightly sarcastic
- NEVER use emojis in headlines
- Examples: [paste 3-5 examples of your writing]
```

**2. Provide examples every time:**
> "Here's how I'd write it: [example]. Draft 5 similar tweets."

**3. Request rewrites:**
> "Too formal. Make it sound more conversational, like I'm talking to a friend."

---

## Platform-Specific Gotchas

### macOS

**Photo Library access required:**
- System Settings → Privacy & Security → Photos
- Enable Terminal (or your preferred terminal app)

**APFS case-sensitivity:**
- `Image.png` ≠ `image.png`
- Use consistent capitalization

**Sandboxing restrictions:**
- Some apps can't access certain folders
- Move files to ~/Downloads or ~/Documents if access denied

---

### YouTube

**Copyright restrictions:**
- Can't download copyrighted music videos
- Use videos marked "Creative Commons"
- Or ensure you have permission

**Age restrictions:**
- Some videos require sign-in
- Use `--cookies-from-browser` with yt-dlp

---

### Social Media Platforms

**X/Twitter:**
- API access requires developer account
- Public API has rate limits
- Use official apps when possible

**Instagram:**
- Difficult to download content programmatically
- Most tools violate TOS
- Use screenshot/screen record instead

**TikTok:**
- Watermarks on downloads
- Frequently changes download methods
- Update tools regularly

---

## Recovery Procedures

### Full template reset

**If everything's broken and you want to start fresh:**

```bash
# 1. Backup current work
cp -r ~/.openclaw/workspace/content ~/Desktop/content-backup
cp ~/.openclaw/workspace/AGENTS.md ~/.openclaw/workspace/AGENTS.md.backup

# 2. Clear API keys (optional)
unset GEMINI_API_KEY
unset OPENAI_API_KEY

# 3. Reinstall skills
bash ~/Downloads/openclaw-setup/workflows/content-creator/skills.sh

# 4. Reset AGENTS.md
cp ~/Downloads/openclaw-setup/workflows/content-creator/AGENTS.md ~/.openclaw/workspace/

# 5. Set API keys fresh
export GEMINI_API_KEY="your-key"
echo 'export GEMINI_API_KEY="your-key"' >> ~/.zshrc

# 6. Test
echo "Summarize this video: https://www.youtube.com/watch?v=dQw4w9WgXcQ" | openclaw
```

---

### Switching to a different template

**To switch from content-creator to another workflow:**

```bash
# 1. Disable content-creator crons
openclaw cron list | grep content
openclaw cron update <job-id> --enabled false

# 2. Archive current AGENTS.md
mv ~/.openclaw/workspace/AGENTS.md ~/.openclaw/workspace/AGENTS.content.md

# 3. Install new template
cd ~/Downloads/openclaw-setup/workflows/[new-template]/
bash skills.sh
cp AGENTS.md ~/.openclaw/workspace/

# 4. Keep useful skills (ffmpeg, imagemagick, etc.)
# These are valuable for many workflows
```

---

### Clean up disk space (images/videos accumulating)

**Content creation generates lots of files:**

```bash
# 1. Check disk usage
du -sh ~/.openclaw/workspace/*

# 2. Archive old content
mkdir ~/Archive/openclaw-2026-01
mv ~/.openclaw/workspace/images/2026-01 ~/Archive/openclaw-2026-01/

# 3. Compress before archiving
tar -czf ~/Archive/content-2026-01.tar.gz ~/.openclaw/workspace/images/2026-01
rm -rf ~/.openclaw/workspace/images/2026-01

# 4. Set up automated cleanup (cron job)
# Delete images older than 90 days:
find ~/.openclaw/workspace/images -type f -mtime +90 -delete
```

---

## Getting More Help

**API-specific issues:**
- **Gemini:** https://ai.google.dev/docs
- **OpenAI:** https://platform.openai.com/docs
- **GIPHY:** https://developers.giphy.com/docs/api

**Tool-specific issues:**
- **ffmpeg:** https://ffmpeg.org/documentation.html
- **yt-dlp:** https://github.com/yt-dlp/yt-dlp#readme
- **ImageMagick:** https://imagemagick.org/script/command-line-processing.php

**Ask your agent:**
> "Why isn't video summarization working? Here's the error: [paste error]"
> "Help me debug this image generation issue"
> "My GIF search keeps failing, what's wrong?"

**OpenClaw community:**
- GitHub issues: https://github.com/steipete/openclaw/issues
- Discord: [link if available]

---

**Last updated:** 2026-02-11
