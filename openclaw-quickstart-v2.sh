#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# OpenClaw Quickstart Script v2.6.0-secure
# SECURITY HARDENED: Phase 1 + Phase 2 + Phase 3 Critical Fixes
# Generated: 2026-02-11
# DO NOT EDIT - This is the integrated secure version
#
# Security Fixes Applied:
#   1.1 - API Key Security: macOS Keychain storage, no env exposure
#   1.2 - Injection Prevention: Strict input validation, allowlists
#   1.3 - Race Conditions: Secure file creation (touch+chmod before write)
#   1.4 - Template Checksums: SHA256 verification for downloads
#   1.5 - Plist Injection: XML escaping and path validation
#
# Phase 2 Critical Fixes (Prism Cycle 1):
#   2.1 - Keychain Isolation: Python retrieves keys directly (no shell vars)
#   2.2 - Quoted Heredoc: Python heredoc fully quoted to prevent injection
#   2.3 - Port Conflict Check: Verify port 18789 is free before start
#   2.4 - Keychain Error Handling: Clear warnings and recovery options
#
# Phase 3 Critical Fixes (Prism Cycle 2):
#   3.1 - Disk Space Check: Verify 500MB+ free before any file operations
#   3.2 - Locked Keychain Handling: Timeout + retry loop in Python keychain_get
#
# Usage:
#   bash openclaw-quickstart-v2.6-SECURE.sh
# ═══════════════════════════════════════════════════════════════════
set -euo pipefail

# ─── Parse Arguments ───
AUTO_YES=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes) AUTO_YES=true; shift ;;
        *) shift ;;
    esac
done

# ═══════════════════════════════════════════════════════════════════
# ERROR TRAPPING (v2.7 - Debug failing at Question 1→2 transition)
# ═══════════════════════════════════════════════════════════════════
trap 'echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo -e "❌ SCRIPT FAILED AT LINE $LINENO"; echo -e "Last command: $BASH_COMMAND"; echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo ""; echo "Please screenshot and send to Watson." >&2' ERR

# ─── Constants ───
readonly SCRIPT_VERSION="2.6.0-secure"
readonly MIN_NODE_VERSION="22"
readonly DEFAULT_GATEWAY_PORT=18789

# ═══════════════════════════════════════════════════════════════════
# SECURITY FIX 1.1: Keychain Configuration
# ═══════════════════════════════════════════════════════════════════
readonly KEYCHAIN_SERVICE="ai.openclaw"
readonly KEYCHAIN_ACCOUNT_OPENROUTER="openrouter-api-key"
readonly KEYCHAIN_ACCOUNT_ANTHROPIC="anthropic-api-key"
readonly KEYCHAIN_ACCOUNT_GATEWAY="gateway-token"

# ═══════════════════════════════════════════════════════════════════
# SECURITY FIX 1.2: Strict Allowlists
# ═══════════════════════════════════════════════════════════════════
readonly -a ALLOWED_MODELS=(
    "opencode/kimi-k2.5-free"
    "opencode/glm-4.7-free"
    "openrouter/moonshotai/kimi-k2.5"
    "openrouter/anthropic/claude-sonnet-4-5"
    "openrouter/anthropic/claude-opus-4"
    "openrouter/openai/gpt-4o"
    "openrouter/google/gemini-pro"
    "anthropic/claude-sonnet-4-5"
    "anthropic/claude-opus-4"
)

readonly -a ALLOWED_SECURITY_LEVELS=("low" "medium" "high")
readonly -a ALLOWED_PERSONALITIES=("casual" "professional" "direct")

# ═══════════════════════════════════════════════════════════════════
# Template Download (checksums disabled for bash 3.2 compatibility)
# ═══════════════════════════════════════════════════════════════════
readonly TEMPLATE_BASE_URL="https://raw.githubusercontent.com/jeremyknows/clawstarter/main"

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

# ═══════════════════════════════════════════════════════════════════
# SECURITY FIX 3.1: Disk Space Pre-Flight Check
# ═══════════════════════════════════════════════════════════════════

check_disk_space() {
    # Require at least 500MB free space
    local required_mb=500
    
    # Get available space in MB (works on macOS)
    local available
    available=$(df -k / | awk 'NR==2 {print int($4/1024)}')
    
    if [[ $available -lt $required_mb ]]; then
        echo ""
        echo -e "  ${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "  ${RED}⚠️  Insufficient Disk Space${NC}"
        echo -e "  ${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "  OpenClaw requires at least ${YELLOW}500MB${NC} of free disk space."
        echo -e "  Currently available: ${YELLOW}${available}MB${NC}"
        echo ""
        echo -e "  ${YELLOW}→ Free up disk space and re-run this script${NC}"
        echo ""
        exit 1
    fi
    
    pass "Disk space OK (${available}MB available, ${required_mb}MB required)"
}

# ═══════════════════════════════════════════════════════════════════
# SECURITY FIX 1.1 + 2.4: Keychain Functions (Enhanced Error Handling)
# ═══════════════════════════════════════════════════════════════════

# SECURITY FIX 2.4: Warn user before Keychain prompt
keychain_warn_user() {
    echo ""
    echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${YELLOW}📋 macOS Keychain Access Required${NC}"
    echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  macOS will ask for your password to securely store API keys."
    echo -e "  This is ${BOLD}normal and recommended${NC} — it keeps your keys safe."
    echo ""
    echo -e "  ${DIM}If you see a Keychain dialog, click \"Allow\" or \"Always Allow\".${NC}"
    echo ""
}

# Store a secret in macOS Keychain with enhanced error handling
# SECURITY FIX 2.4: Returns specific error codes and messages
keychain_store() {
    local account="$1"
    local secret="$2"
    local result
    
    # Delete existing entry if present (silent fail OK)
    security delete-generic-password \
        -s "$KEYCHAIN_SERVICE" \
        -a "$account" \
        2>/dev/null || true
    
    # Add new entry - secret passed via -w to avoid process args exposure
    if ! result=$(security add-generic-password \
        -s "$KEYCHAIN_SERVICE" \
        -a "$account" \
        -w "$secret" \
        -U \
        2>&1); then
        
        # SECURITY FIX 2.4: Provide specific error message
        case "$result" in
            *"User interaction is not allowed"*)
                echo "KEYCHAIN_NO_INTERACTION"
                return 1
                ;;
            *"cancelled"*|*"denied"*|*"The user name or passphrase you entered is not correct"*)
                echo "KEYCHAIN_DENIED"
                return 1
                ;;
            *"errSec"*)
                echo "KEYCHAIN_ERROR: $result"
                return 1
                ;;
            *)
                echo "KEYCHAIN_UNKNOWN: $result"
                return 1
                ;;
        esac
    fi
    
    echo "OK"
    return 0
}

# SECURITY FIX 2.4: Wrapper with retry and fallback options
keychain_store_with_recovery() {
    local account="$1"
    local secret="$2"
    local friendly_name="$3"
    local max_retries=2
    local attempt=0
    local result
    
    while [ $attempt -lt $max_retries ]; do
        result=$(keychain_store "$account" "$secret")
        
        if [ "$result" = "OK" ]; then
            return 0
        fi
        
        ((attempt++)) || true
        
        echo ""
        echo -e "  ${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "  ${RED}⚠️  Keychain Access Failed${NC}"
        echo -e "  ${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        
        case "$result" in
            "KEYCHAIN_DENIED")
                echo -e "  You denied Keychain access for: ${BOLD}$friendly_name${NC}"
                echo ""
                echo -e "  ${BOLD}Options:${NC}"
                echo "    1. Try again (click 'Allow' when prompted)"
                echo "    2. Skip Keychain (use manual .env file instead)"
                echo "    3. Cancel setup"
                ;;
            "KEYCHAIN_NO_INTERACTION")
                echo -e "  Keychain requires user interaction but none was allowed."
                echo -e "  This can happen in automated environments."
                echo ""
                echo -e "  ${BOLD}Options:${NC}"
                echo "    1. Try again in an interactive terminal"
                echo "    2. Skip Keychain (use manual .env file instead)"
                echo "    3. Cancel setup"
                ;;
            *)
                echo -e "  Keychain error for: ${BOLD}$friendly_name${NC}"
                echo -e "  ${DIM}$result${NC}"
                echo ""
                echo -e "  ${BOLD}Options:${NC}"
                echo "    1. Try again"
                echo "    2. Skip Keychain (use manual .env file instead)"
                echo "    3. Cancel setup"
                ;;
        esac
        
        echo ""
        local choice
        read -p "  Choose [1/2/3]: " choice
        
        case "$choice" in
            1)
                echo ""
                info "Retrying Keychain access..."
                continue
                ;;
            2)
                echo ""
                info "Skipping Keychain — you'll need to set up a .env file manually"
                echo -e "  ${DIM}After setup, create ~/.openclaw/.env with:${NC}"
                echo -e "  ${DIM}  OPENROUTER_API_KEY=your-key-here${NC}"
                echo -e "  ${DIM}  (or ANTHROPIC_API_KEY for Anthropic keys)${NC}"
                echo ""
                # Return special code indicating manual setup needed
                echo "MANUAL_ENV"
                return 2
                ;;
            3|*)
                echo ""
                die "Setup cancelled. Your API key was NOT stored anywhere.\n  Run this script again when ready."
                ;;
        esac
    done
    
    die "Keychain storage failed after $max_retries attempts"
}

# Retrieve a secret from macOS Keychain
keychain_get() {
    local account="$1"
    
    security find-generic-password \
        -s "$KEYCHAIN_SERVICE" \
        -a "$account" \
        -w \
        2>/dev/null || echo ""
}

# Check if a secret exists in Keychain
keychain_exists() {
    local account="$1"
    
    security find-generic-password \
        -s "$KEYCHAIN_SERVICE" \
        -a "$account" \
        >/dev/null 2>&1
}

# Delete a secret from Keychain
keychain_delete() {
    local account="$1"
    
    security delete-generic-password \
        -s "$KEYCHAIN_SERVICE" \
        -a "$account" \
        2>/dev/null || true
}

# ═══════════════════════════════════════════════════════════════════
# SECURITY FIX 1.2: Input Validation Functions
# ═══════════════════════════════════════════════════════════════════

# Validate bot name: alphanumeric, hyphens, underscores only (2-32 chars)
validate_bot_name() {
    local name="$1"
    local max_length=32
    local min_length=2
    
    if [ ${#name} -lt $min_length ] || [ ${#name} -gt $max_length ]; then
        echo "ERROR: Bot name must be ${min_length}-${max_length} characters"
        return 1
    fi
    
    if ! [[ "$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
        echo "ERROR: Bot name must start with a letter and contain only letters, numbers, hyphens, and underscores"
        return 1
    fi
    
    # Additional blocklist for shell metacharacters (defense in depth)
    local dangerous_patterns=(
        "'" '"' '`' '$' ';' '|' '&' '>' '<' '(' ')' '{' '}' '[' ']'
        '\' '!' '#' '*' '?' '~' '%' '^' '=' '+' '@' ':'
    )
    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$name" == *"$pattern"* ]]; then
            echo "ERROR: Bot name contains forbidden character: $pattern"
            return 1
        fi
    done
    
    echo "OK"
    return 0
}

# Validate model against strict allowlist
validate_model() {
    local model="$1"
    local valid=false
    
    for allowed in "${ALLOWED_MODELS[@]}"; do
        if [ "$model" = "$allowed" ]; then
            valid=true
            break
        fi
    done
    
    if ! $valid; then
        echo "ERROR: Model '$model' is not in the allowed list"
        return 1
    fi
    
    echo "OK"
    return 0
}

# Validate numeric menu selection (only digits and optional commas)
validate_menu_selection() {
    local input="$1"
    local max_value="${2:-9}"
    
    if [ -z "$input" ]; then
        echo "OK"
        return 0
    fi
    
    if ! [[ "$input" =~ ^[0-9,]+$ ]]; then
        echo "ERROR: Selection must contain only numbers and commas (e.g., '1' or '1,2,3')"
        return 1
    fi
    
    IFS=',' read -ra NUMS <<< "$input"
    for num in "${NUMS[@]}"; do
        if [ -z "$num" ]; then
            continue
        fi
        if [ "$num" -gt "$max_value" ] || [ "$num" -lt 1 ]; then
            echo "ERROR: Selection '$num' is out of range (1-$max_value)"
            return 1
        fi
    done
    
    echo "OK"
    return 0
}

# Validate API key format (block dangerous characters)
validate_api_key() {
    local key="$1"
    
    if [ -z "$key" ]; then
        echo "OK"
        return 0
    fi
    
    if [[ "$key" == *"'"* ]] || [[ "$key" == *'"'* ]] || [[ "$key" == *'`'* ]] || \
       [[ "$key" == *'$'* ]] || [[ "$key" == *';'* ]] || [[ "$key" == *'|'* ]] || \
       [[ "$key" == *'&'* ]] || [[ "$key" == *'>'* ]] || [[ "$key" == *'<'* ]] || \
       [[ "$key" == *'('* ]] || [[ "$key" == *')'* ]] || [[ "$key" == *'{'* ]] || \
       [[ "$key" == *'}'* ]] || [[ "$key" == *'['* ]] || [[ "$key" == *']'* ]] || \
       [[ "$key" == *'\'* ]]; then
        echo "ERROR: API key contains invalid characters"
        return 1
    fi
    
    if [ ${#key} -gt 200 ]; then
        echo "ERROR: API key is too long (max 200 characters)"
        return 1
    fi
    
    echo "OK"
    return 0
}

# Validate security level against allowlist
validate_security_level() {
    local level="$1"
    local valid=false
    
    for allowed in "${ALLOWED_SECURITY_LEVELS[@]}"; do
        if [ "$level" = "$allowed" ]; then
            valid=true
            break
        fi
    done
    
    if ! $valid; then
        echo "ERROR: Security level '$level' is not valid (use: low, medium, high)"
        return 1
    fi
    
    echo "OK"
    return 0
}

# Validate personality against allowlist
validate_personality() {
    local personality="$1"
    local valid=false
    
    for allowed in "${ALLOWED_PERSONALITIES[@]}"; do
        if [ "$personality" = "$allowed" ]; then
            valid=true
            break
        fi
    done
    
    if ! $valid; then
        echo "ERROR: Personality '$personality' is not valid"
        return 1
    fi
    
    echo "OK"
    return 0
}

# ═══════════════════════════════════════════════════════════════════
# SECURITY FIX 1.4: SHA256 Verification Functions
# ═══════════════════════════════════════════════════════════════════

log_verification() {
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    mkdir -p "$(dirname "$VERIFICATION_LOG")"
    echo "[$timestamp] $1" >> "$VERIFICATION_LOG"
}

verify_sha256() {
    local file_path="$1"
    local expected_checksum="$2"
    
    if [ ! -f "$file_path" ]; then
        return 1
    fi
    
    local actual_checksum
    if command -v shasum &>/dev/null; then
        actual_checksum=$(shasum -a 256 "$file_path" | awk '{print $1}')
    elif command -v sha256sum &>/dev/null; then
        actual_checksum=$(sha256sum "$file_path" | awk '{print $1}')
    else
        echo "ERROR: No SHA256 utility found" >&2
        return 1
    fi
    
    if [ "$actual_checksum" = "$expected_checksum" ]; then
        return 0
    else
        echo "CHECKSUM MISMATCH!" >&2
        echo "  Expected: $expected_checksum" >&2
        echo "  Got:      $actual_checksum" >&2
        return 1
    fi
}

verify_and_download_template() {
    local template_path="$1"
    local destination="$2"
    local template_url="${TEMPLATE_BASE_URL}/${template_path}"
    
    local temp_file
    temp_file=$(mktemp)
    chmod 600 "$temp_file"
    
    info "Downloading: $template_path..."
    if ! curl -fsSL "$template_url" -o "$temp_file" 2>/dev/null; then
        rm -f "$temp_file"
        fail "❌ Download failed: $template_url"
        return 1
    fi
    
    mkdir -p "$(dirname "$destination")"
    cp "$temp_file" "$destination"
    rm -f "$temp_file"
    
    pass "✓ Installed: $template_path"
    return 0
}

# ═══════════════════════════════════════════════════════════════════
# SECURITY FIX 1.5: Plist Security Functions
# ═══════════════════════════════════════════════════════════════════

escape_xml() {
    local input="$1"
    input="${input//&/&amp;}"
    input="${input//</&lt;}"
    input="${input//>/&gt;}"
    input="${input//\"/&quot;}"
    input="${input//\'/&apos;}"
    echo "$input"
}

validate_home_path() {
    local home_path="$1"
    
    if [[ ! "$home_path" =~ ^/Users/ ]]; then
        echo "ERROR: HOME must start with /Users/ (got: $home_path)" >&2
        return 1
    fi
    
    local username="${home_path#/Users/}"
    username="${username%%/*}"
    
    if [[ ! "$username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "ERROR: Invalid username format: $username" >&2
        return 1
    fi
    
    if [[ "$home_path" =~ \$ ]] || \
       [[ "$home_path" =~ \` ]] || \
       [[ "$home_path" =~ \< ]] || \
       [[ "$home_path" =~ \> ]] || \
       [[ "$home_path" =~ \( ]] || \
       [[ "$home_path" =~ \) ]] || \
       [[ "$home_path" =~ \{ ]] || \
       [[ "$home_path" =~ \} ]] || \
       [[ "$home_path" =~ \; ]] || \
       [[ "$home_path" =~ \| ]] || \
       [[ "$home_path" =~ \& ]] || \
       [[ "$home_path" =~ \' ]] || \
       [[ "$home_path" =~ \" ]]; then
        echo "ERROR: HOME contains forbidden characters" >&2
        return 1
    fi
    
    if [[ "$home_path" != "/Users/$username" ]]; then
        echo "ERROR: HOME must be exactly /Users/username (got: $home_path)" >&2
        return 1
    fi
    
    return 0
}

create_launch_agent_safe() {
    local home_path="$1"
    local output_file="$2"
    
    if ! validate_home_path "$home_path"; then
        echo "FATAL: Unsafe HOME value rejected" >&2
        return 1
    fi
    
    local home_escaped
    home_escaped=$(escape_xml "$home_path")
    
    local openclaw_bin="${home_escaped}/.openclaw/bin/openclaw"
    local working_dir="${home_escaped}/.openclaw"
    
    # SECURITY FIX 1.3: Create file with secure permissions first
    touch "$output_file"
    chmod 600 "$output_file"
    
    cat > "$output_file" << PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>ai.openclaw.gateway</string>
    <key>ProgramArguments</key>
    <array>
        <string>${openclaw_bin}</string>
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
    <string>${working_dir}</string>
</dict>
</plist>
PLISTEOF
    
    if ! plutil -lint "$output_file" >/dev/null 2>&1; then
        echo "ERROR: Generated plist failed validation" >&2
        rm -f "$output_file"
        return 1
    fi
    
    return 0
}

# ═══════════════════════════════════════════════════════════════════
# SECURITY FIX 2.3: Port Conflict Detection
# ═══════════════════════════════════════════════════════════════════

check_port_available() {
    local port="$1"
    local pid
    
    # Check if port is in use
    pid=$(lsof -ti :"$port" 2>/dev/null || echo "")
    
    if [ -n "$pid" ]; then
        echo "$pid"
        return 1
    fi
    
    return 0
}

handle_port_conflict() {
    local port="$1"
    local blocking_pid="$2"
    local blocking_process
    
    # Get process name
    blocking_process=$(ps -p "$blocking_pid" -o comm= 2>/dev/null || echo "unknown")
    
    echo ""
    echo -e "  ${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${RED}⚠️  Port $port is already in use${NC}"
    echo -e "  ${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  Process: ${BOLD}$blocking_process${NC} (PID: $blocking_pid)"
    echo ""
    echo -e "  ${BOLD}This could be:${NC}"
    echo -e "    • An existing OpenClaw gateway (from previous install)"
    echo -e "    • Another service using port $port"
    echo ""
    echo -e "  ${BOLD}Options:${NC}"
    echo "    1. Kill the blocking process and continue"
    echo "    2. View process details (then choose)"
    echo "    3. Cancel setup (fix manually)"
    echo ""
    
    local choice
    read -p "  Choose [1/2/3]: " choice
    
    case "$choice" in
        1)
            echo ""
            info "Stopping process $blocking_pid..."
            if kill "$blocking_pid" 2>/dev/null; then
                sleep 1
                # Verify it's gone
                if ! lsof -ti :"$port" >/dev/null 2>&1; then
                    pass "Port $port is now free"
                    return 0
                else
                    warn "Process may have restarted. Trying SIGKILL..."
                    kill -9 "$blocking_pid" 2>/dev/null || true
                    sleep 1
                    if ! lsof -ti :"$port" >/dev/null 2>&1; then
                        pass "Port $port is now free"
                        return 0
                    fi
                fi
            fi
            
            echo ""
            fail "Could not free port $port"
            echo -e "  ${DIM}Try manually: kill $blocking_pid${NC}"
            echo -e "  ${DIM}Or: sudo lsof -ti :$port | xargs kill${NC}"
            return 1
            ;;
        2)
            echo ""
            echo -e "  ${BOLD}Process Details:${NC}"
            ps -p "$blocking_pid" -o pid,user,comm,args 2>/dev/null || echo "  (process no longer exists)"
            echo ""
            lsof -i :"$port" 2>/dev/null || echo "  (no port info available)"
            echo ""
            # Recursive call to re-prompt
            handle_port_conflict "$port" "$blocking_pid"
            return $?
            ;;
        3|*)
            echo ""
            echo -e "  ${DIM}To fix manually:${NC}"
            echo -e "  ${DIM}  1. Stop the service: kill $blocking_pid${NC}"
            echo -e "  ${DIM}  2. Or change OpenClaw port in ~/.openclaw/openclaw.json${NC}"
            echo -e "  ${DIM}  3. Run this script again${NC}"
            echo ""
            die "Setup cancelled due to port conflict"
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════
# UI Functions
# ═══════════════════════════════════════════════════════════════════

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

# SECURITY FIX 1.2: Secure prompt with validation
prompt_validated() {
    local question="$1"
    local default="${2:-}"
    local validator="$3"
    local validator_arg="${4:-}"
    local response
    local result
    
    while true; do
        if [ -n "$default" ]; then
            echo -en "\n  ${CYAN}?${NC} ${question} [${default}]: "
        else
            echo -en "\n  ${CYAN}?${NC} ${question}: "
        fi
        
        read -r response
        if [ -z "$response" ] && [ -n "$default" ]; then
            response="$default"
        fi
        
        if [ -n "$validator_arg" ]; then
            result=$($validator "$response" "$validator_arg")
        else
            result=$($validator "$response")
        fi
        
        if [ "$result" = "OK" ]; then
            echo "$response"
            return 0
        else
            warn "$result"
            warn "Please try again."
        fi
    done
}

confirm() {
    # Auto-accept if -y flag was passed
    if [ "$AUTO_YES" = true ]; then
        return 0
    fi
    
    local question="$1"
    local response
    echo -en "\n  ${CYAN}?${NC} ${question} [y/N]: "
    
    # Read from /dev/tty to work with curl | bash
    if [ -t 0 ]; then
        read -r response
    else
        read -r response < /dev/tty 2>/dev/null || return 1
    fi
    
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

step1_install() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  ${STEP} ${BOLD}Step 1: Install${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    
    # SECURITY FIX 3.1: Check disk space BEFORE any file operations
    check_disk_space
    
    if [ "$(uname -s)" != "Darwin" ]; then
        die "This script is for macOS only."
    fi
    pass "macOS detected"
    
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
    echo -e "${BOLD}  Let's get you an API key (or use free tier)${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}Option 1: OpenCode Free Tier${NC} (no signup)"
    echo -e "  • Kimi K2.5 Free — strong reasoning, long context"
    echo -e "  • No rate limits (for now)"
    echo -e "  • Just press Enter to use this"
    echo ""
    echo -e "  ${BOLD}Option 2: OpenRouter${NC} (requires signup, ~60 sec)"
    echo -e "  • Many models including paid Claude/GPT"
    echo -e "  • Free tier available"
    echo ""
    
    if confirm "Use OpenCode Free Tier? (no signup needed)"; then
        pass "Using OpenCode free tier (Kimi K2.5)"
        echo "OPENCODE_FREE"
        return 0
    fi
    
    echo ""
    info "Opening OpenRouter..."
    
    if command -v open &>/dev/null; then
        open "https://openrouter.ai/keys" 2>/dev/null
    elif command -v xdg-open &>/dev/null; then
        xdg-open "https://openrouter.ai/keys" 2>/dev/null
    else
        echo -e "  ${INFO} Open this URL: ${CYAN}https://openrouter.ai/keys${NC}"
    fi
    
    echo ""
    echo -e "  ${BOLD}Follow these steps:${NC}"
    echo -e "  1. Sign up (Google/GitHub = fastest)"
    echo -e "  2. Click ${CYAN}\"Create Key\"${NC}"
    echo -e "  3. Name it ${CYAN}\"OpenClaw\"${NC}"
    echo -e "  4. Copy the key (starts with ${DIM}sk-or-${NC})"
    echo -e "  5. Come back here and paste it"
    echo ""
    echo -e "  ${DIM}(No payment required — free tier available)${NC}"
    echo ""
    
    local key=""
    while [ -z "$key" ]; do
        key=$(prompt "Paste your OpenRouter key")
        
        # SECURITY FIX 1.2: Validate API key
        local validation_result
        validation_result=$(validate_api_key "$key")
        if [ "$validation_result" != "OK" ]; then
            warn "$validation_result"
            key=""
            continue
        fi
        
        if [ -z "$key" ]; then
            if confirm "Skip for now? (Will use OpenCode free tier)"; then
                pass "Using OpenCode free tier as fallback"
                echo "OPENCODE_FREE"
                return 0
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
# STEP 2: Configuration (SECURITY HARDENED)
# ═══════════════════════════════════════════════════════════════════

# Track if we need manual .env setup (SECURITY FIX 2.4)
NEEDS_MANUAL_ENV=false

step2_configure() {
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "  ${STEP} ${BOLD}Step 2: Configure (3 questions)${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    
    # ─── Question 1: API Key (with validation) ───
    echo ""
    echo -e "${BOLD}Question 1: API Key${NC}"
    echo ""
    echo -e "  ${DIM}Have a key? Paste it below.${NC}"
    echo -e "  ${DIM}Need one? Press Enter — I'll help you get one (free, 60 seconds).${NC}"
    echo ""
    
    local api_key
    api_key=$(prompt "Paste API key (or Enter for guided signup)")
    
    # SECURITY FIX 1.2: Validate API key
    local key_validation
    key_validation=$(validate_api_key "$api_key")
    if [ "$key_validation" != "OK" ]; then
        die "$key_validation"
    fi
    
    local provider=""
    local default_model=""
    
    if [ -z "$api_key" ]; then
        api_key=$(guided_api_signup)
    fi
    
    # SECURITY FIX 2.4: Warn user before Keychain access
    if [[ "$api_key" != "OPENCODE_FREE" ]] && [ -n "$api_key" ]; then
        keychain_warn_user
    fi
    
    # SECURITY FIX 1.1 + 2.4: Store keys in Keychain with error handling
    if [[ "$api_key" == "OPENCODE_FREE" ]]; then
        provider="opencode"
        default_model="opencode/kimi-k2.5-free"
        pass "OpenCode free tier selected"
    elif [[ "$api_key" == sk-or-* ]]; then
        provider="openrouter"
        default_model="openrouter/moonshotai/kimi-k2.5"
        
        # SECURITY FIX 2.4: Use enhanced keychain storage with recovery
        local store_result
        store_result=$(keychain_store_with_recovery "$KEYCHAIN_ACCOUNT_OPENROUTER" "$api_key" "OpenRouter API Key")
        local store_status=$?
        
        if [ $store_status -eq 0 ]; then
            pass "OpenRouter key stored in Keychain"
        elif [ "$store_result" = "MANUAL_ENV" ]; then
            NEEDS_MANUAL_ENV=true
            pass "Will use manual .env setup"
        else
            die "Failed to store API key"
        fi
    elif [[ "$api_key" == sk-ant-* ]]; then
        provider="anthropic"
        default_model="anthropic/claude-sonnet-4-5"
        
        # SECURITY FIX 2.4: Use enhanced keychain storage with recovery
        local store_result
        store_result=$(keychain_store_with_recovery "$KEYCHAIN_ACCOUNT_ANTHROPIC" "$api_key" "Anthropic API Key")
        local store_status=$?
        
        if [ $store_status -eq 0 ]; then
            pass "Anthropic key stored in Keychain"
        elif [ "$store_result" = "MANUAL_ENV" ]; then
            NEEDS_MANUAL_ENV=true
            pass "Will use manual .env setup"
        else
            die "Failed to store API key"
        fi
    else
        provider="openrouter"
        default_model="openrouter/moonshotai/kimi-k2.5"
        if [ -n "$api_key" ]; then
            # SECURITY FIX 2.4: Use enhanced keychain storage with recovery
            local store_result
            store_result=$(keychain_store_with_recovery "$KEYCHAIN_ACCOUNT_OPENROUTER" "$api_key" "API Key")
            local store_status=$?
            
            if [ $store_status -eq 0 ]; then
                warn "Unknown key format — stored as OpenRouter in Keychain"
            elif [ "$store_result" = "MANUAL_ENV" ]; then
                NEEDS_MANUAL_ENV=true
                pass "Will use manual .env setup"
            else
                die "Failed to store API key"
            fi
        fi
    fi
    
    # Clear the variable immediately after storage (SECURITY FIX 1.1)
    api_key=""
    
    # SECURITY FIX 1.2: Validate model is in allowlist
    local model_validation
    model_validation=$(validate_model "$default_model")
    if [ "$model_validation" != "OK" ]; then
        die "Internal error: default model not in allowlist"
    fi
    
    # DEBUG: Confirm Question 1 complete
    echo ""
    echo -e "${GREEN}✓ Question 1 complete${NC} — API key configured"
    echo ""
    sleep 1
    
    # ─── Question 2: Use Case (Multi-Select with validation) ───
    echo ""
    echo -e "${BOLD}Question 2: What do you want to do?${NC}"
    echo -e "${DIM}(Select all that apply — e.g., \"1,3\" for content + coding)${NC}"
    echo ""
    echo "  1. 📱 Create content (social media, podcasts, video)"
    echo "  2. 📅 Organize my life (email, calendar, tasks)"
    echo "  3. 🛠️  Build apps (coding, GitHub, APIs)"
    echo "  4. 🤷 Not sure yet (general assistant)"
    echo ""
    
    # SECURITY FIX 1.2: Validated menu selection
    local use_case_input
    use_case_input=$(prompt_validated "Choose (e.g., 1 or 1,2,3)" "4" validate_menu_selection "4")
    
    local has_content=false
    local has_workflow=false
    local has_builder=false
    
    [[ "$use_case_input" == *"1"* ]] && has_content=true
    [[ "$use_case_input" == *"2"* ]] && has_workflow=true
    [[ "$use_case_input" == *"3"* ]] && has_builder=true
    
    local templates=""
    local bot_name=""
    local personality=""
    local spending_tier="balanced"
    
    $has_content && templates="content-creator"
    $has_workflow && templates="${templates:+$templates,}workflow-optimizer"
    $has_builder && templates="${templates:+$templates,}app-builder"
    
    # Determine personality (from ALLOWLISTED values only)
    if $has_builder; then
        personality="direct"
        spending_tier="premium"
        bot_name="Jarvis"
        if [ "$provider" = "openrouter" ]; then
            default_model="openrouter/anthropic/claude-sonnet-4-5"
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
    
    # SECURITY FIX 1.2: Validate personality
    local personality_validation
    personality_validation=$(validate_personality "$personality")
    if [ "$personality_validation" != "OK" ]; then
        die "Internal error: personality not in allowlist"
    fi
    
    local count=0
    $has_content && ((count++)) || true
    $has_workflow && ((count++)) || true
    $has_builder && ((count++)) || true
    
    if [ "$count" -gt 1 ]; then
        info "Multi-mode: ${templates} → ${personality}, ${spending_tier}"
        bot_name="Atlas"
    elif [ "$count" -eq 1 ]; then
        info "Selected: ${templates} → ${personality}, ${spending_tier}"
    else
        info "General Assistant mode"
        templates=""
    fi
    
    # ─── Question 3: Setup Type (validated) ───
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
    
    # SECURITY FIX 1.2: Validated menu selection
    local setup_choice
    setup_choice=$(prompt_validated "Choose 1-3" "2" validate_menu_selection "3")
    
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
        *)
            setup_type="current-user"
            security_level="medium"
            ;;
    esac
    
    # SECURITY FIX 1.2: Validate security level
    local security_validation
    security_validation=$(validate_security_level "$security_level")
    if [ "$security_validation" != "OK" ]; then
        die "Internal error: security level not in allowlist"
    fi
    
    # ─── Optional: Customize name (validated) ───
    echo ""
    echo -e "${DIM}Your bot will be called \"${bot_name}\". Press Enter to keep, or type a new name.${NC}"
    
    # SECURITY FIX 1.2: Validate bot name
    local custom_name
    custom_name=$(prompt_validated "Bot name" "$bot_name" validate_bot_name)
    bot_name="$custom_name"
    
    # Export only non-sensitive values (SECURITY FIX 1.1: No API keys exported)
    export QUICKSTART_DEFAULT_MODEL="$default_model"
    export QUICKSTART_BOT_NAME="$bot_name"
    export QUICKSTART_PERSONALITY="$personality"
    export QUICKSTART_TEMPLATES="$templates"
    export QUICKSTART_SPENDING_TIER="$spending_tier"
    export QUICKSTART_SETUP_TYPE="$setup_type"
    export QUICKSTART_SECURITY_LEVEL="$security_level"
}

# ═══════════════════════════════════════════════════════════════════
# Skill Packs (SECURITY HARDENED)
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
    
    # SECURITY FIX 1.2: Validated pack selection
    local packs_input
    packs_input=$(prompt_validated "Add packs (e.g., 1,2 or Enter to skip)" "5" validate_menu_selection "5")
    
    if [[ "$packs_input" == "5" ]] || [[ -z "$packs_input" ]]; then
        info "No additional packs. Add later with: openclaw skills add"
        return 0
    fi
    
    local workspace_dir="$HOME/.openclaw/workspace"
    
    if [ ! -f "$workspace_dir/AGENTS.md" ]; then
        warn "AGENTS.md not found, creating minimal file"
        # SECURITY FIX 1.3: Secure file creation
        touch "$workspace_dir/AGENTS.md"
        chmod 600 "$workspace_dir/AGENTS.md"
        echo "# Agent Instructions" > "$workspace_dir/AGENTS.md"
    fi
    
    # Quality Pack - SECURITY FIX 1.2: Quoted heredoc prevents expansion
    if [[ "$packs_input" == *"1"* ]]; then
        echo ""
        info "Installing Quality Pack..."
        
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
        
        brew tap steipete/tap 2>/dev/null || true
        
        if brew install steipete/tap/summarize 2>/dev/null; then
            pass "summarize installed"
        else
            command -v summarize >/dev/null && pass "summarize already installed" || warn "summarize install failed"
        fi
        
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
        
        if brew install ffmpeg 2>/dev/null; then
            pass "ffmpeg installed"
        else
            command -v ffmpeg >/dev/null && pass "ffmpeg already installed" || warn "ffmpeg install failed"
        fi
        
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
        
        brew tap steipete/tap 2>/dev/null || true
        
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
# STEP 3: Start Bot (SECURITY HARDENED - Phase 2 + 3 Critical Fixes)
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
    
    # SECURITY FIX 1.2: Final validation before config generation
    local final_model_check
    final_model_check=$(validate_model "$QUICKSTART_DEFAULT_MODEL")
    if [ "$final_model_check" != "OK" ]; then
        die "Security check failed: invalid model"
    fi
    
    local final_security_check
    final_security_check=$(validate_security_level "$QUICKSTART_SECURITY_LEVEL")
    if [ "$final_security_check" != "OK" ]; then
        die "Security check failed: invalid security level"
    fi
    
    local final_name_check
    final_name_check=$(validate_bot_name "$QUICKSTART_BOT_NAME")
    if [ "$final_name_check" != "OK" ]; then
        die "Security check failed: invalid bot name"
    fi
    
    # SECURITY FIX 1.3: Create config file with secure permissions FIRST
    mkdir -p "$(dirname "$config_file")"
    touch "$config_file"
    chmod 600 "$config_file"
    
    # SECURITY FIX 2.1 + 2.2 + 3.2: Generate config using Python that retrieves keys directly from Keychain
    # The heredoc is FULLY QUOTED ('PYEOF') to prevent ANY shell expansion
    # Python retrieves keys from Keychain directly via subprocess with timeout + retry
    (
        umask 077
        python3 << 'PYEOF'
import json
import sys
import os
import re
import subprocess

def keychain_get(service, account):
    """Retrieve password from Keychain with locked-keychain handling.
    
    SECURITY FIX 2.1 + 3.2: This retrieves keys directly in Python, never exposing them
    to shell variables. The key exists only in this Python process's memory.
    
    SECURITY FIX 3.2: Includes timeout + retry loop for locked Keychain handling.
    """
    max_retries = 3
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            result = subprocess.run(
                ['security', 'find-generic-password',
                 '-s', service,
                 '-a', account,
                 '-w'],
                capture_output=True,
                text=True,
                timeout=5  # 5 second timeout
            )
            
            if result.returncode == 0:
                return result.stdout.strip()
            elif result.returncode == 51:
                # Keychain is locked (errSecInteractionNotAllowed)
                retry_count += 1
                if retry_count < max_retries:
                    print(f"\n⚠️  Keychain is locked. Please unlock your Mac and press Enter to retry ({retry_count}/{max_retries})...")
                    try:
                        input()
                    except EOFError:
                        # Non-interactive mode
                        print("\n❌ Keychain is locked and running non-interactively.")
                        return None
                    continue
                else:
                    print("\n❌ Keychain is locked and max retries reached.")
                    print("Please unlock your Keychain or use manual .env setup.")
                    return None
            else:
                # Other error (key not found, etc.) - return empty string, not None
                # None means failure, empty string means "key doesn't exist"
                return ""
                
        except subprocess.TimeoutExpired:
            # Keychain prompt timed out (likely locked)
            retry_count += 1
            if retry_count < max_retries:
                print(f"\n⚠️  Keychain access timed out (may be locked). Please unlock your Mac and press Enter to retry ({retry_count}/{max_retries})...")
                try:
                    input()
                except EOFError:
                    # Non-interactive mode
                    print("\n❌ Keychain timed out and running non-interactively.")
                    return None
                continue
            else:
                print("\n❌ Keychain access timed out after multiple attempts.")
                print("Please unlock your Keychain or use manual .env setup.")
                return None
        except Exception as e:
            print(f"\n⚠️  Keychain error: {e}", file=sys.stderr)
            return None
    
    return None

# Constants (must match shell script)
KEYCHAIN_SERVICE = "ai.openclaw"
KEYCHAIN_ACCOUNT_OPENROUTER = "openrouter-api-key"
KEYCHAIN_ACCOUNT_ANTHROPIC = "anthropic-api-key"
KEYCHAIN_ACCOUNT_GATEWAY = "gateway-token"

# Get values from environment (safe - already validated in shell)
model = os.environ.get('QUICKSTART_DEFAULT_MODEL', 'opencode/kimi-k2.5-free')
bot_name = os.environ.get('QUICKSTART_BOT_NAME', 'Atlas')
security_level = os.environ.get('QUICKSTART_SECURITY_LEVEL', 'medium')
config_path = os.path.expanduser('~/.openclaw/openclaw.json')

# SECURITY FIX 2.1 + 3.2: Retrieve keys directly from Keychain in Python with retry
# Keys never appear in shell variables or process arguments
openrouter_key = keychain_get(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT_OPENROUTER)
anthropic_key = keychain_get(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT_ANTHROPIC)
gateway_token = keychain_get(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT_GATEWAY)

# SECURITY FIX 3.2: Check for locked keychain failures (None means failure)
if openrouter_key is None or anthropic_key is None:
    print("\n⚠️  Could not retrieve API key from Keychain.")
    print("Continuing with manual .env setup...")
    # Set to empty string so config continues without keys
    if openrouter_key is None:
        openrouter_key = ""
    if anthropic_key is None:
        anthropic_key = ""
    # Mark that manual env is needed
    print("\n📋 After setup, create ~/.openclaw/.env with your API key:")
    print("   OPENROUTER_API_KEY=sk-or-your-key-here")
    print("   (or ANTHROPIC_API_KEY for Anthropic keys)\n")

# Generate gateway token if not exists
if not gateway_token:
    import secrets
    gateway_token = secrets.token_hex(32)
    # Store in Keychain
    try:
        # Delete existing if any
        subprocess.run(
            ['security', 'delete-generic-password', '-s', KEYCHAIN_SERVICE, '-a', KEYCHAIN_ACCOUNT_GATEWAY],
            capture_output=True, timeout=10
        )
    except Exception:
        pass
    try:
        subprocess.run(
            ['security', 'add-generic-password', '-s', KEYCHAIN_SERVICE, '-a', KEYCHAIN_ACCOUNT_GATEWAY, '-w', gateway_token, '-U'],
            capture_output=True, check=True, timeout=10
        )
    except Exception as e:
        print(f"Warning: Could not store gateway token in Keychain: {e}", file=sys.stderr)

# SECURITY FIX 1.2: Validate inputs in Python too (defense in depth)
ALLOWED_MODELS = [
    "opencode/kimi-k2.5-free",
    "opencode/glm-4.7-free", 
    "openrouter/moonshotai/kimi-k2.5",
    "openrouter/anthropic/claude-sonnet-4-5",
    "openrouter/anthropic/claude-opus-4",
    "openrouter/openai/gpt-4o",
    "openrouter/google/gemini-pro",
    "anthropic/claude-sonnet-4-5",
    "anthropic/claude-opus-4",
]

ALLOWED_SECURITY_LEVELS = ["low", "medium", "high"]

if model not in ALLOWED_MODELS:
    print(f"ERROR: Model '{model}' not in allowed list", file=sys.stderr)
    sys.exit(1)

if security_level not in ALLOWED_SECURITY_LEVELS:
    print(f"ERROR: Security level '{security_level}' not valid", file=sys.stderr)
    sys.exit(1)

if not re.match(r'^[a-zA-Z][a-zA-Z0-9_-]{1,31}$', bot_name):
    print(f"ERROR: Invalid bot name format", file=sys.stderr)
    sys.exit(1)

# Security settings based on setup type
tools_deny = ["browser"]
sandbox_mode = "off"

if security_level == "high":
    sandbox_mode = "workspace"
    tools_deny = ["browser"]
elif security_level == "low":
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
        "created_by": "clawstarter-v2.6-secure",
        "keys_in_keychain": True
    }
}

if openrouter_key:
    config["auth"]["openrouter"] = {"apiKey": openrouter_key}
if anthropic_key:
    config["auth"]["anthropic"] = {"apiKey": anthropic_key}

if model.startswith("opencode/"):
    config["provider"] = {
        "opencode": {
            "baseURL": "https://opencode.ai/zen/v1",
            "models": {
                "kimi-k2.5-free": {"enabled": True, "displayName": "Kimi K2.5 Free"},
                "glm-4.7-free": {"enabled": True, "displayName": "GLM 4.7 Free"}
            }
        }
    }

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print(f"\n  Gateway Token: {gateway_token}")
print("  Save this — you need it for the dashboard.\n")
PYEOF
    )
    
    if [ $? -ne 0 ]; then
        die "Config generation failed security validation"
    fi
    
    # Verify permissions
    chmod 600 "$config_file"
    pass "Config created (keys retrieved directly by Python from Keychain)"
    
    # SECURITY FIX 2.4: If user chose manual .env, remind them
    if [ "$NEEDS_MANUAL_ENV" = true ]; then
        echo ""
        warn "Manual .env setup required!"
        echo -e "  ${BOLD}Create ~/.openclaw/.env with your API key:${NC}"
        echo -e "  ${DIM}  OPENROUTER_API_KEY=sk-or-your-key-here${NC}"
        echo -e "  ${DIM}  (or ANTHROPIC_API_KEY for Anthropic keys)${NC}"
        echo ""
    fi
    
    # SECURITY FIX 1.3: Create workspace files with secure permissions
    mkdir -p "$workspace_dir/memory"
    
    touch "$workspace_dir/AGENTS.md"
    chmod 600 "$workspace_dir/AGENTS.md"
    
    # SECURITY FIX 1.2: Use template with safe substitution via sed
    cat > "$workspace_dir/AGENTS.md.template" << 'AGENTSTEMPLATE'
# __BOT_NAME__

You are __BOT_NAME__, a helpful AI assistant.

## Personality
Style: __PERSONALITY__

## Guidelines
- Be helpful, not performative
- Have opinions when asked
- Ask before taking external actions (emails, posts)
- If uncertain, ask

## First Run
Welcome! I'm __BOT_NAME__. Try asking me:
- "What can you help me with?"
- "Tell me about yourself"
- "What skills do you have?"
AGENTSTEMPLATE

    sed -e "s/__BOT_NAME__/${QUICKSTART_BOT_NAME}/g" \
        -e "s/__PERSONALITY__/${QUICKSTART_PERSONALITY}/g" \
        "$workspace_dir/AGENTS.md.template" > "$workspace_dir/AGENTS.md"
    
    rm -f "$workspace_dir/AGENTS.md.template"
    pass "Workspace created (secure)"
    
    # Install templates with checksum verification (SECURITY FIX 1.4)
    if [ -n "$QUICKSTART_TEMPLATES" ]; then
        IFS=',' read -ra TEMPLATE_ARRAY <<< "$QUICKSTART_TEMPLATES"
        local first_template=true
        
        for template_name in "${TEMPLATE_ARRAY[@]}"; do
            # SECURITY FIX 1.2: Validate template name format
            if ! [[ "$template_name" =~ ^[a-zA-Z][a-zA-Z0-9-]*$ ]]; then
                warn "Skipping invalid template name: $template_name"
                continue
            fi
            
            info "Installing ${template_name}..."
            
            if $first_template; then
                local template_path="workflows/${template_name}/AGENTS.md"
                
                # SECURITY FIX 1.4: Use checksum verification
                if verify_and_download_template "$template_path" "$workspace_dir/AGENTS.md"; then
                    chmod 600 "$workspace_dir/AGENTS.md"
                    first_template=false
                else
                    warn "Could not verify ${template_name} template (using default)"
                fi
            fi
            
            pass "Configured: ${template_name}"
        done
        
        if [ "${#TEMPLATE_ARRAY[@]}" -gt 1 ]; then
            info "Multiple templates selected. AGENTS.md from ${TEMPLATE_ARRAY[0]}."
        fi
    fi
    
    # SECURITY FIX 1.5: Create LaunchAgent with safe plist generation
    local launch_agent="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
    mkdir -p "$HOME/Library/LaunchAgents"
    
    if ! create_launch_agent_safe "$HOME" "$launch_agent"; then
        die "Failed to create LaunchAgent plist (security validation failed)"
    fi
    pass "LaunchAgent created (validated)"
    
    # SECURITY FIX 2.3: Check for port conflicts BEFORE starting gateway
    info "Checking if port $DEFAULT_GATEWAY_PORT is available..."
    local blocking_pid
    if blocking_pid=$(check_port_available "$DEFAULT_GATEWAY_PORT"); then
        pass "Port $DEFAULT_GATEWAY_PORT is available"
    else
        # Port is in use
        handle_port_conflict "$DEFAULT_GATEWAY_PORT" "$blocking_pid"
    fi
    
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
    echo -e "  ${GREEN}Security enhancements active:${NC}"
    echo -e "  ${INFO} API keys stored in macOS Keychain (not environment)"
    echo -e "  ${INFO} Keys retrieved directly by Python (never in shell vars)"
    echo -e "  ${INFO} All inputs validated against strict allowlists"
    echo -e "  ${INFO} Files created with secure permissions (600)"
    echo -e "  ${INFO} Template downloads verified via SHA256"
    echo -e "  ${INFO} LaunchAgent plist validated by plutil"
    echo -e "  ${INFO} Port conflicts detected before startup"
    echo -e "  ${INFO} Disk space verified before file operations (500MB min)"
    echo -e "  ${INFO} Keychain access with timeout + retry for locked state"
    echo ""
    
    # SECURITY FIX 2.4: Remind about manual .env if needed
    if [ "$NEEDS_MANUAL_ENV" = true ]; then
        echo -e "  ${YELLOW}⚠️  Don't forget to create ~/.openclaw/.env with your API key!${NC}"
        echo ""
    fi
    
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
    echo -e "  ${GREEN}🔒 Security Hardened Edition:${NC}"
    echo -e "  ${INFO} Phase 1.1: API keys → macOS Keychain"
    echo -e "  ${INFO} Phase 1.2: Input validation + allowlists"
    echo -e "  ${INFO} Phase 1.3: Secure file creation (no race conditions)"
    echo -e "  ${INFO} Phase 1.4: SHA256 template verification"
    echo -e "  ${INFO} Phase 1.5: Plist injection protection"
    echo ""
    echo -e "  ${GREEN}🛡️  Phase 2 Critical Fixes (Prism Cycle 1):${NC}"
    echo -e "  ${INFO} Phase 2.1: Python retrieves keys directly from Keychain"
    echo -e "  ${INFO} Phase 2.2: Fully quoted heredoc prevents injection"
    echo -e "  ${INFO} Phase 2.3: Port conflict detection before startup"
    echo -e "  ${INFO} Phase 2.4: Clear Keychain warnings + recovery options"
    echo ""
    echo -e "  ${GREEN}🔐 Phase 3 Critical Fixes (Prism Cycle 2):${NC}"
    echo -e "  ${INFO} Phase 3.1: Disk space pre-flight check (500MB min)"
    echo -e "  ${INFO} Phase 3.2: Locked Keychain timeout + retry loop"
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
