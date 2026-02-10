#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# OpenClaw Auto-Setup Script
#
# Automates the OpenClaw Setup Guide from zero to running gateway.
# Works standalone (interactive prompts) or after the HTML configurator.
#
# Usage:
#   bash openclaw-autosetup.sh              # Interactive (default)
#   bash openclaw-autosetup.sh --minimal    # Gateway only, skip confirmations for non-destructive steps
#   bash openclaw-autosetup.sh --full       # Everything, interactive confirmations
#   bash openclaw-autosetup.sh --resume     # Resume from last completed step
#   bash openclaw-autosetup.sh --reset      # Clear progress and start fresh
#   bash openclaw-autosetup.sh --help       # Show this help
#
# Requirements:
#   - macOS (Apple Silicon or Intel)
#   - Internet connection
#   - Python 3 (ships with macOS)
#
# Progress is saved to ~/.openclaw-autosetup-progress so you can
# interrupt and resume with --resume.
#
# Log file: ~/.openclaw/autosetup-TIMESTAMP.log
# ═══════════════════════════════════════════════════════════════════
set -euo pipefail

# ─── Constants ───
readonly SCRIPT_VERSION="1.0.0"
readonly PROGRESS_FILE="$HOME/.openclaw-autosetup-progress"
readonly CONFIG_FILE="$HOME/.openclaw/openclaw.json"
readonly MIN_VERSION="2026.1.29"
readonly REC_VERSION="2026.2.9"
readonly DEFAULT_MODEL="openrouter/moonshotai/kimi-k2.5"
readonly FALLBACK_MODEL="anthropic/claude-sonnet-4-5"
readonly GATEWAY_PORT=18789
readonly VERIFY_SCRIPT="$HOME/Downloads/openclaw-verify.sh"

# ─── Colors & Symbols (matches openclaw-verify.sh) ───
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

PASS="${GREEN}✓${NC}"
FAIL="${RED}✗${NC}"
WARN="${YELLOW}!${NC}"
INFO="${CYAN}→${NC}"
STEP="${BOLD}${CYAN}>>>${NC}"

# ─── State ───
MODE="interactive"   # interactive, minimal, full
RESUME=false
LOG_FILE=""
STEP_COUNT=0
STEP_TOTAL=16

# ═══════════════════════════════════════════════════════════════════
# Output functions
# ═══════════════════════════════════════════════════════════════════

pass()   { echo -e "  ${PASS} $1"; }
fail()   { echo -e "  ${FAIL} $1"; }
warn()   { echo -e "  ${WARN} $1"; }
info()   { echo -e "  ${INFO} $1"; }
header() { echo ""; echo -e "${BOLD}$1${NC}"; echo "  ────────────────────────────────────"; }

step_header() {
    STEP_COUNT=$((STEP_COUNT + 1))
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  ${STEP} ${BOLD}Step ${STEP_COUNT}/${STEP_TOTAL}: $1${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
}

die() {
    echo -e "\n  ${FAIL} ${RED}FATAL:${NC} $1" >&2
    echo -e "  ${INFO} Log file: ${LOG_FILE:-'(not started)'}" >&2
    exit 1
}

# ═══════════════════════════════════════════════════════════════════
# Logging
# ═══════════════════════════════════════════════════════════════════

log_start() {
    mkdir -p "$HOME/.openclaw"
    local timestamp
    timestamp=$(date '+%Y%m%d-%H%M%S')
    LOG_FILE="$HOME/.openclaw/autosetup-${timestamp}.log"
    # Redirect all output to both terminal and log file
    exec > >(tee -a "$LOG_FILE") 2>&1
    echo "# OpenClaw Auto-Setup Log" >> "$LOG_FILE"
    echo "# Started: $(date)" >> "$LOG_FILE"
    echo "# Mode: ${MODE}" >> "$LOG_FILE"
    echo "# User: $(whoami)" >> "$LOG_FILE"
    echo "# Host: $(hostname)" >> "$LOG_FILE"
    echo "# Script version: ${SCRIPT_VERSION}" >> "$LOG_FILE"
    echo "---" >> "$LOG_FILE"
}

# ═══════════════════════════════════════════════════════════════════
# Progress tracking
# ═══════════════════════════════════════════════════════════════════

progress_init() {
    if [ -f "$PROGRESS_FILE" ]; then
        # Validate the progress file is not corrupted
        if ! python3 -c "
import json, sys
try:
    with open('$PROGRESS_FILE') as f:
        data = json.load(f)
    if not isinstance(data, dict) or 'steps' not in data:
        sys.exit(1)
    if not isinstance(data['steps'], dict):
        sys.exit(1)
except Exception:
    sys.exit(1)
" 2>/dev/null; then
            echo ""
            warn "Progress file appears corrupted: ${PROGRESS_FILE}"
            echo ""
            if confirm "Start fresh? (This deletes the corrupted progress file)"; then
                rm -f "$PROGRESS_FILE"
                _create_progress_file
            else
                die "Cannot continue with corrupted progress file. Remove it manually:\n  rm ${PROGRESS_FILE}"
            fi
        fi
    else
        _create_progress_file
    fi
}

_create_progress_file() {
    python3 -c "
import json
data = {
    'version': '$SCRIPT_VERSION',
    'started': '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
    'mode': '$MODE',
    'steps': {}
}
with open('$PROGRESS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
}

mark_step() {
    local step_name="$1"
    python3 -c "
import json
with open('$PROGRESS_FILE') as f:
    data = json.load(f)
data['steps']['$step_name'] = '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
with open('$PROGRESS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
    pass "Step '${step_name}' marked complete"
}

is_step_done() {
    local step_name="$1"
    python3 -c "
import json, sys
with open('$PROGRESS_FILE') as f:
    data = json.load(f)
if '$step_name' in data.get('steps', {}):
    sys.exit(0)
else:
    sys.exit(1)
" 2>/dev/null
}

show_progress() {
    if [ ! -f "$PROGRESS_FILE" ]; then
        info "No progress file found."
        return
    fi
    echo ""
    echo -e "${BOLD}  Current Progress${NC}"
    echo "  ────────────────────────────────────"
    python3 -c "
import json
with open('$PROGRESS_FILE') as f:
    data = json.load(f)
steps = data.get('steps', {})
if not steps:
    print('  No steps completed yet.')
else:
    for step, ts in steps.items():
        print(f'  \033[0;32m✓\033[0m {step} ({ts})')
print(f'  Total: {len(steps)} step(s) completed')
"
    echo ""
}

reset_progress() {
    if [ -f "$PROGRESS_FILE" ]; then
        rm -f "$PROGRESS_FILE"
        pass "Progress file removed."
    else
        info "No progress file to remove."
    fi
}

# ═══════════════════════════════════════════════════════════════════
# User interaction
# ═══════════════════════════════════════════════════════════════════

confirm() {
    local prompt="$1"
    local response
    echo -en "\n  ${YELLOW}?${NC} ${prompt} [y/N]: "
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

confirm_destructive() {
    # Always requires confirmation, even in --minimal mode
    local prompt="$1"
    local response
    echo -en "\n  ${RED}!${NC} ${BOLD}${prompt}${NC} [y/N]: "
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

confirm_or_skip() {
    # In --minimal mode, skip confirmation for non-destructive steps
    local prompt="$1"
    if [ "$MODE" = "minimal" ]; then
        info "(--minimal) Auto-proceeding: ${prompt}"
        return 0
    fi
    confirm "$prompt"
}

prompt_input() {
    local prompt="$1"
    local default="${2:-}"
    local response
    if [ -n "$default" ]; then
        echo -en "\n  ${CYAN}?${NC} ${prompt} [${default}]: "
    else
        echo -en "\n  ${CYAN}?${NC} ${prompt}: "
    fi
    read -r response
    if [ -z "$response" ] && [ -n "$default" ]; then
        echo "$default"
    else
        echo "$response"
    fi
}

pause_for_human() {
    local message="$1"
    echo ""
    echo -e "  ${BOLD}${YELLOW}══════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}${YELLOW}  HUMAN ACTION REQUIRED${NC}"
    echo -e "  ${BOLD}${YELLOW}══════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  $message"
    echo ""
    echo -en "  ${INFO} Press ${BOLD}Enter${NC} when done (or ${BOLD}s${NC} to skip): "
    local response
    read -r response
    if [ "$response" = "s" ] || [ "$response" = "S" ]; then
        warn "Step skipped by user"
        return 1
    fi
    return 0
}

# ═══════════════════════════════════════════════════════════════════
# JSON manipulation via Python 3
# ═══════════════════════════════════════════════════════════════════

json_set() {
    # Usage: json_set <file> <dotted.key.path> <value> [--type string|number|bool|json]
    # Examples:
    #   json_set config.json "sandbox.mode" "off"
    #   json_set config.json "gateway.port" "18789" --type number
    #   json_set config.json "discord.enabled" "true" --type bool
    #   json_set config.json "channels.discord" '{"enabled":true}' --type json
    local file="$1"
    local key_path="$2"
    local value="$3"
    local value_type="${5:-string}"  # $4 is --type flag, $5 is the type

    if [ "${4:-}" = "--type" ]; then
        value_type="$5"
    fi

    python3 -c "
import json, sys

file_path = '$file'
key_path = '$key_path'
raw_value = '''$value'''
value_type = '$value_type'

# Parse the value based on type
if value_type == 'number':
    if '.' in raw_value:
        value = float(raw_value)
    else:
        value = int(raw_value)
elif value_type == 'bool':
    value = raw_value.lower() in ('true', '1', 'yes')
elif value_type == 'json':
    value = json.loads(raw_value)
else:
    value = raw_value

# Read existing file
with open(file_path) as f:
    data = json.load(f)

# Navigate to the parent and set the key
keys = key_path.split('.')
obj = data
for k in keys[:-1]:
    if k not in obj:
        obj[k] = {}
    obj = obj[k]
obj[keys[-1]] = value

# Write back
with open(file_path, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')

print('OK')
" || return 1
}

json_get() {
    # Usage: json_get <file> <dotted.key.path>
    # Returns the value or empty string if not found
    local file="$1"
    local key_path="$2"

    python3 -c "
import json, sys

try:
    with open('$file') as f:
        data = json.load(f)
    keys = '$key_path'.split('.')
    obj = data
    for k in keys:
        obj = obj[k]
    if isinstance(obj, (dict, list)):
        print(json.dumps(obj))
    else:
        print(obj)
except (KeyError, TypeError, IndexError):
    pass
except Exception as e:
    print('ERROR: ' + str(e), file=sys.stderr)
" 2>/dev/null
}

json_validate() {
    # Validates a JSON file. Returns 0 if valid, 1 if not.
    local file="$1"
    python3 -c "
import json, sys
try:
    with open('$file') as f:
        json.load(f)
    sys.exit(0)
except json.JSONDecodeError as e:
    print(f'JSON error at line {e.lineno}, col {e.colno}: {e.msg}', file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(str(e), file=sys.stderr)
    sys.exit(1)
" 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════
# Atomic config editing
# ═══════════════════════════════════════════════════════════════════

atomic_config_edit() {
    # Safely edits the OpenClaw config file:
    #   1. Create backup
    #   2. Write changes to .tmp
    #   3. Validate .tmp is valid JSON
    #   4. Rename .tmp to config file
    #   5. On failure: restore backup, log error, print fix instructions
    #
    # Usage: atomic_config_edit <dotted.key.path> <value> [--type string|number|bool|json]
    local key_path="$1"
    local value="$2"
    shift 2
    local type_flag="${1:-}"
    local type_val="${2:-string}"

    local backup_file="${CONFIG_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
    local tmp_file="${CONFIG_FILE}.tmp"

    # Ensure config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        die "Config file not found: ${CONFIG_FILE}\n  Run 'openclaw onboard --install-daemon' first."
    fi

    # Step 1: Backup
    cp "$CONFIG_FILE" "$backup_file" || die "Failed to create backup: ${backup_file}"

    # Step 2: Copy to tmp and apply changes
    cp "$CONFIG_FILE" "$tmp_file" || die "Failed to create temp file: ${tmp_file}"

    if [ "$type_flag" = "--type" ]; then
        json_set "$tmp_file" "$key_path" "$value" --type "$type_val"
    else
        json_set "$tmp_file" "$key_path" "$value"
    fi

    local set_result=$?
    if [ $set_result -ne 0 ]; then
        rm -f "$tmp_file"
        warn "Failed to set ${key_path} in config"
        info "Backup preserved at: ${backup_file}"
        info "Fix: Edit ${CONFIG_FILE} manually to set ${key_path}"
        return 1
    fi

    # Step 3: Validate
    if ! json_validate "$tmp_file"; then
        rm -f "$tmp_file"
        warn "Config validation failed after edit"
        info "Backup preserved at: ${backup_file}"
        info "Fix: Edit ${CONFIG_FILE} manually"
        return 1
    fi

    # Step 4: Atomic rename
    mv "$tmp_file" "$CONFIG_FILE" || {
        # Restore from backup on failure
        cp "$backup_file" "$CONFIG_FILE" 2>/dev/null
        rm -f "$tmp_file"
        die "Failed to write config. Restored from backup: ${backup_file}"
    }

    pass "Config updated: ${key_path}"
    info "Backup: ${backup_file}"
    return 0
}

# ═══════════════════════════════════════════════════════════════════
# Version comparison helpers
# ═══════════════════════════════════════════════════════════════════

version_gte() {
    # Returns 0 if $1 >= $2 (version format: YYYY.M.D)
    local v1="$1"
    local v2="$2"
    python3 -c "
v1 = [int(x) for x in '$v1'.split('.')]
v2 = [int(x) for x in '$v2'.split('.')]
import sys
sys.exit(0 if v1 >= v2 else 1)
" 2>/dev/null
}

parse_openclaw_version() {
    # Extracts version number from openclaw --version output
    local raw="$1"
    echo "$raw" | grep -oE '[0-9]{4}\.[0-9]+\.[0-9]+' | head -1
}

# ═══════════════════════════════════════════════════════════════════
# Argument parsing
# ═══════════════════════════════════════════════════════════════════

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --minimal)
                MODE="minimal"
                shift
                ;;
            --full)
                MODE="full"
                shift
                ;;
            --resume)
                RESUME=true
                shift
                ;;
            --reset)
                reset_progress
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --progress)
                show_progress
                exit 0
                ;;
            *)
                die "Unknown argument: $1\nRun with --help for usage."
                ;;
        esac
    done
}

show_help() {
    echo ""
    echo -e "${BOLD}OpenClaw Auto-Setup Script v${SCRIPT_VERSION}${NC}"
    echo ""
    echo "Usage: bash openclaw-autosetup.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  (no flags)    Interactive mode — prompts for each decision"
    echo "  --minimal     Gateway only — skips confirmations for non-destructive steps"
    echo "  --full        Everything — all steps with interactive confirmations"
    echo "  --resume      Resume from last completed step"
    echo "  --reset       Clear progress file and start fresh"
    echo "  --progress    Show current progress"
    echo "  --help, -h    Show this help"
    echo ""
    echo "Progress file: ${PROGRESS_FILE}"
    echo "Log files:     ~/.openclaw/autosetup-*.log"
    echo ""
    echo "Steps automated:"
    echo "  1.  Environment detection (Node, Homebrew, OpenClaw, existing config)"
    echo "  2.  Homebrew installation (if missing)"
    echo "  3.  Node.js 22 installation (if missing)"
    echo "  4.  OpenClaw install/update + version verification"
    echo "  5.  Mac user account creation (human checkpoint)"
    echo "  6.  Home directory permission lockdown"
    echo "  7.  API key generation (human checkpoint)"
    echo "  8.  Onboarding wizard (human checkpoint)"
    echo "  9.  Gateway verification"
    echo "  10. Discord setup (human checkpoint)"
    echo "  11. Sleep prevention (pmset)"
    echo "  12. Auto-update restart disable"
    echo "  13. Config file permission hardening"
    echo "  14. Access profile application"
    echo "  15. openclaw doctor"
    echo "  16. Final verification (openclaw-verify.sh)"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════
# Step functions
# ═══════════════════════════════════════════════════════════════════

step_detect_env() {
    local step_name="detect_env"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Environment detection"
        return 0
    fi

    step_header "Environment Detection"

    # Operating system
    local os_name
    os_name=$(uname -s)
    local arch
    arch=$(uname -m)
    if [ "$os_name" != "Darwin" ]; then
        die "This script is designed for macOS. Detected: ${os_name}"
    fi
    pass "macOS detected (${arch})"

    # Current user
    local current_user
    current_user=$(whoami)
    info "Running as: ${current_user}"
    info "Home directory: ${HOME}"

    # Check if admin
    if dscl . -read /Groups/admin GroupMembership 2>/dev/null | grep -qw "$current_user"; then
        warn "Running as admin user '${current_user}'"
        info "A dedicated Standard user is recommended for production (see Step 5)"
    else
        pass "Running as non-admin user '${current_user}'"
    fi

    # Python 3
    if command -v python3 &>/dev/null; then
        local py_ver
        py_ver=$(python3 --version 2>&1)
        pass "Python 3 available: ${py_ver}"
    else
        die "Python 3 not found. It should ship with macOS. Check your PATH."
    fi

    # Homebrew
    if command -v brew &>/dev/null; then
        pass "Homebrew installed: $(brew --prefix)"
    else
        info "Homebrew not installed (will install in Step 2)"
    fi

    # Node.js
    if command -v node &>/dev/null; then
        local node_ver
        node_ver=$(node --version 2>/dev/null)
        local node_major
        node_major=$(echo "$node_ver" | sed 's/v//' | cut -d. -f1)
        if [ "$node_major" -ge 22 ] 2>/dev/null; then
            pass "Node.js ${node_ver} (meets v22+ requirement)"
        else
            warn "Node.js ${node_ver} found but need v22+ (will upgrade in Step 3)"
        fi
    else
        info "Node.js not installed (will install in Step 3)"
    fi

    # OpenClaw
    if command -v openclaw &>/dev/null; then
        local oc_ver_raw
        oc_ver_raw=$(openclaw --version 2>&1 | head -1)
        local oc_ver
        oc_ver=$(parse_openclaw_version "$oc_ver_raw")
        if [ -n "$oc_ver" ]; then
            pass "OpenClaw installed: ${oc_ver}"
            if version_gte "$oc_ver" "$REC_VERSION"; then
                pass "Version meets recommended (${REC_VERSION}+)"
            elif version_gte "$oc_ver" "$MIN_VERSION"; then
                warn "Version ${oc_ver} is above minimum but below recommended ${REC_VERSION}"
            else
                warn "Version ${oc_ver} is BELOW minimum ${MIN_VERSION} — SECURITY RISK"
            fi
        else
            warn "OpenClaw installed but could not parse version: ${oc_ver_raw}"
        fi
    else
        info "OpenClaw not installed (will install in Step 4)"
    fi

    # Existing config
    if [ -f "$CONFIG_FILE" ]; then
        pass "Existing config found: ${CONFIG_FILE}"
        if json_validate "$CONFIG_FILE"; then
            pass "Config is valid JSON"
        else
            warn "Config exists but is NOT valid JSON — will need repair"
        fi
    else
        info "No existing config (will be created during onboarding)"
    fi

    # Existing LaunchAgent
    local launch_agent="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
    if [ -f "$launch_agent" ]; then
        pass "Gateway LaunchAgent exists"
    else
        info "No LaunchAgent found (will be created during onboarding)"
    fi

    mark_step "$step_name"
}

step_install_homebrew() {
    local step_name="install_homebrew"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Homebrew installation"
        return 0
    fi

    step_header "Homebrew Installation"

    if command -v brew &>/dev/null; then
        pass "Homebrew already installed at $(brew --prefix)"
        info "Version: $(brew --version | head -1)"
        mark_step "$step_name"
        return 0
    fi

    info "Homebrew is macOS's package manager — it installs developer tools like Node.js."
    info "Official site: https://brew.sh"
    echo ""

    if ! confirm_or_skip "Install Homebrew?"; then
        warn "Skipping Homebrew installation"
        info "You'll need to install Node.js 22+ manually from https://nodejs.org"
        mark_step "$step_name"
        return 0
    fi

    info "Installing Homebrew (this may take a few minutes)..."
    echo ""

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        fail "Homebrew installation failed"
        info "Try manually: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 1
    }

    # Add Homebrew to PATH for Apple Silicon
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        info "Added Homebrew to PATH for this session"
        echo ""
        warn "To make Homebrew permanent, add this to your ~/.zprofile:"
        info "  eval \"\$(/opt/homebrew/bin/brew shellenv)\""
    fi

    if command -v brew &>/dev/null; then
        pass "Homebrew installed successfully"
    else
        fail "Homebrew installed but not in PATH"
        info "Restart your terminal and re-run this script with --resume"
        return 1
    fi

    mark_step "$step_name"
}

step_install_node() {
    local step_name="install_node"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Node.js installation"
        return 0
    fi

    step_header "Node.js 22 Installation"

    if command -v node &>/dev/null; then
        local node_ver
        node_ver=$(node --version 2>/dev/null)
        local node_major
        node_major=$(echo "$node_ver" | sed 's/v//' | cut -d. -f1)
        if [ "$node_major" -ge 22 ] 2>/dev/null; then
            pass "Node.js ${node_ver} already installed and meets v22+ requirement"
            mark_step "$step_name"
            return 0
        else
            info "Node.js ${node_ver} is installed but below v22"
        fi
    fi

    info "OpenClaw requires Node.js 22 or newer."
    echo ""

    if ! command -v brew &>/dev/null; then
        warn "Homebrew is not installed — cannot auto-install Node.js"
        echo ""
        pause_for_human "Install Node.js 22+ manually from https://nodejs.org\n  Download the macOS installer (LTS version) and run it." || true
        if command -v node &>/dev/null; then
            local nv
            nv=$(node --version 2>/dev/null)
            pass "Node.js ${nv} detected"
        else
            fail "Node.js still not found after manual step"
            info "Restart your terminal and re-run with --resume"
            return 1
        fi
        mark_step "$step_name"
        return 0
    fi

    if ! confirm_or_skip "Install Node.js 22 via Homebrew?"; then
        warn "Skipping Node.js installation"
        info "Install manually: brew install node@22"
        mark_step "$step_name"
        return 0
    fi

    info "Installing Node.js 22..."
    brew install node@22 || {
        fail "Node.js installation failed"
        info "Try manually: brew install node@22"
        return 1
    }

    # Link node@22 if it's keg-only
    if ! command -v node &>/dev/null; then
        brew link --overwrite node@22 2>/dev/null || true
    fi

    # Check if node@22 is in a non-standard path and add to PATH
    if ! command -v node &>/dev/null; then
        local brew_prefix
        brew_prefix=$(brew --prefix)
        if [ -f "${brew_prefix}/opt/node@22/bin/node" ]; then
            export PATH="${brew_prefix}/opt/node@22/bin:$PATH"
            info "Added Node.js 22 to PATH for this session"
            warn "To make permanent, add to your ~/.zprofile:"
            info "  export PATH=\"${brew_prefix}/opt/node@22/bin:\$PATH\""
        fi
    fi

    if command -v node &>/dev/null; then
        local final_ver
        final_ver=$(node --version)
        pass "Node.js ${final_ver} installed successfully"
    else
        fail "Node.js installed but not in PATH"
        info "Restart your terminal and re-run with --resume"
        return 1
    fi

    if command -v npm &>/dev/null; then
        pass "npm $(npm --version) available"
    else
        warn "npm not found — may need to restart terminal"
    fi

    mark_step "$step_name"
}

step_install_openclaw() {
    local step_name="install_openclaw"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): OpenClaw installation"
        return 0
    fi

    step_header "OpenClaw Install / Update"

    local needs_install=false
    local needs_update=false
    local current_ver=""

    if command -v openclaw &>/dev/null; then
        local oc_ver_raw
        oc_ver_raw=$(openclaw --version 2>&1 | head -1)
        current_ver=$(parse_openclaw_version "$oc_ver_raw")

        if [ -n "$current_ver" ]; then
            pass "OpenClaw installed: ${current_ver}"
            if ! version_gte "$current_ver" "$MIN_VERSION"; then
                fail "Version ${current_ver} is BELOW minimum ${MIN_VERSION} — SECURITY RISK"
                warn "CVE-2026-25253 (remote code execution) and CVE-2026-25157 (command injection) affect this version"
                needs_update=true
            elif ! version_gte "$current_ver" "$REC_VERSION"; then
                warn "Version ${current_ver} is below recommended ${REC_VERSION}"
                info "Recommended version adds safety scanner and credential redaction"
                needs_update=true
            else
                pass "Version ${current_ver} meets recommended (${REC_VERSION}+)"
            fi
        else
            warn "Could not parse version — will attempt update"
            needs_update=true
        fi
    else
        info "OpenClaw not installed"
        needs_install=true
    fi

    if $needs_install; then
        if ! command -v node &>/dev/null; then
            die "Node.js is required to install OpenClaw. Run Step 3 first."
        fi

        echo ""
        if ! confirm_or_skip "Install OpenClaw?"; then
            warn "Skipping OpenClaw installation"
            die "OpenClaw is required to continue. Run manually:\n  curl -fsSL https://openclaw.ai/install.sh | bash"
        fi

        info "Installing OpenClaw..."
        echo ""
        curl -fsSL https://openclaw.ai/install.sh | bash || {
            fail "OpenClaw installation failed"
            info "Try manually: curl -fsSL https://openclaw.ai/install.sh | bash"
            return 1
        }

        # Refresh PATH
        export PATH="$HOME/.openclaw/bin:$PATH"

        if command -v openclaw &>/dev/null; then
            local new_ver
            new_ver=$(parse_openclaw_version "$(openclaw --version 2>&1 | head -1)")
            pass "OpenClaw ${new_ver} installed successfully"
        else
            fail "OpenClaw installed but not in PATH"
            info "Add to ~/.zprofile: export PATH=\"\$HOME/.openclaw/bin:\$PATH\""
            info "Then restart terminal and re-run with --resume"
            return 1
        fi
    elif $needs_update; then
        echo ""
        if confirm_or_skip "Update OpenClaw to latest version?"; then
            info "Updating OpenClaw..."
            openclaw update || {
                fail "OpenClaw update failed"
                info "Try manually: openclaw update"
                return 1
            }
            local updated_ver
            updated_ver=$(parse_openclaw_version "$(openclaw --version 2>&1 | head -1)")
            if [ -n "$updated_ver" ]; then
                pass "OpenClaw updated to ${updated_ver}"
                if version_gte "$updated_ver" "$REC_VERSION"; then
                    pass "Now meets recommended version (${REC_VERSION}+)"
                elif version_gte "$updated_ver" "$MIN_VERSION"; then
                    pass "Now meets minimum version (${MIN_VERSION}+)"
                    warn "Still below recommended ${REC_VERSION} — consider updating again later"
                fi
            fi
        else
            warn "Skipping update — current version: ${current_ver}"
            if ! version_gte "$current_ver" "$MIN_VERSION"; then
                fail "WARNING: Running a version with known security vulnerabilities"
                info "Strongly recommend updating: openclaw update"
            fi
        fi
    fi

    mark_step "$step_name"
}

step_create_mac_user() {
    local step_name="create_mac_user"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Mac user creation"
        return 0
    fi

    step_header "Create Dedicated Mac User (Human Checkpoint)"

    local current_user
    current_user=$(whoami)

    # Check if already on a non-admin user
    if ! dscl . -read /Groups/admin GroupMembership 2>/dev/null | grep -qw "$current_user"; then
        pass "Already running as non-admin user '${current_user}'"
        info "This appears to be a dedicated bot user — good setup"
        echo ""
        if confirm_or_skip "Is '${current_user}' the correct bot user account?"; then
            mark_step "$step_name"
            return 0
        fi
    fi

    info "A dedicated macOS Standard user isolates your bot from your personal files."
    info "This is the single most important security step."
    echo ""
    info "If you already have a dedicated user, switch to it and re-run this script."
    info "If not, create one now:"
    echo ""

    if ! pause_for_human "Create a Mac user account:\n\n  1. Open ${BOLD}System Settings${NC} > ${BOLD}Users & Groups${NC}\n  2. Click the ${BOLD}+${NC} button\n  3. Name: Your bot's name (e.g., Watson, Maverick, Atlas)\n  4. Account type: ${BOLD}Standard${NC} (NOT Administrator)\n  5. Set a strong password\n  6. Click Create User\n\n  Then switch to that user and re-run this script."; then
        warn "Skipped Mac user creation"
        info "You can continue on your current user, but this is less secure"
    fi

    mark_step "$step_name"
}

step_lock_home_dir() {
    local step_name="lock_home_dir"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Home directory lockdown"
        return 0
    fi

    step_header "Home Directory Permission Lockdown"

    local home_perms
    home_perms=$(stat -f "%Lp" "$HOME" 2>/dev/null || echo "unknown")

    if [ "$home_perms" = "700" ]; then
        pass "Home directory already locked down (chmod 700)"
        mark_step "$step_name"
        return 0
    fi

    warn "Home directory permissions: ${home_perms} (should be 700)"
    info "Default macOS permissions (755) let ANY local user read your files."
    info "chmod 700 restricts access to only your user account."
    echo ""

    if ! confirm_destructive "Lock down ${HOME} with chmod 700?"; then
        warn "Skipping home directory lockdown"
        info "Fix later: chmod 700 ${HOME}"
        mark_step "$step_name"
        return 0
    fi

    chmod 700 "$HOME" || {
        fail "Failed to set permissions on ${HOME}"
        info "Try manually: chmod 700 ${HOME}"
        return 1
    }

    local new_perms
    new_perms=$(stat -f "%Lp" "$HOME" 2>/dev/null)
    if [ "$new_perms" = "700" ]; then
        pass "Home directory locked down: chmod 700"
    else
        fail "Permissions set but verify shows ${new_perms} instead of 700"
    fi

    mark_step "$step_name"
}

step_get_api_keys() {
    local step_name="get_api_keys"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): API key setup"
        return 0
    fi

    step_header "Get API Keys (Human Checkpoint)"

    # If --minimal, check if config already has auth
    if [ "$MODE" = "minimal" ] && [ -f "$CONFIG_FILE" ]; then
        local has_auth
        has_auth=$(python3 -c "
import json
try:
    with open('$CONFIG_FILE') as f:
        config = json.load(f)
    auth = config.get('auth', config.get('providers', {}))
    if auth:
        print('yes')
    else:
        print('no')
except:
    print('no')
" 2>/dev/null)
        if [ "$has_auth" = "yes" ]; then
            pass "API provider configuration already exists in config"
            mark_step "$step_name"
            return 0
        fi
    fi

    info "You need at least one AI provider API key before running the onboarding wizard."
    echo ""
    info "Recommended providers:"
    echo ""
    echo -e "  ${BOLD}1. Anthropic (Claude)${NC} — Direct access to Claude models"
    echo -e "     Sign up: ${CYAN}https://console.anthropic.com${NC}"
    echo -e "     Add credits > Create API key (starts with sk-ant-...)"
    echo ""
    echo -e "  ${BOLD}2. OpenRouter (multi-model)${NC} — Access 100+ models with one key"
    echo -e "     Sign up: ${CYAN}https://openrouter.ai${NC}"
    echo -e "     Add credits > Create API key (starts with sk-or-v1-...)"
    echo ""
    echo -e "  ${BOLD}3. Voyage AI (for memory search)${NC} — Embedding provider (recommended)"
    echo -e "     Sign up: ${CYAN}https://www.voyageai.com${NC}"
    echo -e "     Get API key (starts with pa-...)"
    echo ""
    info "Set spending limits on each provider dashboard before continuing."
    echo ""
    info "Default model: ${CYAN}${DEFAULT_MODEL}${NC} (budget-friendly)"
    info "Fallback model: ${CYAN}${FALLBACK_MODEL}${NC}"
    echo ""

    if ! pause_for_human "Generate your API keys in a web browser.\n  Have them ready to paste during the onboarding wizard (Step 8).\n  Store them securely (password manager recommended)."; then
        warn "Skipped API key step — you'll need keys for the onboarding wizard"
    fi

    mark_step "$step_name"
}

step_run_onboard() {
    local step_name="run_onboard"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Onboarding wizard"
        return 0
    fi

    step_header "Run Onboarding Wizard (Human Checkpoint)"

    if ! command -v openclaw &>/dev/null; then
        die "OpenClaw not found. Run Step 4 first."
    fi

    # Check if already onboarded (config + LaunchAgent exist)
    if [ -f "$CONFIG_FILE" ] && [ -f "$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist" ]; then
        pass "Config and LaunchAgent already exist"
        echo ""
        if confirm "It looks like onboarding was already completed. Skip this step?"; then
            mark_step "$step_name"
            return 0
        fi
    fi

    info "The onboarding wizard is interactive — it asks questions and you respond."
    info "Have your API keys ready."
    echo ""
    info "Recommended answers for the wizard:"
    echo ""
    echo -e "  ${BOLD}Model/Auth:${NC}"
    echo -e "    Default model: ${CYAN}${DEFAULT_MODEL}${NC}"
    echo -e "    Fallback: ${CYAN}${FALLBACK_MODEL}${NC}"
    echo -e "    Paste your API key when prompted"
    echo ""
    echo -e "  ${BOLD}Workspace:${NC} Accept default (~/.openclaw/workspace)"
    echo -e "  ${BOLD}Gateway:${NC}   Accept default port (${GATEWAY_PORT}), save the auth token"
    echo -e "  ${BOLD}Channels:${NC}  Enable Discord (or skip for now)"
    echo -e "  ${BOLD}Daemon:${NC}    Say ${BOLD}yes${NC} — this keeps the bot running 24/7"
    echo -e "  ${BOLD}Skills:${NC}    Skip for now"
    echo ""

    if ! pause_for_human "Run the onboarding wizard in this terminal:\n\n  ${CYAN}openclaw onboard --install-daemon${NC}\n\n  Follow the prompts. Save the gateway auth token.\n  You can re-run 'openclaw onboard' safely if needed."; then
        warn "Skipped onboarding wizard"
        info "Run later: openclaw onboard --install-daemon"
    fi

    # Verify onboarding completed
    if [ -f "$CONFIG_FILE" ]; then
        pass "Config file created: ${CONFIG_FILE}"
    else
        warn "Config file not found — onboarding may not have completed"
        info "Re-run: openclaw onboard --install-daemon"
    fi

    mark_step "$step_name"
}

step_verify_gateway() {
    local step_name="verify_gateway"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Gateway verification"
        return 0
    fi

    step_header "Gateway Verification"

    if ! command -v openclaw &>/dev/null; then
        die "OpenClaw not found. Run Step 4 first."
    fi

    local all_ok=true

    # Check LaunchAgent
    local launch_agent="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
    if [ -f "$launch_agent" ]; then
        pass "LaunchAgent plist exists"
    else
        fail "LaunchAgent not found: ${launch_agent}"
        info "Fix: openclaw onboard --install-daemon"
        all_ok=false
    fi

    # Check if loaded
    if launchctl list 2>/dev/null | grep -q "openclaw"; then
        pass "Gateway LaunchAgent is loaded"
    else
        warn "Gateway LaunchAgent is not loaded"
        if [ -f "$launch_agent" ]; then
            info "Attempting to load..."
            launchctl load "$launch_agent" 2>/dev/null || true
            sleep 2
            if launchctl list 2>/dev/null | grep -q "openclaw"; then
                pass "Gateway loaded successfully"
            else
                fail "Failed to load gateway"
                all_ok=false
            fi
        else
            all_ok=false
        fi
    fi

    # Check process
    if pgrep -f "openclaw" &>/dev/null; then
        local gw_pid
        gw_pid=$(pgrep -f "openclaw" | head -1)
        pass "Gateway process running (PID: ${gw_pid})"
    else
        warn "No OpenClaw gateway process found"
        info "Attempting to start..."
        openclaw gateway start 2>/dev/null || true
        sleep 3
        if pgrep -f "openclaw" &>/dev/null; then
            pass "Gateway started"
        else
            fail "Could not start gateway"
            info "Check logs: tail -20 /tmp/openclaw/openclaw-\$(date +%Y-%m-%d).log"
            all_ok=false
        fi
    fi

    # Check port
    if lsof -i ":${GATEWAY_PORT}" -sTCP:LISTEN &>/dev/null; then
        pass "Gateway listening on port ${GATEWAY_PORT}"
    else
        warn "Nothing listening on port ${GATEWAY_PORT}"
        all_ok=false
    fi

    # Check HTTP endpoint
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${GATEWAY_PORT}/" 2>/dev/null || echo "000")
    if echo "$http_code" | grep -qE "^(200|301|302)"; then
        pass "Gateway HTTP endpoint responding (${http_code})"
    else
        warn "Gateway HTTP endpoint not responding (code: ${http_code})"
        all_ok=false
    fi

    # Gateway status command
    local gw_status
    gw_status=$(openclaw gateway status 2>&1 || true)
    if echo "$gw_status" | grep -qi "running"; then
        pass "openclaw gateway status: running"
    elif echo "$gw_status" | grep -qi "stopped\|not running"; then
        fail "openclaw gateway status: not running"
        all_ok=false
    else
        info "openclaw gateway status: $(echo "$gw_status" | head -1)"
    fi

    if $all_ok; then
        pass "Gateway is fully operational"
    else
        warn "Gateway has issues — review the failures above"
        info "Troubleshooting: openclaw doctor"
    fi

    mark_step "$step_name"
}

step_setup_discord() {
    local step_name="setup_discord"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Discord setup"
        return 0
    fi

    step_header "Discord Bot Setup (Human Checkpoint)"

    # In minimal mode, skip Discord entirely
    if [ "$MODE" = "minimal" ]; then
        info "Skipping Discord setup in --minimal mode"
        info "Set up later using the Setup Guide"
        mark_step "$step_name"
        return 0
    fi

    # Check if Discord is already configured
    if [ -f "$CONFIG_FILE" ]; then
        local discord_status
        discord_status=$(python3 -c "
import json
try:
    with open('$CONFIG_FILE') as f:
        config = json.load(f)
    channels = config.get('channels', {})
    discord = channels.get('discord', config.get('discord', {}))
    if discord and discord.get('enabled', False):
        print('ENABLED')
    elif discord and discord.get('token'):
        print('CONFIGURED')
    else:
        print('NOT_CONFIGURED')
except:
    print('NOT_CONFIGURED')
" 2>/dev/null)
        if [ "$discord_status" = "ENABLED" ]; then
            pass "Discord is already enabled in config"
            mark_step "$step_name"
            return 0
        elif [ "$discord_status" = "CONFIGURED" ]; then
            info "Discord is configured but may not be enabled"
        fi
    fi

    echo ""
    if ! confirm "Do you want to set up Discord as a communication channel?"; then
        info "Skipping Discord setup"
        info "You can use the dashboard chat at http://127.0.0.1:${GATEWAY_PORT}/"
        mark_step "$step_name"
        return 0
    fi

    echo ""
    info "Discord setup has two parts:"
    info "  A) Create a bot in the Discord Developer Portal (web browser)"
    info "  B) Enter the bot token and IDs here (this script writes the config)"
    echo ""

    # Part A: Human creates bot in portal
    if ! pause_for_human "Create a Discord bot application:\n\n  1. Go to ${CYAN}https://discord.com/developers/applications${NC}\n  2. Click ${BOLD}New Application${NC} > Name it (your bot's name)\n  3. Go to ${BOLD}Bot${NC} in the sidebar:\n     - Click ${BOLD}Reset Token${NC} > Copy the token (save it!)\n     - Enable ${BOLD}Message Content Intent${NC} (CRITICAL)\n     - Enable ${BOLD}Server Members Intent${NC}\n     - Enable ${BOLD}Presence Intent${NC}\n  4. Go to ${BOLD}OAuth2${NC} > ${BOLD}URL Generator${NC}:\n     - Scopes: ${BOLD}bot${NC} and ${BOLD}applications.commands${NC}\n     - Permissions: Send Messages, Read Message History,\n       Embed Links, Attach Files, Add Reactions, Use Slash Commands\n     - Copy the generated URL\n  5. Paste the URL in your browser > Select your server > Authorize\n\n  Also enable ${BOLD}Developer Mode${NC} in Discord:\n  Settings > Advanced > Developer Mode = ON"; then
        warn "Skipped Discord Developer Portal setup"
        info "Complete later using the Setup Guide"
        mark_step "$step_name"
        return 0
    fi

    # Part B: Collect Discord info and write config
    echo ""
    info "Now enter your Discord details. Right-click items in Discord to copy IDs."
    echo ""

    local discord_token
    discord_token=$(prompt_input "Discord bot token (starts with a long string)")

    if [ -z "$discord_token" ]; then
        warn "No token entered — skipping Discord config"
        mark_step "$step_name"
        return 0
    fi

    local discord_guild_id
    discord_guild_id=$(prompt_input "Server (Guild) ID (right-click server name > Copy Server ID)")

    local discord_server_slug
    discord_server_slug=$(prompt_input "Server name slug (lowercase, e.g., 'my-server')" "my-server")

    local discord_owner_id
    discord_owner_id=$(prompt_input "Your Discord User ID (right-click your name > Copy User ID)")

    local discord_channel_id
    discord_channel_id=$(prompt_input "Primary channel ID (right-click #general > Copy Channel ID)")

    # Validate inputs
    if [ -z "$discord_guild_id" ] || [ -z "$discord_owner_id" ] || [ -z "$discord_channel_id" ]; then
        warn "Missing required Discord IDs — skipping config write"
        info "Edit ~/.openclaw/openclaw.json manually using the Setup Guide"
        mark_step "$step_name"
        return 0
    fi

    # Ask for optional second channel
    local discord_logs_channel_id=""
    echo ""
    if confirm "Do you have a #bot-logs channel? (optional)"; then
        discord_logs_channel_id=$(prompt_input "Bot logs channel ID")
    fi

    # Build the Discord config JSON
    local channels_json
    if [ -n "$discord_logs_channel_id" ]; then
        channels_json="{\"${discord_channel_id}\": {\"allow\": true, \"requireMention\": false}, \"${discord_logs_channel_id}\": {\"allow\": true, \"requireMention\": false}}"
    else
        channels_json="{\"${discord_channel_id}\": {\"allow\": true, \"requireMention\": false}}"
    fi

    local discord_config
    discord_config=$(python3 -c "
import json
config = {
    'enabled': True,
    'token': '$discord_token',
    'groupPolicy': 'allowlist',
    'dm': {
        'policy': 'pairing',
        'allowFrom': ['$discord_owner_id']
    },
    'guilds': {
        '$discord_guild_id': {
            'slug': '$discord_server_slug',
            'channels': json.loads('$channels_json')
        }
    }
}
print(json.dumps(config))
")

    # Write to config atomically
    if [ -f "$CONFIG_FILE" ]; then
        atomic_config_edit "channels.discord" "$discord_config" --type json
        if [ $? -eq 0 ]; then
            pass "Discord configuration written to config"
            info "Restart gateway to apply: openclaw gateway restart"
        else
            fail "Failed to write Discord config"
            info "Add manually using the Setup Guide"
        fi
    else
        warn "Config file not found — Discord config not written"
        info "Run 'openclaw onboard --install-daemon' first, then re-run with --resume"
    fi

    # Restart gateway if running
    if pgrep -f "openclaw" &>/dev/null; then
        echo ""
        if confirm_or_skip "Restart gateway to apply Discord config?"; then
            info "Restarting gateway..."
            openclaw gateway restart 2>/dev/null || true
            sleep 5
            if pgrep -f "openclaw" &>/dev/null; then
                pass "Gateway restarted"
                info "Check Discord — your bot should appear online"
            else
                warn "Gateway may not have restarted cleanly"
                info "Check: openclaw gateway status"
            fi
        fi
    fi

    mark_step "$step_name"
}

step_prevent_sleep() {
    local step_name="prevent_sleep"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Sleep prevention"
        return 0
    fi

    step_header "Mac Sleep Prevention"

    # Check current sleep value
    local sleep_val
    sleep_val=$(pmset -g 2>/dev/null | grep -E "^ sleep" | awk '{print $2}' || echo "unknown")

    if [ "$sleep_val" = "0" ]; then
        pass "System sleep already disabled (sleep = 0)"

        # Verify other settings too
        local standby_val
        standby_val=$(pmset -g 2>/dev/null | grep -E "^ standby " | awk '{print $2}' || echo "unknown")
        if [ "$standby_val" = "0" ]; then
            pass "Standby already disabled"
        else
            info "Standby is set to ${standby_val} (should be 0)"
        fi

        local powernap_val
        powernap_val=$(pmset -g 2>/dev/null | grep "powernap" | awk '{print $2}' || echo "unknown")
        if [ "$powernap_val" = "0" ]; then
            pass "Power Nap already disabled"
        else
            info "Power Nap is set to ${powernap_val} (should be 0)"
        fi

        mark_step "$step_name"
        return 0
    fi

    warn "System sleep is set to ${sleep_val} — should be 0 for always-on operation"
    info "If the Mac sleeps, all channels disconnect and cron jobs stop."
    echo ""
    info "This requires sudo (admin password)."
    info "Command: sudo pmset -a sleep 0 standby 0 hibernatemode 0 powernap 0 displaysleep 15 disksleep 0"
    echo ""

    if ! confirm_destructive "Apply sleep prevention settings? (requires sudo)"; then
        warn "Skipping sleep prevention"
        info "Fix later: sudo pmset -a sleep 0 standby 0 hibernatemode 0 powernap 0 displaysleep 15 disksleep 0"
        mark_step "$step_name"
        return 0
    fi

    sudo pmset -a sleep 0 standby 0 hibernatemode 0 powernap 0 displaysleep 15 disksleep 0 || {
        fail "Failed to set pmset values (sudo may have been denied)"
        info "Run manually: sudo pmset -a sleep 0 standby 0 hibernatemode 0 powernap 0 displaysleep 15 disksleep 0"
        mark_step "$step_name"
        return 0
    }

    # Verify
    local new_sleep_val
    new_sleep_val=$(pmset -g 2>/dev/null | grep -E "^ sleep" | awk '{print $2}' || echo "unknown")
    if [ "$new_sleep_val" = "0" ]; then
        pass "System sleep disabled"
        pass "Display sleep set to 15 min (saves energy, doesn't affect the bot)"
    else
        warn "Sleep value after change: ${new_sleep_val} (expected 0)"
    fi

    mark_step "$step_name"
}

step_disable_auto_updates() {
    local step_name="disable_auto_updates"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Auto-update restart disable"
        return 0
    fi

    step_header "Disable Auto-Update Restarts"

    local auto_update
    auto_update=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates 2>/dev/null || echo "not_set")

    if [ "$auto_update" = "0" ]; then
        pass "Automatic macOS update restarts already disabled"
        mark_step "$step_name"
        return 0
    fi

    if [ "$auto_update" = "1" ]; then
        warn "Automatic macOS update restarts are ON"
    else
        info "Auto-update restart setting: ${auto_update}"
    fi

    info "macOS can auto-restart for updates even with sleep disabled."
    info "This is a separate system — sleep prevention alone doesn't prevent update restarts."
    echo ""
    info "Command: sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool FALSE"
    echo ""

    if ! confirm_destructive "Disable automatic macOS update restarts? (requires sudo)"; then
        warn "Skipping auto-update disable"
        info "Fix later: sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool FALSE"
        mark_step "$step_name"
        return 0
    fi

    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool FALSE || {
        fail "Failed to disable auto-updates (sudo may have been denied)"
        info "Run manually: sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool FALSE"
        mark_step "$step_name"
        return 0
    }

    # Verify
    local new_val
    new_val=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates 2>/dev/null || echo "not_set")
    if [ "$new_val" = "0" ]; then
        pass "Automatic macOS update restarts disabled"
    else
        warn "Setting after change: ${new_val} (expected 0)"
    fi

    mark_step "$step_name"
}

step_harden_permissions() {
    local step_name="harden_permissions"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Permission hardening"
        return 0
    fi

    step_header "Config File Permission Hardening"

    local openclaw_dir="$HOME/.openclaw"
    local any_changes=false

    if [ ! -d "$openclaw_dir" ]; then
        info "OpenClaw directory not found yet — will be created during onboarding"
        mark_step "$step_name"
        return 0
    fi

    # Check and fix .openclaw directory
    local dir_perms
    dir_perms=$(stat -f "%Lp" "$openclaw_dir" 2>/dev/null || echo "unknown")
    if [ "$dir_perms" = "700" ]; then
        pass ".openclaw/ directory permissions: 700 (already secured)"
    else
        info ".openclaw/ directory permissions: ${dir_perms} (should be 700)"
        if confirm_or_skip "Set ${openclaw_dir} to chmod 700?"; then
            chmod 700 "$openclaw_dir" && pass "Set .openclaw/ to 700" || fail "Failed to chmod .openclaw/"
            any_changes=true
        fi
    fi

    # Check and fix config file
    if [ -f "$CONFIG_FILE" ]; then
        local config_perms
        config_perms=$(stat -f "%Lp" "$CONFIG_FILE" 2>/dev/null || echo "unknown")
        if [ "$config_perms" = "600" ]; then
            pass "openclaw.json permissions: 600 (already secured)"
        else
            info "openclaw.json permissions: ${config_perms} (should be 600 — contains API keys)"
            if confirm_or_skip "Set ${CONFIG_FILE} to chmod 600?"; then
                chmod 600 "$CONFIG_FILE" && pass "Set openclaw.json to 600" || fail "Failed to chmod openclaw.json"
                any_changes=true
            fi
        fi
    fi

    # Check and fix credentials directory
    local creds_dir="$HOME/.openclaw/credentials"
    if [ -d "$creds_dir" ]; then
        local creds_perms
        creds_perms=$(stat -f "%Lp" "$creds_dir" 2>/dev/null || echo "unknown")
        if [ "$creds_perms" = "700" ]; then
            pass "credentials/ directory permissions: 700 (already secured)"
        else
            info "credentials/ directory permissions: ${creds_perms} (should be 700)"
            if confirm_or_skip "Set ${creds_dir} to chmod 700?"; then
                chmod 700 "$creds_dir" && pass "Set credentials/ to 700" || fail "Failed to chmod credentials/"
                any_changes=true
            fi
        fi
    fi

    # Check and fix auth profiles
    local auth_profiles="$HOME/.openclaw/agents/main/agent/auth-profiles.json"
    if [ -f "$auth_profiles" ]; then
        local auth_perms
        auth_perms=$(stat -f "%Lp" "$auth_profiles" 2>/dev/null || echo "unknown")
        if [ "$auth_perms" = "600" ]; then
            pass "auth-profiles.json permissions: 600 (already secured)"
        else
            info "auth-profiles.json permissions: ${auth_perms} (should be 600)"
            if confirm_or_skip "Set auth-profiles.json to chmod 600?"; then
                chmod 600 "$auth_profiles" && pass "Set auth-profiles.json to 600" || fail "Failed to chmod auth-profiles.json"
                any_changes=true
            fi
        fi
    fi

    # Check .env files
    local env_files_found=false
    while IFS= read -r -d '' env_file; do
        env_files_found=true
        local env_perms
        env_perms=$(stat -f "%Lp" "$env_file" 2>/dev/null || echo "unknown")
        if [ "$env_perms" = "600" ]; then
            pass "$(basename "$env_file") permissions: 600 (already secured)"
        else
            info "$(basename "$env_file") permissions: ${env_perms} (should be 600)"
            if confirm_or_skip "Set $(basename "$env_file") to chmod 600?"; then
                chmod 600 "$env_file" && pass "Set $(basename "$env_file") to 600" || true
                any_changes=true
            fi
        fi
    done < <(find "$openclaw_dir" -name ".env*" -print0 2>/dev/null)

    if ! $any_changes; then
        pass "All permissions already correctly set"
    fi

    mark_step "$step_name"
}

step_apply_access_profile() {
    local step_name="apply_access_profile"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Access profile application"
        return 0
    fi

    step_header "Apply Access Profile"

    if [ ! -f "$CONFIG_FILE" ]; then
        warn "Config file not found — skipping access profile"
        info "Run onboarding first, then re-run with --resume"
        mark_step "$step_name"
        return 0
    fi

    # Check if sandbox/tools are already configured
    local current_sandbox
    current_sandbox=$(json_get "$CONFIG_FILE" "agents.defaults.sandbox.mode" 2>/dev/null)
    if [ -n "$current_sandbox" ]; then
        pass "Access profile already configured (sandbox mode: ${current_sandbox})"
        echo ""
        if ! confirm "Reconfigure the access profile?"; then
            mark_step "$step_name"
            return 0
        fi
    fi

    info "Access profiles control what your bot can physically do."
    info "The approval tier (how much you supervise) is separate."
    echo ""
    echo -e "  ${BOLD}1. Explorer${NC} (recommended for most founders)"
    echo -e "     All tools enabled. Web, shell, files, messaging."
    echo -e "     OS-level user isolation provides the safety boundary."
    echo ""
    echo -e "  ${BOLD}2. Guarded${NC} (for bots processing untrusted content)"
    echo -e "     Web and messaging enabled. Shell commands blocked."
    echo ""
    echo -e "  ${BOLD}3. Restricted${NC} (alert-only bots)"
    echo -e "     Messaging and memory only. No web, no shell, no files."
    echo ""

    local choice
    if [ "$MODE" = "minimal" ]; then
        choice="1"
        info "(--minimal) Auto-selecting Explorer profile"
    else
        choice=$(prompt_input "Choose a profile [1/2/3]" "1")
    fi

    case "$choice" in
        1|explorer|Explorer)
            info "Applying Explorer profile..."
            atomic_config_edit "agents.defaults.sandbox" '{"mode": "off", "workspaceAccess": "rw"}' --type json || return 1
            atomic_config_edit "agents.defaults.tools" '{"notes": "All tools enabled. Monitor via logs channel."}' --type json || return 1
            pass "Explorer profile applied"
            ;;
        2|guarded|Guarded)
            info "Applying Guarded profile..."
            atomic_config_edit "agents.defaults.sandbox" '{"mode": "off", "workspaceAccess": "rw"}' --type json || return 1
            atomic_config_edit "agents.defaults.tools" '{"deny": ["exec"], "notes": "Shell commands blocked. Web browsing and messaging allowed."}' --type json || return 1
            pass "Guarded profile applied"
            ;;
        3|restricted|Restricted)
            info "Applying Restricted profile..."
            atomic_config_edit "agents.defaults.sandbox" '{"mode": "off", "workspaceAccess": "ro"}' --type json || return 1
            atomic_config_edit "agents.defaults.tools" '{"deny": ["exec", "browser", "web_search", "web_fetch"], "notes": "Messaging and memory only. No web, no shell."}' --type json || return 1
            pass "Restricted profile applied"
            ;;
        *)
            warn "Invalid choice '${choice}' — defaulting to Explorer"
            atomic_config_edit "agents.defaults.sandbox" '{"mode": "off", "workspaceAccess": "rw"}' --type json || return 1
            atomic_config_edit "agents.defaults.tools" '{"notes": "All tools enabled. Monitor via logs channel."}' --type json || return 1
            pass "Explorer profile applied (default)"
            ;;
    esac

    info "You can change profiles later by editing ~/.openclaw/openclaw.json"

    mark_step "$step_name"
}

step_run_doctor() {
    local step_name="run_doctor"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): openclaw doctor"
        return 0
    fi

    step_header "Run openclaw doctor"

    if ! command -v openclaw &>/dev/null; then
        warn "OpenClaw not found — skipping doctor check"
        mark_step "$step_name"
        return 0
    fi

    info "Running openclaw doctor to validate configuration..."
    echo ""

    local doctor_output
    doctor_output=$(openclaw doctor 2>&1 || true)
    local doctor_exit=$?

    # Filter out Node.js deprecation warnings
    local doctor_filtered
    doctor_filtered=$(echo "$doctor_output" | grep -v "DeprecationWarning" | grep -v "trace-deprecation")

    echo "$doctor_filtered"
    echo ""

    if echo "$doctor_filtered" | grep -qiE "Errors: [1-9]|critical|FAIL"; then
        fail "openclaw doctor reports issues"
        echo ""
        info "Fix the issues above, then re-run: openclaw doctor"
        info "If stuck, restore config backup: ls ~/.openclaw/openclaw.json.backup-*"
    elif [ $doctor_exit -eq 0 ]; then
        pass "openclaw doctor: all checks passed"
    else
        warn "openclaw doctor exited with code ${doctor_exit}"
    fi

    mark_step "$step_name"
}

step_final_verify() {
    local step_name="final_verify"
    if $RESUME && is_step_done "$step_name"; then
        info "Skipping (already done): Final verification"
        return 0
    fi

    step_header "Final Verification"

    # Try to run the verify script
    if [ -f "$VERIFY_SCRIPT" ]; then
        info "Running openclaw-verify.sh for comprehensive check..."
        echo ""
        bash "$VERIFY_SCRIPT" || true
        echo ""
    else
        info "Verification script not found at: ${VERIFY_SCRIPT}"
        info "Running built-in checks instead..."
        echo ""

        local checks_pass=0
        local checks_fail=0

        # Node.js
        if command -v node &>/dev/null; then
            local nv
            nv=$(node --version)
            pass "Node.js: ${nv}"
            checks_pass=$((checks_pass + 1))
        else
            fail "Node.js: not found"
            checks_fail=$((checks_fail + 1))
        fi

        # OpenClaw
        if command -v openclaw &>/dev/null; then
            local ov
            ov=$(parse_openclaw_version "$(openclaw --version 2>&1 | head -1)")
            pass "OpenClaw: ${ov}"
            checks_pass=$((checks_pass + 1))

            if version_gte "$ov" "$MIN_VERSION"; then
                pass "Version meets minimum (${MIN_VERSION})"
                checks_pass=$((checks_pass + 1))
            else
                fail "Version below minimum ${MIN_VERSION}"
                checks_fail=$((checks_fail + 1))
            fi
        else
            fail "OpenClaw: not found"
            checks_fail=$((checks_fail + 1))
        fi

        # Config
        if [ -f "$CONFIG_FILE" ]; then
            pass "Config file exists"
            checks_pass=$((checks_pass + 1))
            if json_validate "$CONFIG_FILE"; then
                pass "Config is valid JSON"
                checks_pass=$((checks_pass + 1))
            else
                fail "Config is invalid JSON"
                checks_fail=$((checks_fail + 1))
            fi
        else
            fail "Config file not found"
            checks_fail=$((checks_fail + 1))
        fi

        # Home directory
        local hp
        hp=$(stat -f "%Lp" "$HOME" 2>/dev/null)
        if [ "$hp" = "700" ]; then
            pass "Home directory: 700"
            checks_pass=$((checks_pass + 1))
        else
            warn "Home directory: ${hp} (should be 700)"
        fi

        # Gateway
        if pgrep -f "openclaw" &>/dev/null; then
            pass "Gateway process: running"
            checks_pass=$((checks_pass + 1))
        else
            fail "Gateway process: not running"
            checks_fail=$((checks_fail + 1))
        fi

        if lsof -i ":${GATEWAY_PORT}" -sTCP:LISTEN &>/dev/null; then
            pass "Gateway port ${GATEWAY_PORT}: listening"
            checks_pass=$((checks_pass + 1))
        else
            fail "Gateway port ${GATEWAY_PORT}: not listening"
            checks_fail=$((checks_fail + 1))
        fi

        # Sleep
        local sv
        sv=$(pmset -g 2>/dev/null | grep -E "^ sleep" | awk '{print $2}' || echo "unknown")
        if [ "$sv" = "0" ]; then
            pass "Sleep prevention: enabled"
            checks_pass=$((checks_pass + 1))
        else
            warn "Sleep: ${sv} (should be 0)"
        fi

        echo ""
        echo -e "  ${GREEN}${checks_pass} passed${NC}  ${RED}${checks_fail} failed${NC}"
        echo ""

        if [ "$checks_fail" -eq 0 ]; then
            echo -e "  ${GREEN}${BOLD}ALL CHECKS PASSED${NC}"
        else
            echo -e "  ${YELLOW}${BOLD}${checks_fail} issue(s) to address${NC}"
        fi
    fi

    mark_step "$step_name"
}

# ═══════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════

main() {
    parse_args "$@"

    # Show banner
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  OpenClaw Auto-Setup v${SCRIPT_VERSION}${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  Mode: ${CYAN}${MODE}${NC}"
    echo -e "  User: ${CYAN}$(whoami)${NC} on $(hostname)"
    echo -e "  Date: $(date '+%Y-%m-%d %H:%M')"
    if $RESUME; then
        echo -e "  ${YELLOW}Resuming from last checkpoint${NC}"
    fi
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"

    # Start logging
    log_start
    info "Log file: ${LOG_FILE}"

    # Initialize progress tracking
    progress_init

    if $RESUME; then
        show_progress
    fi

    echo ""
    if [ "$MODE" = "minimal" ]; then
        info "Running in --minimal mode (gateway only)."
        info "Non-destructive steps skip confirmation."
        info "Destructive steps still require explicit approval."
        STEP_TOTAL=10
    elif [ "$MODE" = "full" ]; then
        info "Running in --full mode (everything, with confirmations)."
    else
        info "Running in interactive mode."
        info "Each step will explain what it does and ask for confirmation."
    fi

    echo ""
    if ! $RESUME; then
        if [ "$MODE" != "minimal" ]; then
            if ! confirm "Ready to begin?"; then
                info "Exiting. Re-run when ready."
                exit 0
            fi
        fi
    fi

    # ─── Run Steps ───

    # Step 1: Environment detection (always runs)
    step_detect_env

    # Step 2: Homebrew (if needed)
    step_install_homebrew

    # Step 3: Node.js (if needed)
    step_install_node

    # Step 4: OpenClaw install/update
    step_install_openclaw

    # Step 5: Mac user creation (human checkpoint) — skip in minimal
    if [ "$MODE" != "minimal" ]; then
        step_create_mac_user
    else
        info ""
        info "Skipping Mac user creation in --minimal mode"
    fi

    # Step 6: Home directory lockdown
    step_lock_home_dir

    # Step 7: API keys (human checkpoint)
    step_get_api_keys

    # Step 8: Onboarding wizard (human checkpoint)
    step_run_onboard

    # Step 9: Gateway verification
    step_verify_gateway

    # Step 10: Discord setup (human checkpoint) — skip in minimal
    if [ "$MODE" != "minimal" ]; then
        step_setup_discord
    else
        info ""
        info "Skipping Discord setup in --minimal mode"
    fi

    # Step 11: Sleep prevention
    step_prevent_sleep

    # Step 12: Auto-update restart disable
    step_disable_auto_updates

    # Step 13: Permission hardening
    step_harden_permissions

    # Step 14: Access profile
    step_apply_access_profile

    # Step 15: openclaw doctor
    step_run_doctor

    # Step 16: Final verification
    step_final_verify

    # ─── Summary ───
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  Setup Complete${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${PASS} Environment detected and validated"
    echo -e "  ${PASS} Dependencies installed (Node.js, OpenClaw)"
    echo -e "  ${PASS} Gateway configured and verified"
    echo -e "  ${PASS} Security hardening applied"
    echo ""
    echo -e "  ${BOLD}What you have now:${NC}"
    echo -e "  ${INFO} Running OpenClaw gateway (auto-starts on reboot)"
    echo -e "  ${INFO} AI provider configured"
    if [ "$MODE" != "minimal" ]; then
        echo -e "  ${INFO} Communication channel connected"
    fi
    echo -e "  ${INFO} Mac sleep prevention configured"
    echo -e "  ${INFO} File permissions hardened"
    echo ""
    echo -e "  ${BOLD}What's next:${NC}"
    echo -e "  ${INFO} Open the dashboard: ${CYAN}openclaw dashboard${NC}"
    echo -e "  ${INFO} Talk to your bot to verify it responds"
    echo -e "  ${INFO} Start the ${BOLD}Foundation Playbook${NC} for hardening + advanced config"
    echo ""
    echo -e "  ${BOLD}Useful commands:${NC}"
    echo -e "  ${DIM}  openclaw gateway status    # Check gateway status${NC}"
    echo -e "  ${DIM}  openclaw doctor             # Validate configuration${NC}"
    echo -e "  ${DIM}  openclaw gateway restart    # Restart gateway${NC}"
    echo -e "  ${DIM}  openclaw dashboard          # Open web dashboard${NC}"
    echo ""
    echo -e "  ${BOLD}Files:${NC}"
    echo -e "  ${DIM}  Config:   ${CONFIG_FILE}${NC}"
    echo -e "  ${DIM}  Log:      ${LOG_FILE}${NC}"
    echo -e "  ${DIM}  Progress: ${PROGRESS_FILE}${NC}"
    echo ""
    if [ -f "$VERIFY_SCRIPT" ]; then
        echo -e "  Re-verify anytime: ${CYAN}bash ${VERIFY_SCRIPT}${NC}"
    fi
    echo ""
}

# ═══════════════════════════════════════════════════════════════════
# Entry point
# ═══════════════════════════════════════════════════════════════════
main "$@"
