#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# OpenClaw Quickstart — 3 Easy Steps
#
# Zero to running bot in ~15 minutes.
# For beginners who just want it working.
#
# Usage:
#   bash openclaw-quickstart.sh
#
# What this does:
#   1. Installs Node.js + OpenClaw automatically
#   2. Asks 4-5 simple questions (no tech knowledge needed)
#   3. Starts your bot
#
# What it DOESN'T do (deferred to advanced setup):
#   - Create separate Mac user
#   - Configure Discord/Telegram
#   - Apply access profiles
#   - Migrate secrets to env vars
#
# See QUICKSTART.md for the 3-step guide.
# ═══════════════════════════════════════════════════════════════════
set -euo pipefail

# ─── Constants ───
readonly SCRIPT_VERSION="2.0.0"
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

# ═══════════════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════════════

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
# STEP 1: Auto-Install Dependencies
# ═══════════════════════════════════════════════════════════════════

step1_install_dependencies() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  ${STEP} ${BOLD}Step 1: Download & Install${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Check macOS
    if [ "$(uname -s)" != "Darwin" ]; then
        die "This script is for macOS only. Detected: $(uname -s)"
    fi
    pass "macOS detected"
    
    # Check/install Homebrew
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew (macOS package manager)..."
        echo ""
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || \
            die "Homebrew installation failed"
        
        # Add to PATH for Apple Silicon
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
        
        # Link if needed
        if ! command -v node &>/dev/null; then
            brew link --overwrite node@22 &>/dev/null || true
            local brew_prefix
            brew_prefix=$(brew --prefix)
            export PATH="${brew_prefix}/opt/node@22/bin:$PATH"
        fi
        
        if command -v node &>/dev/null; then
            pass "Node.js $(node --version) installed"
        else
            die "Node.js installed but not in PATH. Restart terminal and re-run."
        fi
    fi
    
    # Check/install OpenClaw
    if command -v openclaw &>/dev/null; then
        local oc_ver
        oc_ver=$(openclaw --version 2>&1 | head -1 | grep -oE '[0-9]{4}\.[0-9]+\.[0-9]+' || echo "unknown")
        pass "OpenClaw ${oc_ver} found"
        
        # Offer update
        if confirm "Update to latest version?"; then
            info "Updating OpenClaw..."
            openclaw update &>/dev/null &
            spinner $!
            wait
            pass "OpenClaw updated"
        fi
    else
        info "Installing OpenClaw..."
        curl -fsSL https://openclaw.ai/install.sh | bash || \
            die "OpenClaw installation failed"
        
        export PATH="$HOME/.openclaw/bin:$PATH"
        
        if command -v openclaw &>/dev/null; then
            pass "OpenClaw installed"
        else
            die "OpenClaw installed but not in PATH. Add to ~/.zprofile:\n  export PATH=\"\$HOME/.openclaw/bin:\$PATH\""
        fi
    fi
    
    # Quick sleep prevention (silently, no sudo prompt for this step)
    if [ "$(pmset -g 2>/dev/null | grep -E '^ sleep' | awk '{print $2}')" != "0" ]; then
        info "Sleep prevention is NOT configured (your bot may stop when Mac sleeps)"
        info "Fix this later: See 'Advanced Setup' in QUICKSTART.md"
    fi
}

# ═══════════════════════════════════════════════════════════════════
# STEP 2: Quick Configuration (4-5 Questions)
# ═══════════════════════════════════════════════════════════════════

step2_configure() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  ${STEP} ${BOLD}Step 2: Make Your Choices${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Question 1: AI Provider
    echo -e "${BOLD}Which AI provider do you want to use?${NC}"
    echo ""
    echo -e "  ${GREEN}1. OpenRouter ⭐ RECOMMENDED${NC}"
    echo "     → Best for beginners — one key, 100+ models, budget-friendly"
    echo "     → Sign up: https://openrouter.ai"
    echo ""
    echo "  2. Anthropic (premium quality)"
    echo "     → Claude models directly, slightly higher quality"
    echo "     → Sign up: https://console.anthropic.com"
    echo ""
    echo "  3. Both (advanced — use OpenRouter for most, Anthropic for complex tasks)"
    echo ""
    echo -e "${DIM}Not sure? Pick 1 — you can always change it later.${NC}"
    echo ""
    
    local provider_choice
    provider_choice=$(prompt "Type 1, 2, or 3 and press Enter" "1")
    
    local openrouter_key=""
    local anthropic_key=""
    local default_model=""
    
    case "$provider_choice" in
        1)
            info "OpenRouter selected"
            openrouter_key=$(prompt "Paste your OpenRouter API key (starts with sk-or-v1-)")
            default_model="openrouter/moonshotai/kimi-k2.5"
            ;;
        2)
            info "Anthropic selected"
            anthropic_key=$(prompt "Paste your Anthropic API key (starts with sk-ant-)")
            default_model="anthropic/claude-sonnet-4-5"
            ;;
        3)
            info "Both providers selected"
            openrouter_key=$(prompt "Paste your OpenRouter API key")
            anthropic_key=$(prompt "Paste your Anthropic API key")
            default_model="openrouter/moonshotai/kimi-k2.5"
            ;;
        *)
            warn "Invalid choice, defaulting to OpenRouter"
            openrouter_key=$(prompt "Paste your OpenRouter API key")
            default_model="openrouter/moonshotai/kimi-k2.5"
            ;;
    esac
    
    # Question 2: Spending Tier (sets model quality)
    echo ""
    echo -e "${BOLD}What's your monthly AI spending budget?${NC}"
    echo ""
    echo "  1. Budget (~\$5-15/mo)"
    echo "     → Good for simple tasks, summaries, quick lookups"
    echo "     → Models: Kimi K2.5, GPT-5 Nano"
    echo ""
    echo -e "  ${GREEN}2. Balanced (~\$15-50/mo) ⭐ RECOMMENDED${NC}"
    echo "     → Best value — handles most tasks well"
    echo "     → Models: Claude Sonnet, Kimi K2.5"
    echo ""
    echo "  3. Premium (~\$50+/mo)"
    echo "     → For complex research, coding, strategic work"
    echo "     → Models: Claude Opus, Claude Sonnet"
    echo ""
    echo -e "${DIM}Most people are happy with Balanced. You can upgrade anytime.${NC}"
    echo ""
    
    local spend_choice
    spend_choice=$(prompt "Type 1, 2, or 3 and press Enter" "2")
    
    case "$spend_choice" in
        1)
            info "Budget tier selected"
            if [ "$provider_choice" = "2" ]; then
                default_model="anthropic/claude-haiku-3-5"
            else
                default_model="openrouter/moonshotai/kimi-k2.5"
            fi
            ;;
        2)
            info "Balanced tier selected"
            # Keep the default from provider choice
            ;;
        3)
            info "Premium tier selected"
            if [ "$provider_choice" = "2" ]; then
                default_model="anthropic/claude-opus-4-6"
            else
                default_model="anthropic/claude-sonnet-4-5"
            fi
            ;;
    esac
    
    # Question 3: Personality
    echo ""
    echo -e "${BOLD}What personality style do you prefer?${NC}"
    echo ""
    echo "  1. Professional — Formal, structured responses"
    echo -e "  ${GREEN}2. Casual ⭐ RECOMMENDED${NC} — Friendly, conversational"
    echo "  3. Direct — Concise, no fluff"
    echo "  4. Custom — Configure later in SOUL.md"
    echo ""
    echo -e "${DIM}You can change this anytime by editing SOUL.md in your workspace.${NC}"
    echo ""
    
    local personality_choice
    personality_choice=$(prompt "Type 1, 2, 3, or 4 and press Enter" "2")
    
    local bot_personality
    case "$personality_choice" in
        1) bot_personality="professional" ;;
        2) bot_personality="casual" ;;
        3) bot_personality="direct" ;;
        *) bot_personality="custom" ;;
    esac
    
    # Question 4: Bot Name
    echo ""
    local bot_name
    bot_name=$(prompt "What should I call your bot?" "Atlas")
    
    # Question 5: Channel (simplified — just dashboard for now)
    echo ""
    echo -e "${BOLD}How do you want to chat with your bot?${NC}"
    echo ""
    echo "  1. Dashboard only (web browser, simplest setup)"
    echo "  2. I'll configure Discord/Telegram later"
    echo ""
    
    local channel_choice
    channel_choice=$(prompt "Choose [1/2]" "1")
    
    if [ "$channel_choice" = "2" ]; then
        info "You can add channels later using the full setup guide"
    fi
    
    # Question 6: Use Case (NEW - Decision Matrix)
    echo ""
    echo -e "${BOLD}What do you want to use OpenClaw for?${NC}"
    echo -e "${DIM}(Select all that apply — type numbers separated by commas)${NC}"
    echo ""
    echo "  1. 📱 Content Creator"
    echo "     → Social media, podcasts, video workflows, automated posting"
    echo ""
    echo "  2. 📅 Workflow Optimizer"
    echo "     → Personal assistant, email, calendar, notes, reminders"
    echo ""
    echo "  3. 🛠️ App Builder"
    echo "     → Coding, APIs, GitHub automation, development workflows"
    echo ""
    echo -e "${DIM}Example: 1,2 for Content Creator + Workflow Optimizer${NC}"
    echo ""
    
    local use_case_input
    use_case_input=$(prompt "Type 1, 2, 3, or combination (e.g., 1,2)" "2")
    
    # Parse use cases into flags
    local is_content_creator=false
    local is_workflow_optimizer=false
    local is_app_builder=false
    
    if [[ "$use_case_input" == *"1"* ]]; then is_content_creator=true; fi
    if [[ "$use_case_input" == *"2"* ]]; then is_workflow_optimizer=true; fi
    if [[ "$use_case_input" == *"3"* ]]; then is_app_builder=true; fi
    
    # Default to workflow optimizer if nothing selected
    if ! $is_content_creator && ! $is_workflow_optimizer && ! $is_app_builder; then
        is_workflow_optimizer=true
    fi
    
    info "Selected: ${is_content_creator:+Content Creator }${is_workflow_optimizer:+Workflow Optimizer }${is_app_builder:+App Builder}"
    
    # Question 7: Setup Type (Security Level)
    echo ""
    echo -e "${BOLD}What's your setup situation?${NC}"
    echo ""
    echo -e "  ${GREEN}1. Personal Mac ⭐ RECOMMENDED${NC}"
    echo "     → Your own machine, you're the only user"
    echo ""
    echo "  2. Shared Mac"
    echo "     → Multiple users on this computer"
    echo ""
    echo "  3. Dedicated Device"
    echo "     → A Mac specifically for OpenClaw (e.g., Mac Mini server)"
    echo ""
    
    local setup_type_choice
    setup_type_choice=$(prompt "Type 1, 2, or 3 and press Enter" "1")
    
    local setup_type="personal"
    local security_level="medium"
    case "$setup_type_choice" in
        1) setup_type="personal"; security_level="medium" ;;
        2) setup_type="shared"; security_level="high" ;;
        3) setup_type="dedicated"; security_level="low" ;;
    esac
    
    info "Setup: $setup_type (security level: $security_level)"
    
    # Build skills recommendation based on use cases
    local recommended_skills=""
    
    # Always include these safe beginner skills
    recommended_skills="weather, summarize"
    
    if $is_content_creator; then
        recommended_skills="$recommended_skills, openai-image-gen, tts, video-frames, x-fetch"
    fi
    
    if $is_workflow_optimizer; then
        recommended_skills="$recommended_skills, apple-notes, apple-reminders, gog, himalaya"
    fi
    
    if $is_app_builder; then
        recommended_skills="$recommended_skills, github, coding-agent, generate-jsdoc"
    fi
    
    echo ""
    echo -e "${BOLD}📦 Recommended skills for you:${NC}"
    echo -e "  ${CYAN}$recommended_skills${NC}"
    echo ""
    echo -e "${DIM}You can install these after setup with: openclaw skills add <name>${NC}"
    echo ""
    
    # Save config variables for step 3
    export QUICKSTART_OPENROUTER_KEY="$openrouter_key"
    export QUICKSTART_ANTHROPIC_KEY="$anthropic_key"
    export QUICKSTART_DEFAULT_MODEL="$default_model"
    export QUICKSTART_BOT_NAME="$bot_name"
    export QUICKSTART_PERSONALITY="$bot_personality"
    export QUICKSTART_USE_CASES="$use_case_input"
    export QUICKSTART_SETUP_TYPE="$setup_type"
    export QUICKSTART_SECURITY_LEVEL="$security_level"
    export QUICKSTART_RECOMMENDED_SKILLS="$recommended_skills"
}

# ═══════════════════════════════════════════════════════════════════
# STEP 3: Start Bot
# ═══════════════════════════════════════════════════════════════════

step3_start_bot() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  ${STEP} ${BOLD}Step 3: Start Chatting${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Run onboarding wizard with automatic answers
    local config_file="$HOME/.openclaw/openclaw.json"
    
    if [ -f "$config_file" ]; then
        warn "Config already exists at $config_file"
        if ! confirm "Overwrite with new configuration?"; then
            info "Keeping existing config. Skipping to gateway start."
            step3_start_gateway
            return 0
        fi
        cp "$config_file" "${config_file}.backup-$(date +%Y%m%d-%H%M%S)"
        info "Backed up existing config"
    fi
    
    info "Running onboarding wizard (auto-answering based on your choices)..."
    echo ""
    
    # Build minimal config via Python
    python3 - "$QUICKSTART_DEFAULT_MODEL" "$QUICKSTART_OPENROUTER_KEY" "$QUICKSTART_ANTHROPIC_KEY" "$config_file" "$QUICKSTART_SECURITY_LEVEL" "$QUICKSTART_USE_CASES" << 'PYEOF'
import json, sys, os, secrets

model = sys.argv[1]
openrouter_key = sys.argv[2]
anthropic_key = sys.argv[3]
config_path = sys.argv[4]
security_level = sys.argv[5] if len(sys.argv) > 5 else "medium"
use_cases = sys.argv[6] if len(sys.argv) > 6 else "2"

# Generate gateway token
gateway_token = secrets.token_hex(32)

# Security settings based on setup type
tools_deny = ["browser"]  # Always deny browser
sandbox_mode = "off"

if security_level == "high":
    # Shared Mac - more restrictive
    sandbox_mode = "workspace"  # Restrict to workspace only
    tools_deny.extend(["exec"])  # Consider restricting exec
    
# Build minimal config
config = {
    "version": "2026.2.9",
    "model": model,
    "models": {
        "fallback": "anthropic/claude-sonnet-4-5" if anthropic_key else model
    },
    "auth": {},
    "gateway": {
        "port": 18789,
        "auth": {
            "enabled": True,
            "token": gateway_token
        }
    },
    "channels": {
        "discord": {"enabled": False},
        "telegram": {"enabled": False}
    },
    "workspace": {
        "path": os.path.expanduser("~/.openclaw/workspace")
    },
    "agents": {
        "defaults": {
            "sandbox": {"mode": sandbox_mode, "workspaceAccess": "rw"},
            "tools": {"deny": tools_deny},
            "subagents": {
                "maxConcurrent": 8,
                "maxDepth": 1  # Prevent recursive agent spawning
            }
        }
    },
    "meta": {
        "use_cases": use_cases,
        "security_level": security_level,
        "created_by": "clawstarter-quickstart"
    }
}

# Add API keys
if openrouter_key:
    config["auth"]["openrouter"] = {"apiKey": openrouter_key}
if anthropic_key:
    config["auth"]["anthropic"] = {"apiKey": anthropic_key}

# Create config directory
os.makedirs(os.path.dirname(config_path), exist_ok=True)

# Write config
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

# Print gateway token for user
print(f"\nGateway Token: {gateway_token}")
print("Save this token — you'll need it to access the dashboard.\n")
PYEOF
    
    if [ ! -f "$config_file" ]; then
        die "Config creation failed"
    fi
    
    pass "Configuration created"
    
    # Set permissions
    chmod 600 "$config_file"
    chmod 700 "$HOME/.openclaw"
    pass "Permissions secured"
    
    # Create workspace
    local workspace_dir="$HOME/.openclaw/workspace"
    mkdir -p "$workspace_dir"
    mkdir -p "$workspace_dir/memory"
    
    # Create minimal AGENTS.md
    cat > "$workspace_dir/AGENTS.md" << AGENTSEOF
# Agent Operating Instructions

You are ${QUICKSTART_BOT_NAME}, a helpful AI assistant.

**Personality:** ${QUICKSTART_PERSONALITY}

**Your purpose:** Help your human with daily tasks, answer questions, and learn from interactions.

**Safety rules:**
- Never run destructive commands without asking first
- Confirm before sending emails or messages
- If you're uncertain, ask

**Communication style:**
$(case "$QUICKSTART_PERSONALITY" in
    professional) echo "- Be formal and structured\n- Use complete sentences\n- Provide thorough explanations" ;;
    casual) echo "- Be friendly and conversational\n- Use contractions and informal language\n- Keep responses light and approachable" ;;
    direct) echo "- Be concise and to-the-point\n- No fluff or unnecessary elaboration\n- Get straight to answers" ;;
    custom) echo "- Adapt to your human's preferences over time\n- Ask questions to understand their style" ;;
esac)

See the OpenClaw Foundation Playbook for advanced configuration.
AGENTSEOF
    
    pass "Workspace created"
    
    # Create LaunchAgent
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
    <key>StandardOutPath</key>
    <string>/tmp/openclaw/gateway-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/openclaw/gateway-stderr.log</string>
    <key>WorkingDirectory</key>
    <string>$HOME/.openclaw</string>
</dict>
</plist>
PLISTEOF
    
    pass "LaunchAgent created"
    
    # Start gateway
    step3_start_gateway
}

step3_start_gateway() {
    info "Starting gateway..."
    
    # Unload if already loaded
    launchctl unload "$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist" 2>/dev/null || true
    
    # Load
    launchctl load "$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist" || \
        die "Failed to load LaunchAgent"
    
    sleep 3
    
    # Verify
    if pgrep -f "openclaw" &>/dev/null; then
        pass "Gateway is running!"
    else
        die "Gateway failed to start. Check logs:\n  tail /tmp/openclaw/gateway-stderr.log"
    fi
    
    # Show success
    echo ""
    echo -e "${BOLD}${GREEN}🎉 SUCCESS! Your bot is alive.${NC}"
    echo ""
    echo -e "  ${INFO} Dashboard: ${CYAN}http://127.0.0.1:${DEFAULT_GATEWAY_PORT}/${NC}"
    echo -e "  ${INFO} Status: ${CYAN}openclaw gateway status${NC}"
    echo -e "  ${INFO} Restart: ${CYAN}openclaw gateway restart${NC}"
    echo ""
    echo -e "${BOLD}Try your first message:${NC}"
    echo -e "  Open the dashboard and type: ${CYAN}\"Hello! What can you help me with?\"${NC}"
    echo ""
    echo -e "${BOLD}What's next:${NC}"
    echo -e "  ${INFO} Your bot is running 24/7 (auto-restarts on reboot)"
    echo -e "  ${INFO} Add Discord/Telegram: See full setup guide"
    echo -e "  ${INFO} Advanced security: See Foundation Playbook Phase 1"
    echo -e "  ${INFO} Sleep prevention: Run ${CYAN}sudo pmset -a sleep 0${NC}"
    echo ""
    
    # Show recommended skills based on use case
    if [ -n "$QUICKSTART_RECOMMENDED_SKILLS" ]; then
        echo -e "${BOLD}📦 Recommended skills to install:${NC}"
        echo -e "  ${CYAN}$QUICKSTART_RECOMMENDED_SKILLS${NC}"
        echo ""
        echo -e "  Install with: ${CYAN}openclaw skills add <skill-name>${NC}"
        echo ""
    fi
    
    echo -e "${BOLD}💡 Model tips:${NC}"
    echo -e "  ${INFO} For complex tasks: Use Claude Sonnet or Opus"
    echo -e "  ${INFO} For simple lookups: GPT-5 Nano is fast and cheap"
    echo -e "  ${INFO} Change models anytime: ${CYAN}/model sonnet${NC} in chat"
    echo ""
    
    # Security reminder based on setup type
    if [ "$QUICKSTART_SECURITY_LEVEL" = "high" ]; then
        echo -e "${BOLD}🔐 Security note (shared Mac):${NC}"
        echo -e "  ${INFO} Your bot is in restricted mode for safety"
        echo -e "  ${INFO} Review security settings before adding channels"
        echo ""
    fi
    
    # Offer workflow template installation
    echo ""
    echo -e "${BOLD}📦 Install Workflow Template?${NC}"
    echo -e "${DIM}Templates include pre-configured skills, agent instructions, and automations.${NC}"
    echo ""
    
    local install_template=false
    if confirm "Install a workflow template for your use case?"; then
        install_template=true
    fi
    
    if $install_template; then
        install_workflow_template
    fi
    
    # Offer to open dashboard
    echo ""
    if confirm "Open dashboard now?"; then
        if command -v open &>/dev/null; then
            open "http://127.0.0.1:${DEFAULT_GATEWAY_PORT}/"
        else
            info "Open this URL in your browser: http://127.0.0.1:${DEFAULT_GATEWAY_PORT}/"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════
# Workflow Template Installation
# ═══════════════════════════════════════════════════════════════════

install_workflow_template() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local workflows_dir="${script_dir}/workflows"
    
    if [ ! -d "$workflows_dir" ]; then
        warn "Workflows directory not found at: $workflows_dir"
        info "Download templates from: https://github.com/openclaw/clawstarter"
        return 1
    fi
    
    echo ""
    echo -e "${BOLD}Select a workflow template:${NC}"
    echo ""
    echo "  1. 📱 Content Creator"
    echo "     → Social media, podcasts, video workflows"
    echo ""
    echo "  2. 📅 Workflow Optimizer"
    echo "     → Email, calendar, tasks, daily routines"
    echo ""
    echo "  3. 🛠️  App Builder"
    echo "     → Coding, GitHub, APIs, development"
    echo ""
    echo "  4. Skip template installation"
    echo ""
    
    local template_choice
    template_choice=$(prompt "Choose a template [1-4]" "4")
    
    local template_name=""
    case "$template_choice" in
        1) template_name="content-creator" ;;
        2) template_name="workflow-optimizer" ;;
        3) template_name="app-builder" ;;
        4|*) 
            info "Skipping template installation"
            return 0
            ;;
    esac
    
    local template_dir="${workflows_dir}/${template_name}"
    local workspace_dir="$HOME/.openclaw/workspace"
    
    if [ ! -d "$template_dir" ]; then
        warn "Template not found: $template_name"
        return 1
    fi
    
    info "Installing ${template_name} template..."
    echo ""
    
    # Copy AGENTS.md
    if [ -f "${template_dir}/AGENTS.md" ]; then
        if [ -f "${workspace_dir}/AGENTS.md" ]; then
            cp "${workspace_dir}/AGENTS.md" "${workspace_dir}/AGENTS.md.backup"
            info "Backed up existing AGENTS.md"
        fi
        cp "${template_dir}/AGENTS.md" "${workspace_dir}/"
        pass "Installed agent instructions"
    fi
    
    # Run skills installer
    if [ -f "${template_dir}/skills.sh" ]; then
        echo ""
        if confirm "Install recommended skills for ${template_name}?"; then
            echo ""
            bash "${template_dir}/skills.sh"
        else
            info "Skipped skill installation"
            info "You can install later: bash ${template_dir}/skills.sh"
        fi
    fi
    
    # Offer cron job installation
    if [ -d "${template_dir}/crons" ]; then
        echo ""
        echo -e "${DIM}This template includes automation jobs (crons).${NC}"
        if confirm "View available automations?"; then
            echo ""
            for cron_file in "${template_dir}/crons"/*.json; do
                if [ -f "$cron_file" ]; then
                    local cron_name
                    cron_name=$(basename "$cron_file" .json)
                    local enabled
                    enabled=$(python3 -c "import json; print(json.load(open('$cron_file')).get('enabled', False))")
                    local status="disabled"
                    [ "$enabled" = "True" ] && status="enabled"
                    echo -e "  • ${cron_name} (${status})"
                fi
            done
            echo ""
            info "Enable crons in the OpenClaw dashboard or via CLI"
        fi
    fi
    
    # Show getting started
    if [ -f "${template_dir}/GETTING-STARTED.md" ]; then
        echo ""
        pass "Template installed!"
        echo ""
        echo -e "${BOLD}📚 Next steps:${NC}"
        echo -e "  Read the getting started guide:"
        echo -e "  ${CYAN}${template_dir}/GETTING-STARTED.md${NC}"
    fi
}

# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════

main() {
    # Banner
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  OpenClaw Quickstart v${SCRIPT_VERSION}${NC}"
    echo -e "${BOLD}  Zero to Running Bot in 3 Easy Steps${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  This script will:"
    echo -e "  ${INFO} Install Node.js + OpenClaw automatically"
    echo -e "  ${INFO} Ask you 7 simple questions"
    echo -e "  ${INFO} Recommend skills based on your use case"
    echo -e "  ${INFO} Start your bot (dashboard-only for now)"
    echo ""
    echo -e "  ${YELLOW}Time: ~15 minutes${NC}"
    echo ""
    
    if ! confirm "Ready to begin?"; then
        info "Exiting. Re-run when ready: bash openclaw-quickstart.sh"
        exit 0
    fi
    
    # Run the 3 steps
    step1_install_dependencies
    step2_configure
    step3_start_bot
}

main "$@"
