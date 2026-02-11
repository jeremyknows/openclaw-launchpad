#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Workflow Optimizer Skills Installer
# Installs all skills for the Workflow Optimizer template
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${CYAN}📅 Installing Workflow Optimizer Skills${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
brew tap antoniorodr/memo 2>/dev/null || true

# Native macOS integrations (no API keys)
echo ""
echo -e "${GREEN}Installing macOS integrations...${NC}"
brew install antoniorodr/memo/memo 2>/dev/null || echo "  memo (Apple Notes) already installed"
brew install steipete/tap/remindctl 2>/dev/null || echo "  remindctl (Apple Reminders) already installed"

# Productivity tools
echo ""
echo -e "${GREEN}Installing productivity tools...${NC}"
brew install steipete/tap/gogcli 2>/dev/null || echo "  gog (Google Workspace) already installed"
brew install himalaya 2>/dev/null || echo "  himalaya (Email) already installed"
brew install steipete/tap/summarize 2>/dev/null || echo "  summarize already installed"
brew install 1password-cli 2>/dev/null || echo "  1password-cli already installed"

echo ""
echo -e "${CYAN}✓ Core installation complete!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}Setup Required:${NC}"
echo ""
echo "  1. Grant macOS permissions when prompted:"
echo "     System Settings → Privacy & Security → Automation"
echo ""
echo "  2. Google Workspace (gog) — OAuth login:"
echo "     gog auth login"
echo "     (Opens browser for Google sign-in)"
echo ""
echo "  3. Email (himalaya) — Configure ~/.config/himalaya/config.toml"
echo "     See: himalaya --help"
echo ""
echo "  4. 1Password — Enable CLI integration:"
echo "     1Password app → Settings → Developer → CLI Integration"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}🎉 Ready! Try asking your agent:${NC}"
echo "  • \"What's on my calendar today?\""
echo "  • \"Add a reminder to call mom tomorrow at 3pm\""
echo "  • \"Show me unread emails from this week\""
echo "  • \"Create a note about today's meeting\""
echo ""
