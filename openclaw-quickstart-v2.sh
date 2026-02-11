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
readonly SCRIPT_VERSION="2.1.0"
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
# STEP 2: Two Questions Only
# ═══════════════════════════════════════════════════════════════════

step2_configure() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  ${STEP} ${BOLD}Step 2: Configure (2 questions)${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    
    # ─── Question 1: API Key ───
    echo ""
    echo -e "${BOLD}Question 1: Paste your API key${NC}"
    echo ""
    echo -e "  ${DIM}Get one from:${NC}"
    echo -e "  • OpenRouter (recommended): ${CYAN}https://openrouter.ai/keys${NC}"
    echo -e "  • Anthropic: ${CYAN}https://console.anthropic.com${NC}"
    echo ""
    
    local api_key
    api_key=$(prompt "Paste API key")
    
    # Auto-detect provider from key format
    local provider=""
    local openrouter_key=""
    local anthropic_key=""
    local default_model=""
    
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
        warn "Unknown key format — assuming OpenRouter"
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
    python3 - "$QUICKSTART_DEFAULT_MODEL" "$QUICKSTART_OPENROUTER_KEY" "$QUICKSTART_ANTHROPIC_KEY" "$config_file" "$QUICKSTART_BOT_NAME" << 'PYEOF'
import json, sys, os, secrets

model = sys.argv[1]
openrouter_key = sys.argv[2]
anthropic_key = sys.argv[3]
config_path = sys.argv[4]
bot_name = sys.argv[5] if len(sys.argv) > 5 else "Atlas"

gateway_token = secrets.token_hex(32)

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
            "tools": {"deny": ["browser"]},
            "subagents": {"maxConcurrent": 8, "maxDepth": 1}
        }
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
    echo -e "${BOLD}  2 Questions → Running Bot${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  This takes ~5 minutes:"
    echo -e "  ${INFO} Install dependencies (Node.js, OpenClaw)"
    echo -e "  ${INFO} Ask 2 questions"
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
