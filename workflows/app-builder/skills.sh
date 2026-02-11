#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# App Builder Skills Installer
# Installs all skills for the App Builder workflow template
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${CYAN}🛠️  Installing App Builder Skills${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check Homebrew
if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}⚠️  Homebrew not found. Install it first:${NC}"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Add taps
echo "Adding taps..."
brew tap steipete/tap 2>/dev/null || true

# Core development tools
echo ""
echo -e "${GREEN}Installing development tools...${NC}"
brew install gh 2>/dev/null || echo "  gh (GitHub CLI) already installed"
brew install jq 2>/dev/null || echo "  jq already installed"
brew install fzf 2>/dev/null || echo "  fzf already installed"

# Documentation tools
echo ""
echo -e "${GREEN}Installing documentation tools...${NC}"
brew install steipete/tap/summarize 2>/dev/null || echo "  summarize already installed"

# Optional but recommended
echo ""
echo -e "${GREEN}Installing recommended extras...${NC}"
brew install tmux 2>/dev/null || echo "  tmux already installed"
brew install ripgrep 2>/dev/null || echo "  ripgrep already installed"

echo ""
echo -e "${CYAN}✓ Core installation complete!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}Setup Required:${NC}"
echo ""
echo "  1. Authenticate GitHub CLI:"
echo "     gh auth login"
echo "     (Opens browser for GitHub OAuth)"
echo ""
echo "  2. (Optional) Set up summarize for docs:"
echo "     export GEMINI_API_KEY=\"your-key\""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}🎉 Ready! Try asking your agent:${NC}"
echo "  • \"Show me open PRs in this repo\""
echo "  • \"Check CI status for the latest commit\""
echo "  • \"Create an issue: Bug in login flow\""
echo "  • \"Help me refactor this function\""
echo ""
