#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Content Creator Skills Installer
# Installs all skills for the Content Creator workflow template
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${CYAN}📱 Installing Content Creator Skills${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check Homebrew
if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}⚠️  Homebrew not found. Install it first:${NC}"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Add tap
echo "Adding steipete tap..."
brew tap steipete/tap 2>/dev/null || true

# Core skills (no API keys needed)
echo ""
echo -e "${GREEN}Installing core skills...${NC}"
brew install steipete/tap/gifgrep 2>/dev/null || echo "  gifgrep already installed"
brew install ffmpeg 2>/dev/null || echo "  ffmpeg already installed"

# API-dependent skills
echo ""
echo -e "${GREEN}Installing API-dependent skills...${NC}"
brew install steipete/tap/summarize 2>/dev/null || echo "  summarize already installed"
# Note: nano-banana-pro is a skill, not a brew package
# Note: tts uses built-in OpenClaw capability

echo ""
echo -e "${CYAN}✓ Core installation complete!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}API Keys Required:${NC}"
echo ""
echo "  For video/article summarization (summarize):"
echo "    export GEMINI_API_KEY=\"your-key\""
echo "    Get free: https://aistudio.google.com/app/apikey"
echo ""
echo "  For audio transcription (whisper-api):"
echo "    export OPENAI_API_KEY=\"your-key\""
echo "    Get key: https://platform.openai.com/api-keys"
echo ""
echo "  For image generation (nano-banana-pro):"
echo "    Uses your main AI provider (OpenRouter/Anthropic)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}🎉 Ready! Try asking your agent:${NC}"
echo "  • \"Summarize this video: [URL]\""
echo "  • \"Find me a 'mind blown' GIF\""
echo "  • \"Generate an image of a sunset over mountains\""
echo ""
