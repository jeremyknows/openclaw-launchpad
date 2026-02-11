#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# OpenClaw Quickstart v2 — 2 Questions to Running Bot
#
# Simplified from v1 (7 questions → 2 questions)
# Smart inference handles the rest.
#
# Usage:
#   bash openclaw-quickstart-v2.sh
# ═══════════════════════════════════════════════════════════════════
set -euo pipefail

# ─── Constants ───
readonly SCRIPT_VERSION="2.2.0"
readonly MIN_NODE_VERSION="22"
readonly DEFAULT_GATEWAY_PORT=18789

# ─── Colors ───
GREEN='\033[0;32m'
DIM='\033[2m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PASS="${GREEN}✓${NC}"
FAIL="${RED}✗${NC}"
INFO="${CYAN}→${NC}"
STEP="${BOLD}${CYAN}>>>${NC}"

pass()   { echo -e "  ${PASS} $1"; }
fail()   { echo -e "  ${FAIL} $1"; }
info()   { echo -e "  ${INFO} $1"; }
warn()   { echo -e "  ${YELLOW}!${NC} $1"; }

die() {
    echo -e "\n  ${FAIL} ${RED}ERROR:${NC} $1" >&2
    exit 1
}

prompt() {
    local question="$1"
    local default="${2:-}"
    local response
    
    if [ -n "$default" ]; then
        echo -en "\n  ${CYAN}?${NC} ${question} [${default}]: "
    else
        echo -en "\n  ${CYAN}?${NC} ${question}: "
    fi
    
    read -r response
    if [ -z "$response" ] && [ -n "$default" ]; then
        echo "$default"
    else
        echo "$response"
    fi
}

confirm() {
    local question="$1"
    local response
    echo -en "\n  ${CYAN}?${NC} ${question} [y/N]: "
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c] " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ═══════════════════════════════════════════════════════════════════
# STEP 1: Auto-Install Dependencies (unchanged from v1)
# ═══════════════════════════════════════════════════════════════════

step1_install() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  ${STEP} ${BOLD}Step 1: Install${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Check macOS
    if [ "$(uname -s)" != "Darwin" ]; then
        die "This script is for macOS only."
    fi
    pass "macOS detected"
    
    # Check/install Homebrew
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || \
            die "Homebrew installation failed"
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        pass "Homebrew installed"
    else
        pass "Homebrew found"
    fi
    
    # Check/install Node.js
    local node_ok=false
    if command -v node &>/dev/null; then
        local node_ver
        node_ver=$(node --version | sed 's/v//' | cut -d. -f1)
        if [ "$node_ver" -ge "$MIN_NODE_VERSION" ] 2>/dev/null; then
            pass "Node.js $(node --version) found"
            node_ok=true
        fi
    fi
    
    if ! $node_ok; then
        info "Installing Node.js 22..."
        brew install node@22 &>/dev/null &
        spinner $!
        wait
        if ! command -v node &>/dev/null; then
            brew link --overwrite node@22 &>/dev/null || true
            export PATH="$(brew --prefix)/opt/node@22/bin:$PATH"
        fi
        pass "Node.js installed"
    fi
    
    # Check/install OpenClaw
    if command -v openclaw &>/dev/null; then
        pass "OpenClaw found"
    else
        info "Installing OpenClaw..."
        curl -fsSL https://openclaw.ai/install.sh | bash || \
            die "OpenClaw installation failed"
        export PATH="$HOME/.openclaw/bin:$PATH"
        pass "OpenClaw installed"
    fi
}

# ═══════════════════════════════════════════════════════════════════
# Guided API Key Signup
# ═══════════════════════════════════════════════════════════════════

guided_api_signup() {
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  Let's get you an API key (free, ~60 seconds)${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  I'll open ${CYAN}OpenRouter${NC} in your browser."
    echo ""
    echo -e "  ${BOLD}Follow these steps:${NC}"
    echo -e "  1. Sign up (Google/GitHub = fastest)"
    echo -e "  2. Click ${CYAN}\"Create Key\"${NC}"
    echo -e "  3. Name it ${CYAN}\"OpenClaw\"${NC}"
    echo -e "  4. Copy the key (starts with ${DIM}sk-or-${NC})"
    echo -e "  5. Come back here and paste it"
    echo ""
    
    if confirm "Open OpenRouter now?"; then
        # Open browser
        if command -v open &>/dev/null; then
            open "https://openrouter.ai/keys" 2>/dev/null
        elif command -v xdg-open &>/dev/null; then
            xdg-open "https://openrouter.ai/keys" 2>/dev/null
        else
            echo -e "  ${INFO} Open this URL: ${CYAN}https://openrouter.ai/keys${NC}"
        fi
        
        echo ""
        echo -e "  ${DIM}Browser opened. Complete signup, then paste your key below.${NC}"
        echo -e "  ${DIM}(No payment required — free tier available)${NC}"
        echo ""
    else
        echo ""
        echo -e "  ${INFO} When ready, go to: ${CYAN}https://openrouter.ai/keys${NC}"
        echo ""
    fi
    
    # Wait for key
    local key=""
    while [ -z "$key" ]; do
        key=$(prompt "Paste your OpenRouter key")
        
        if [ -z "$key" ]; then
            if confirm "Skip for now? (You can add a key later)"; then
                warn "No API key — bot will have limited functionality"
                echo ""
                return ""
            fi
        elif [[ ! "$key" == sk-or-* ]]; then
            warn "That doesn't look like an OpenRouter key (should start with sk-or-)"
            if ! confirm "Use it anyway?"; then
                key=""
            fi
        fi
    done
    
    pass "Got it!"
    echo "$key"
}

# ═══════════════════════════════════════════════════════════════════
# STEP 2: Configuration (3 Questions)
# ═══════════════════════════════════════════════════════════════════

step2_configure() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  ${STEP} ${BOLD}Step 2: Configure (2 questions)${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    
    # ─── Question 1: API Key (with guided signup) ───
    echo ""
    echo -e "${BOLD}Question 1: API Key${NC}"
    echo ""
    echo -e "  ${DIM}Have a key? Paste it below.${NC}"
    echo -e "  ${DIM}Need one? Press Enter — I'll help you get one (free, 60 seconds).${NC}"
    echo ""
    
    local api_key
    api_key=$(prompt "Paste API key (or Enter for guided signup)")
    
    # Auto-detect provider from key format
    local provider=""
    local openrouter_key=""
    local anthropic_key=""
    local default_model=""
    
    # Guided signup if empty
    if [ -z "$api_key" ]; then
        api_key=$(guided_api_signup)
    fi
    
    if [[ "$api_key" == sk-or-* ]]; then
        provider="openrouter"
        openrouter_key="$api_key"
        default_model="openrouter/moonshotai/kimi-k2.5"
        pass "OpenRouter key detected"
    elif [[ "$api_key" == sk-ant-* ]]; then
        provider="anthropic"
        anthropic_key="$api_key"
        default_model="anthropic/claude-sonnet-4-5"
        pass "Anthropic key detected"
    else
        # Assume OpenRouter for unknown formats
        provider="openrouter"
        openrouter_key="$api_key"
        default_model="openrouter/moonshotai/kimi-k2.5"
        if [ -n "$api_key" ]; then
            warn "Unknown key format — assuming OpenRouter"
        fi
    fi
    
    # ─── Question 2: Use Case (Multi-Select) ───
    echo ""
    echo -e "${BOLD}Question 2: What do you want to do?${NC}"
    echo -e "${DIM}(Select all that apply — e.g., \"1,3\" for content + coding)${NC}"
    echo ""
    echo "  1. 📱 Create content (social media, podcasts, video)"
    echo "  2. 📅 Organize my life (email, calendar, tasks)"
    echo "  3. 🛠️  Build apps (coding, GitHub, APIs)"
    echo "  4. 🤷 Not sure yet (general assistant)"
    echo ""
    
    local use_case_input
    use_case_input=$(prompt "Choose (e.g., 1 or 1,2,3)" "4")
    
    # Parse multi-select
    local has_content=false
    local has_workflow=false
    local has_builder=false
    
    [[ "$use_case_input" == *"1"* ]] && has_content=true
    [[ "$use_case_input" == *"2"* ]] && has_workflow=true
    [[ "$use_case_input" == *"3"* ]] && has_builder=true
    
    # ─── Smart Inference (priority: builder > workflow > content) ───
    local templates=""
    local bot_name=""
    local personality=""
    local spending_tier="balanced"
    
    # Collect templates
    $has_content && templates="content-creator"
    $has_workflow && templates="${templates:+$templates,}workflow-optimizer"
    $has_builder && templates="${templates:+$templates,}app-builder"
    
    # Determine personality (most complex wins)
    if $has_builder; then
        personality="direct"
        spending_tier="premium"
        bot_name="Jarvis"
        # Upgrade to Sonnet for coding
        if [ "$provider" = "openrouter" ]; then
            default_model="anthropic/claude-sonnet-4-5"
        fi
    elif $has_workflow; then
        personality="professional"
        bot_name="Friday"
    elif $has_content; then
        personality="casual"
        bot_name="Muse"
    else
        personality="casual"
        bot_name="Atlas"
    fi
    
    # Count selections for messaging
    local count=0
    $has_content && ((count++)) || true
    $has_workflow && ((count++)) || true
    $has_builder && ((count++)) || true
    
    if [ "$count" -gt 1 ]; then
        info "Multi-mode: ${templates} → ${personality}, ${spending_tier}"
        bot_name="Atlas"  # Generic name for multi-mode
    elif [ "$count" -eq 1 ]; then
        info "Selected: ${templates} → ${personality}, ${spending_tier}"
    else
        info "General Assistant mode"
        templates=""
    fi
    
    # ─── Question 3: Setup Type ───
    echo ""
    echo -e "${BOLD}Question 3: How will you run OpenClaw?${NC}"
    echo ""
    echo -e "  ${GREEN}1. 👤 New Mac User (Recommended)${NC}"
    echo "     → Create a separate user account on your Mac"
    echo "     → Best isolation without extra hardware"
    echo ""
    echo "  2. 💻 Your Mac User / VM"
    echo "     → Run under your current account (or in a VM)"
    echo "     → Simpler setup, less isolation"
    echo ""
    echo "  3. 🖥️  Dedicated Device"
    echo "     → A Mac just for OpenClaw (Mac Mini, always-on)"
    echo "     → Maximum isolation, relaxed permissions"
    echo ""
    
    local setup_choice
    setup_choice=$(prompt "Choose 1-3" "2")
    
    local setup_type="personal"
    local security_level="medium"
    
    case "$setup_choice" in
        1)
            setup_type="new-user"
            security_level="high"
            info "New Mac User → high security, workspace-only sandbox"
            ;;
        2)
            setup_type="current-user"
            security_level="medium"
            info "Your Mac User → standard security"
            ;;
        3)
            setup_type="dedicated"
            security_level="low"
            info "Dedicated Device → relaxed permissions, full access"
            ;;
    esac
    
    # ─── Optional: Customize name ───
    echo ""
    echo -e "${DIM}Your bot will be called \"${bot_name}\". Press Enter to keep, or type a new name.${NC}"
    local custom_name
    custom_name=$(prompt "Bot name" "$bot_name")
    bot_name="$custom_name"
    
    # Export for step 3
    export QUICKSTART_OPENROUTER_KEY="$openrouter_key"
    export QUICKSTART_ANTHROPIC_KEY="$anthropic_key"
    export QUICKSTART_DEFAULT_MODEL="$default_model"
    export QUICKSTART_BOT_NAME="$bot_name"
    export QUICKSTART_PERSONALITY="$personality"
    export QUICKSTART_TEMPLATES="$templates"  # Comma-separated
    export QUICKSTART_SPENDING_TIER="$spending_tier"
    export QUICKSTART_SETUP_TYPE="$setup_type"
    export QUICKSTART_SECURITY_LEVEL="$security_level"
}

# ═══════════════════════════════════════════════════════════════════
# Skill Packs (Optional Add-ons)
# ═══════════════════════════════════════════════════════════════════

offer_skill_packs() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  ${STEP} ${BOLD}Bonus: Skill Packs${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${DIM}Your bot works great now! These optional packs add superpowers.${NC}"
    echo ""
    
    if ! confirm "Browse skill packs?"; then
        info "Skipped. Add later with: openclaw skills add <name>"
        return 0
    fi
    
    echo ""
    echo -e "${BOLD}Available Skill Packs:${NC}"
    echo ""
    echo "  1. 🔬 ${BOLD}Quality Pack${NC} — Better debugging & code review"
    echo "     ${DIM}systematic-debugging, TDD, verification, code-review${NC}"
    echo ""
    echo "  2. 🔍 ${BOLD}Research Pack${NC} — Deep research capabilities"
    echo "     ${DIM}x-research (Twitter), summarize, web scraping${NC}"
    echo ""
    echo "  3. 🎨 ${BOLD}Media Pack${NC} — Image & audio creation"
    echo "     ${DIM}image generation, whisper transcription, TTS${NC}"
    echo ""
    echo "  4. 🏠 ${BOLD}Home Pack${NC} — Personal automation"
    echo "     ${DIM}weather, iMessage, WhatsApp${NC}"
    echo ""
    echo "  5. ⏭️  ${BOLD}Skip${NC} — I'm good for now"
    echo ""
    
    local packs_input
    packs_input=$(prompt "Add packs (e.g., 1,2 or Enter to skip)" "5")
    
    # Skip logic: 5 or empty means skip ALL
    if [[ "$packs_input" == "5" ]] || [[ -z "$packs_input" ]]; then
        info "No additional packs. Add later with: openclaw skills add"
        return 0
    fi
    
    local workspace_dir="$HOME/.openclaw/workspace"
    
    # Safety check: Ensure AGENTS.md exists
    if [ ! -f "$workspace_dir/AGENTS.md" ]; then
        warn "AGENTS.md not found, creating minimal file"
        echo "# Agent Instructions" > "$workspace_dir/AGENTS.md"
    fi
    
    # Quality Pack
    if [[ "$packs_input" == *"1"* ]]; then
        echo ""
        info "Installing Quality Pack..."
        
        # Check for duplicate
        if grep -q "QUALITY_PACK_INSTALLED" "$workspace_dir/AGENTS.md" 2>/dev/null; then
            warn "Quality Pack already installed, skipping"
        else
            cat >> "$workspace_dir/AGENTS.md" << 'QUALITYEOF'

<!-- QUALITY_PACK_INSTALLED -->
## Quality Methodology (from Quality Pack)

These are thinking frameworks, not commands. Apply them when working:

| Methodology | When to Apply |
|-------------|---------------|
| systematic-debugging | Before proposing fixes — diagnose root cause first |
| verification-before-completion | Before claiming done — run tests, show proof |
| test-driven-development | Before implementation — write tests first |
| complete-code-review | When reviewing code — multiple passes |
| receiving-feedback | When getting review — verify suggestions before applying |

*These skills are auto-loaded. Just follow the approach.*
QUALITYEOF
            pass "Quality Pack added"
        fi
    fi
    
    # Research Pack
    if [[ "$packs_input" == *"2"* ]]; then
        echo ""
        info "Installing Research Pack..."
        
        # Add tap first!
        brew tap steipete/tap 2>/dev/null || true
        
        # Install summarize with feedback
        if brew install steipete/tap/summarize 2>/dev/null; then
            pass "summarize installed"
        else
            command -v summarize >/dev/null && pass "summarize already installed" || warn "summarize install failed"
        fi
        
        # Check for duplicate
        if grep -q "RESEARCH_PACK_INSTALLED" "$workspace_dir/AGENTS.md" 2>/dev/null; then
            warn "Research Pack already in AGENTS.md, skipping"
        else
            cat >> "$workspace_dir/AGENTS.md" << 'RESEARCHEOF'

<!-- RESEARCH_PACK_INSTALLED -->
## Research Skills (from Research Pack)

| Skill | What It Does |
|-------|--------------|
| x-research-skill | Search X/Twitter for trends, takes, discourse |
| summarize | Summarize articles, YouTube videos, podcasts |
| web_fetch | Extract readable content from URLs (built-in) |

*For X research, just ask: "Research what people are saying about [topic] on X"*
RESEARCHEOF
            pass "Research Pack configured"
        fi
    fi
    
    # Media Pack
    if [[ "$packs_input" == *"3"* ]]; then
        echo ""
        info "Installing Media Pack..."
        
        # Install ffmpeg with feedback
        if brew install ffmpeg 2>/dev/null; then
            pass "ffmpeg installed"
        else
            command -v ffmpeg >/dev/null && pass "ffmpeg already installed" || warn "ffmpeg install failed"
        fi
        
        # Check for duplicate
        if grep -q "MEDIA_PACK_INSTALLED" "$workspace_dir/AGENTS.md" 2>/dev/null; then
            warn "Media Pack already in AGENTS.md, skipping"
        else
            cat >> "$workspace_dir/AGENTS.md" << 'MEDIAEOF'

<!-- MEDIA_PACK_INSTALLED -->
## Media Skills (from Media Pack)

| Skill | What It Does | Needs |
|-------|--------------|-------|
| image | Generate images | Your AI provider |
| tts | Text-to-speech | Built-in |
| video-frames | Extract frames from video | ffmpeg (installed) |
| openai-whisper-api | Transcribe audio | OPENAI_API_KEY |

*Try: "Generate an image of..." or "Transcribe this audio file"*
MEDIAEOF
            pass "Media Pack configured"
        fi
        echo -e "  ${DIM}Whisper transcription requires OPENAI_API_KEY in your environment.${NC}"
    fi
    
    # Home Pack
    if [[ "$packs_input" == *"4"* ]]; then
        echo ""
        info "Installing Home Pack..."
        
        # Add tap for home tools
        brew tap steipete/tap 2>/dev/null || true
        
        # Check for duplicate
        if grep -q "HOME_PACK_INSTALLED" "$workspace_dir/AGENTS.md" 2>/dev/null; then
            warn "Home Pack already in AGENTS.md, skipping"
        else
            cat >> "$workspace_dir/AGENTS.md" << 'HOMEEOF'

<!-- HOME_PACK_INSTALLED -->
## Home Automation Skills (from Home Pack)

| Skill | What It Does | Setup |
|-------|--------------|-------|
| weather | Weather lookups | None — just ask |
| imsg | iMessage automation | Needs permissions |
| wacli | WhatsApp messaging | Needs QR auth |

*Try: "What's the weather in NYC?" (works immediately)*

To enable iMessage: `brew install steipete/tap/imsg`
To enable WhatsApp: `brew install steipete/tap/wacli`
HOMEEOF
            pass "Home Pack configured"
        fi
        echo -e "  ${DIM}Weather works now. iMessage/WhatsApp need separate install.${NC}"
    fi
    
    echo ""
    pass "Skill packs configured!"
}

# ═══════════════════════════════════════════════════════════════════
# STEP 3: Start Bot
# ═══════════════════════════════════════════════════════════════════

step3_start() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  ${STEP} ${BOLD}Step 3: Launch${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    
    local config_file="$HOME/.openclaw/openclaw.json"
    local workspace_dir="$HOME/.openclaw/workspace"
    
    # Backup existing config
    if [ -f "$config_file" ]; then
        cp "$config_file" "${config_file}.backup-$(date +%Y%m%d-%H%M%S)"
        info "Backed up existing config"
    fi
    
    # Generate config via Python
    python3 - "$QUICKSTART_DEFAULT_MODEL" "$QUICKSTART_OPENROUTER_KEY" "$QUICKSTART_ANTHROPIC_KEY" "$config_file" "$QUICKSTART_BOT_NAME" "$QUICKSTART_SECURITY_LEVEL" << 'PYEOF'
import json, sys, os, secrets

model = sys.argv[1]
openrouter_key = sys.argv[2]
anthropic_key = sys.argv[3]
config_path = sys.argv[4]
bot_name = sys.argv[5] if len(sys.argv) > 5 else "Atlas"
security_level = sys.argv[6] if len(sys.argv) > 6 else "medium"

gateway_token = secrets.token_hex(32)

# Security settings based on setup type
tools_deny = ["browser"]
sandbox_mode = "off"

if security_level == "high":
    # New Mac User — most restrictive
    sandbox_mode = "workspace"
    tools_deny = ["browser"]
elif security_level == "low":
    # Dedicated device — relaxed
    sandbox_mode = "off"
    tools_deny = []

config = {
    "version": "2026.2.9",
    "model": model,
    "gateway": {
        "port": 18789,
        "auth": {"enabled": True, "token": gateway_token}
    },
    "auth": {},
    "workspace": {"path": os.path.expanduser("~/.openclaw/workspace")},
    "agents": {
        "defaults": {
            "sandbox": {"mode": sandbox_mode},
            "tools": {"deny": tools_deny} if tools_deny else {},
            "subagents": {"maxConcurrent": 8, "maxDepth": 1}
        }
    },
    "meta": {
        "security_level": security_level,
        "created_by": "clawstarter-v2"
    }
}

if openrouter_key:
    config["auth"]["openrouter"] = {"apiKey": openrouter_key}
if anthropic_key:
    config["auth"]["anthropic"] = {"apiKey": anthropic_key}

os.makedirs(os.path.dirname(config_path), exist_ok=True)
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print(f"\n  Gateway Token: {gateway_token}")
print("  Save this — you need it for the dashboard.\n")
PYEOF
    
    chmod 600 "$config_file"
    pass "Config created"
    
    # Create workspace + AGENTS.md
    mkdir -p "$workspace_dir/memory"
    
    cat > "$workspace_dir/AGENTS.md" << AGENTSEOF
# ${QUICKSTART_BOT_NAME}

You are ${QUICKSTART_BOT_NAME}, a helpful AI assistant.

## Personality
Style: ${QUICKSTART_PERSONALITY}

## Guidelines
- Be helpful, not performative
- Have opinions when asked
- Ask before taking external actions (emails, posts)
- If uncertain, ask

## First Run
Welcome! I'm ${QUICKSTART_BOT_NAME}. Try asking me:
- "What can you help me with?"
- "Tell me about yourself"
- "What skills do you have?"
AGENTSEOF
    pass "Workspace created"
    
    # Install templates if selected (supports multiple, comma-separated)
    if [ -n "$QUICKSTART_TEMPLATES" ]; then
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        
        # Split by comma and install each
        IFS=',' read -ra TEMPLATE_ARRAY <<< "$QUICKSTART_TEMPLATES"
        local first_template=true
        
        for template_name in "${TEMPLATE_ARRAY[@]}"; do
            local template_dir="${script_dir}/workflows/${template_name}"
            
            if [ -d "$template_dir" ]; then
                info "Installing ${template_name}..."
                
                # First template's AGENTS.md becomes primary
                if $first_template && [ -f "${template_dir}/AGENTS.md" ]; then
                    cp "${template_dir}/AGENTS.md" "$workspace_dir/"
                    first_template=false
                fi
                
                # Run skills installer for all templates
                if [ -f "${template_dir}/skills.sh" ]; then
                    bash "${template_dir}/skills.sh" 2>/dev/null || true
                fi
                
                pass "Installed: ${template_name}"
            fi
        done
        
        # If multiple templates, note that skills are combined
        if [ "${#TEMPLATE_ARRAY[@]}" -gt 1 ]; then
            info "All template skills installed. AGENTS.md uses ${TEMPLATE_ARRAY[0]} as base."
        fi
    fi
    
    # Create and load LaunchAgent
    local launch_agent="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
    mkdir -p "$HOME/Library/LaunchAgents"
    
    cat > "$launch_agent" << PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>ai.openclaw.gateway</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/.openclaw/bin/openclaw</string>
        <string>gateway</string>
        <string>start</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/tmp/openclaw/gateway.log</string>
    <key>WorkingDirectory</key>
    <string>$HOME/.openclaw</string>
</dict>
</plist>
PLISTEOF
    
    # Start gateway
    launchctl unload "$launch_agent" 2>/dev/null || true
    launchctl load "$launch_agent" || die "Failed to start gateway"
    sleep 2
    
    if pgrep -f "openclaw" &>/dev/null; then
        pass "Gateway running"
    else
        die "Gateway failed. Check: tail /tmp/openclaw/gateway.log"
    fi
    
    # ─── Skill Packs (Optional) ───
    offer_skill_packs
    
    # ─── Success! ───
    echo ""
    echo -e "${BOLD}${GREEN}🎉 Done! ${QUICKSTART_BOT_NAME} is alive.${NC}"
    echo ""
    echo -e "  Dashboard: ${CYAN}http://127.0.0.1:${DEFAULT_GATEWAY_PORT}/${NC}"
    echo ""
    echo -e "  Try: \"Hello ${QUICKSTART_BOT_NAME}! What can you help me with?\""
    echo ""
    
    if [ -n "$QUICKSTART_TEMPLATES" ]; then
        echo -e "  ${DIM}Templates installed: ${QUICKSTART_TEMPLATES}${NC}"
        IFS=',' read -ra TEMPLATE_ARRAY <<< "$QUICKSTART_TEMPLATES"
        for t in "${TEMPLATE_ARRAY[@]}"; do
            echo -e "  ${DIM}  → workflows/${t}/GETTING-STARTED.md${NC}"
        done
    fi
    echo ""
    
    # Open dashboard
    if confirm "Open dashboard now?"; then
        open "http://127.0.0.1:${DEFAULT_GATEWAY_PORT}/" 2>/dev/null || true
    fi
}

# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════

main() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  OpenClaw Quickstart v${SCRIPT_VERSION}${NC}"
    echo -e "${BOLD}  3 Questions → Running Bot${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  This takes ~5 minutes:"
    echo -e "  ${INFO} Install dependencies (Node.js, OpenClaw)"
    echo -e "  ${INFO} Ask 3 questions + optional skill packs"
    echo -e "  ${INFO} Start your bot"
    echo ""
    
    if ! confirm "Ready?"; then
        echo "  Run again when ready."
        exit 0
    fi
    
    step1_install
    step2_configure
    step3_start
}

main "$@"
