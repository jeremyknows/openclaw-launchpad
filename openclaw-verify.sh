#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# OpenClaw Setup Verification Script
# Run this after completing the Setup Guide to confirm everything works.
# Usage: bash openclaw-verify.sh
# Also called as the final step of openclaw-autosetup.sh
# ═══════════════════════════════════════════════════════════════════

# ─── Colors & Symbols ───
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

PASS="${GREEN}✓${NC}"
FAIL="${RED}✗${NC}"
WARN="${YELLOW}!${NC}"
INFO="${CYAN}→${NC}"

pass_count=0
fail_count=0
warn_count=0

pass()  { echo -e "  ${PASS} $1"; pass_count=$((pass_count + 1)); }
fail()  { echo -e "  ${FAIL} $1"; fail_count=$((fail_count + 1)); }
warn()  { echo -e "  ${WARN} $1"; warn_count=$((warn_count + 1)); }
info()  { echo -e "  ${INFO} $1"; }
header(){ echo ""; echo -e "${BOLD}$1${NC}"; echo "  ────────────────────────────────────"; }

# ═══════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  OpenClaw Setup Verification${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "  Running as: ${CYAN}$(whoami)${NC} on $(hostname)"
echo -e "  Date: $(date '+%Y-%m-%d %H:%M')"

# ═══════════════════════════════════════════════════════════════════
header "1. macOS User Isolation"

CURRENT_USER=$(whoami)
CURRENT_HOME="$HOME"

# Check if running as a non-admin user
if dscl . -read /Groups/admin GroupMembership 2>/dev/null | grep -qw "$CURRENT_USER"; then
  warn "Running as admin user '${CURRENT_USER}' — a dedicated Standard user is recommended"
else
  pass "Running as non-admin user '${CURRENT_USER}'"
fi

# Check home directory permissions
HOME_PERMS=$(stat -f "%Lp" "$CURRENT_HOME" 2>/dev/null || echo "unknown")
if [ "$HOME_PERMS" = "700" ]; then
  pass "Home directory permissions: 700 (locked down)"
elif [ "$HOME_PERMS" = "755" ]; then
  fail "Home directory permissions: 755 (default — other users can read your files)"
  info "Fix: chmod 700 $CURRENT_HOME"
else
  warn "Home directory permissions: ${HOME_PERMS} (expected 700)"
fi

# ═══════════════════════════════════════════════════════════════════
header "2. Node.js"

if command -v node &>/dev/null; then
  NODE_VERSION=$(node --version 2>/dev/null)
  NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/v//' | cut -d. -f1)
  if [ "$NODE_MAJOR" -ge 22 ] 2>/dev/null; then
    pass "Node.js ${NODE_VERSION} (meets v22+ requirement)"
  else
    fail "Node.js ${NODE_VERSION} (need v22+)"
    info "Fix: brew install node@22"
  fi
  info "Path: $(which node)"
else
  fail "Node.js not found"
  info "Fix: brew install node@22"
fi

if command -v npm &>/dev/null; then
  pass "npm $(npm --version 2>/dev/null)"
else
  warn "npm not found"
fi

# ═══════════════════════════════════════════════════════════════════
header "3. OpenClaw Installation"

if command -v openclaw &>/dev/null; then
  OC_VERSION=$(openclaw --version 2>/dev/null | head -1)
  pass "OpenClaw installed: ${OC_VERSION}"
  info "Path: $(which openclaw)"

  # Parse version number (expecting format like "2026.x.y" or "OpenClaw 2026.x.y")
  VERSION_NUM=$(echo "$OC_VERSION" | grep -oE '[0-9]{4}\.[0-9]+\.[0-9]+' | head -1)
  if [ -n "$VERSION_NUM" ]; then
    YEAR=$(echo "$VERSION_NUM" | cut -d. -f1)
    MINOR=$(echo "$VERSION_NUM" | cut -d. -f2)
    PATCH=$(echo "$VERSION_NUM" | cut -d. -f3)

    # Check minimum: 2026.1.29
    if [ "$YEAR" -gt 2026 ] || ([ "$YEAR" -eq 2026 ] && [ "$MINOR" -gt 1 ]) || \
       ([ "$YEAR" -eq 2026 ] && [ "$MINOR" -eq 1 ] && [ "$PATCH" -ge 29 ]); then
      pass "Version ${VERSION_NUM} meets minimum (2026.1.29) — CVE-2026-25253 and CVE-2026-25157 patched"
    else
      fail "Version ${VERSION_NUM} is BELOW minimum 2026.1.29 — SECURITY RISK"
      info "Fix: openclaw update"
    fi

    # Check recommended: 2026.2.9
    if [ "$YEAR" -gt 2026 ] || ([ "$YEAR" -eq 2026 ] && [ "$MINOR" -gt 2 ]) || \
       ([ "$YEAR" -eq 2026 ] && [ "$MINOR" -eq 2 ] && [ "$PATCH" -ge 9 ]); then
      pass "Version ${VERSION_NUM} meets recommended (2026.2.9+)"
    else
      warn "Version ${VERSION_NUM} is below recommended 2026.2.9+ — consider: openclaw update"
    fi
  else
    warn "Could not parse version number from: ${OC_VERSION}"
  fi
else
  fail "OpenClaw not found"
  info "Fix: curl -fsSL https://openclaw.ai/install.sh | bash"
fi

# ═══════════════════════════════════════════════════════════════════
header "4. Configuration"

CONFIG_FILE="$HOME/.openclaw/openclaw.json"
if [ -f "$CONFIG_FILE" ]; then
  pass "Config file exists: ${CONFIG_FILE}"

  # Check if it's valid JSON
  if python3 -c "import json; json.load(open('$CONFIG_FILE'))" 2>/dev/null; then
    pass "Config is valid JSON"
  else
    fail "Config is NOT valid JSON — openclaw doctor will show details"
  fi

  # Check file permissions
  CONFIG_PERMS=$(stat -f "%Lp" "$CONFIG_FILE" 2>/dev/null || echo "unknown")
  if [ "$CONFIG_PERMS" = "600" ] || [ "$CONFIG_PERMS" = "640" ]; then
    pass "Config file permissions: ${CONFIG_PERMS} (restricted)"
  elif [ "$CONFIG_PERMS" = "644" ] || [ "$CONFIG_PERMS" = "755" ]; then
    warn "Config file permissions: ${CONFIG_PERMS} — contains API keys, consider: chmod 600 ${CONFIG_FILE}"
  else
    info "Config file permissions: ${CONFIG_PERMS}"
  fi

  # Check for API keys (without revealing them)
  if python3 -c "
import json, sys
try:
    with open('$CONFIG_FILE') as f:
        config = json.load(f)
    # Check for auth/provider configs
    auth = config.get('auth', config.get('providers', {}))
    if auth:
        print('HAS_AUTH')
    else:
        print('NO_AUTH')
except Exception as e:
    print('ERROR: ' + str(e))
" 2>/dev/null | grep -q "HAS_AUTH"; then
    pass "API provider configuration found"
  else
    warn "No API provider configuration detected in config"
  fi
else
  fail "Config file not found: ${CONFIG_FILE}"
  info "Fix: openclaw onboard --install-daemon"
fi

# Check workspace directory
WORKSPACE="$HOME/.openclaw/workspace"
if [ -d "$WORKSPACE" ]; then
  pass "Workspace directory exists: ${WORKSPACE}"
else
  warn "Workspace directory not found: ${WORKSPACE}"
fi

# Check auth profiles
AUTH_PROFILES="$HOME/.openclaw/agents/main/agent/auth-profiles.json"
if [ -f "$AUTH_PROFILES" ]; then
  pass "Auth profiles file exists"
else
  warn "Auth profiles not found (may be created on first agent run)"
fi

# ═══════════════════════════════════════════════════════════════════
header "5. Gateway"

# Check LaunchAgent
LAUNCH_AGENT="$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
if [ -f "$LAUNCH_AGENT" ]; then
  pass "LaunchAgent plist exists"
else
  fail "LaunchAgent plist not found: ${LAUNCH_AGENT}"
  info "Fix: openclaw onboard --install-daemon"
fi

# Check if gateway is loaded
if launchctl list 2>/dev/null | grep -q "openclaw"; then
  pass "Gateway LaunchAgent is loaded"
else
  fail "Gateway LaunchAgent is not loaded"
  info "Fix: launchctl load ${LAUNCH_AGENT}"
fi

# Check if gateway process is running
if pgrep -f "openclaw" &>/dev/null; then
  GATEWAY_PID=$(pgrep -f "openclaw" | head -1)
  pass "Gateway process running (PID: ${GATEWAY_PID})"
else
  fail "No OpenClaw gateway process found"
  info "Fix: openclaw gateway start"
fi

# Check gateway port
if lsof -i :18789 -sTCP:LISTEN &>/dev/null; then
  pass "Gateway listening on port 18789"
else
  warn "Nothing listening on port 18789 (default gateway port)"
fi

# Try health endpoint
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18789/ 2>/dev/null | grep -qE "^(200|301|302)"; then
  pass "Gateway HTTP endpoint responding"
else
  warn "Gateway HTTP endpoint not responding on localhost:18789"
fi

# Run openclaw gateway status if available
if command -v openclaw &>/dev/null; then
  GW_STATUS=$(openclaw gateway status 2>&1 || true)
  if echo "$GW_STATUS" | grep -qi "running"; then
    pass "openclaw gateway status: running"
  elif echo "$GW_STATUS" | grep -qi "stopped\|not running"; then
    fail "openclaw gateway status: not running"
  else
    info "openclaw gateway status: $(echo "$GW_STATUS" | head -1)"
  fi
fi

# ═══════════════════════════════════════════════════════════════════
header "6. Discord Bot"

if [ -f "$CONFIG_FILE" ]; then
  HAS_DISCORD=$(python3 -c "
import json
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
" 2>/dev/null || echo "ERROR")

  case "$HAS_DISCORD" in
    ENABLED)
      pass "Discord channel is enabled in config"
      ;;
    CONFIGURED)
      warn "Discord is configured but may not be enabled"
      ;;
    NOT_CONFIGURED)
      info "Discord not configured (optional — skip if using dashboard only)"
      ;;
    *)
      info "Could not check Discord config"
      ;;
  esac
else
  info "Skipping Discord check (no config file)"
fi

# ═══════════════════════════════════════════════════════════════════
header "7. Mac Sleep Prevention"

SLEEP_VAL=$(pmset -g 2>/dev/null | grep -E "^ sleep" | awk '{print $2}' || echo "unknown")
if [ "$SLEEP_VAL" = "0" ]; then
  pass "System sleep disabled (sleep = 0)"
else
  warn "System sleep is set to ${SLEEP_VAL} — should be 0 for always-on operation"
  info "Fix: sudo pmset -a sleep 0 standby 0 hibernatemode 0 powernap 0 displaysleep 15 disksleep 0"
fi

DISPLAY_SLEEP=$(pmset -g 2>/dev/null | grep "displaysleep" | awk '{print $2}' || echo "unknown")
if [ "$DISPLAY_SLEEP" != "unknown" ]; then
  info "Display sleep: ${DISPLAY_SLEEP} minutes (display can sleep without affecting the gateway)"
fi

# Check auto-update setting
AUTO_UPDATE=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates 2>/dev/null || echo "not set")
if [ "$AUTO_UPDATE" = "0" ]; then
  pass "Automatic macOS update restarts disabled"
elif [ "$AUTO_UPDATE" = "1" ]; then
  warn "Automatic macOS update restarts are ON — updates may restart your Mac"
  info "Fix: sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool FALSE"
else
  info "Auto-update restart setting: ${AUTO_UPDATE}"
fi

# ═══════════════════════════════════════════════════════════════════
header "8. openclaw doctor"

if command -v openclaw &>/dev/null; then
  DOCTOR_OUTPUT=$(openclaw doctor 2>&1 || true)
  DOCTOR_EXIT=$?

  # Filter out Node.js deprecation warnings (not actual doctor errors)
  DOCTOR_FILTERED=$(echo "$DOCTOR_OUTPUT" | grep -v "DeprecationWarning" | grep -v "trace-deprecation")
  if echo "$DOCTOR_FILTERED" | grep -qiE "Errors: [1-9]|critical|FAIL"; then
    fail "openclaw doctor reports issues:"
    echo "$DOCTOR_FILTERED" | grep -iE "error|critical|fail|warn" | grep -v "Errors: 0" | head -5 | while read -r line; do
      info "$line"
    done
  elif [ $DOCTOR_EXIT -eq 0 ]; then
    pass "openclaw doctor: all checks passed"
  else
    warn "openclaw doctor exited with code ${DOCTOR_EXIT}"
    echo "$DOCTOR_OUTPUT" | head -5 | while read -r line; do
      info "$line"
    done
  fi
else
  fail "Cannot run openclaw doctor (openclaw not found)"
fi

# ═══════════════════════════════════════════════════════════════════
header "9. Log Files"

LOG_DIR="/tmp/openclaw"
TODAY_LOG="${LOG_DIR}/openclaw-$(date +%Y-%m-%d).log"

if [ -d "$LOG_DIR" ]; then
  pass "Log directory exists: ${LOG_DIR}"
  if [ -f "$TODAY_LOG" ]; then
    LOG_SIZE=$(wc -c < "$TODAY_LOG" | tr -d ' ')
    pass "Today's log file exists (${LOG_SIZE} bytes)"

    # Check for recent errors in the log
    RECENT_ERRORS=$(tail -100 "$TODAY_LOG" 2>/dev/null | grep -ci "error\|exception\|fatal" || true)
    if [ "$RECENT_ERRORS" -gt 0 ]; then
      warn "${RECENT_ERRORS} error(s) in recent log entries"
      info "Review: tail -50 ${TODAY_LOG}"
    else
      pass "No errors in recent log entries"
    fi
  else
    info "No log file for today yet"
  fi
else
  warn "Log directory not found: ${LOG_DIR}"
fi

# Secondary log location
if [ -d "$HOME/.openclaw/logs" ]; then
  info "Secondary log dir exists: ~/.openclaw/logs/"
fi

# ═══════════════════════════════════════════════════════════════════
header "10. Access Profile & Approval Tier"

if [ -f "$CONFIG_FILE" ]; then
  ACCESS_PROFILE=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    config = json.load(f)
agents = config.get('agents', {})
defaults = agents.get('defaults', {})
sandbox = defaults.get('sandbox', {})
tools = defaults.get('tools', {})
deny = tools.get('deny', [])
mode = sandbox.get('mode', 'not set')
ws = sandbox.get('workspaceAccess', 'not set')
if 'exec' in deny and 'browser' in deny:
    print('RESTRICTED')
elif 'exec' in deny:
    print('GUARDED')
elif mode != 'not set' or ws != 'not set':
    print('EXPLORER')
else:
    print('NOT_SET')
" 2>/dev/null || echo "ERROR")

  case "$ACCESS_PROFILE" in
    EXPLORER)
      pass "Access profile: Explorer (all tools enabled)"
      ;;
    GUARDED)
      pass "Access profile: Guarded (shell commands blocked)"
      ;;
    RESTRICTED)
      pass "Access profile: Restricted (messaging and memory only)"
      ;;
    NOT_SET)
      warn "No access profile configured — consider setting one in openclaw.json"
      info "Profiles: Explorer (default), Guarded, Restricted"
      ;;
    *)
      info "Could not determine access profile"
      ;;
  esac

  # Check approval tier (look for approval/autonomy settings)
  APPROVAL_CONFIG=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    config = json.load(f)
agents = config.get('agents', {})
defaults = agents.get('defaults', {})
approval = defaults.get('approval', defaults.get('autonomy', {}))
if approval:
    print('CONFIGURED')
else:
    print('NOT_SET')
" 2>/dev/null || echo "ERROR")

  case "$APPROVAL_CONFIG" in
    CONFIGURED)
      pass "Approval/autonomy tier is configured"
      ;;
    NOT_SET)
      info "No explicit approval tier set (all actions may require manual approval by default)"
      ;;
    *)
      info "Could not check approval tier"
      ;;
  esac
else
  info "Skipping access profile check (no config file)"
fi

# ═══════════════════════════════════════════════════════════════════
header "11. Spending Limit Reminder"

echo -e "  ${INFO} Verify spending limits are set on your API provider accounts:"
echo -e "  ${INFO}   OpenRouter: openrouter.ai/settings"
echo -e "  ${INFO}   Anthropic: console.anthropic.com → Billing → Limits"
echo -e "  ${INFO}   OpenAI: platform.openai.com → Billing → Usage limits"
warn "Spending limits cannot be verified automatically — please check manually"

# ═══════════════════════════════════════════════════════════════════
header "12. Security Quick Check"

# Check for exposed API keys in common locations
EXPOSED_KEYS=$(grep -rEl "sk-ant-|sk-or-|pa-[A-Za-z0-9]" \
  "$HOME/Desktop" "$HOME/Documents" "$HOME/Downloads" \
  --include="*.md" --include="*.txt" --include="*.env" \
  --include="*.sh" --include="*.yaml" --include="*.toml" \
  2>/dev/null | grep -v "openclaw-verify.sh" | grep -v "OPENCLAW-" | head -5 || true)

if [ -n "$EXPOSED_KEYS" ]; then
  warn "Possible API keys found in non-config files:"
  echo "$EXPOSED_KEYS" | while read -r f; do
    info "  $f"
  done
else
  pass "No API keys found outside of OpenClaw config"
fi

# Check .zshrc / .bashrc for exposed keys
for rc_file in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.zprofile" "$HOME/.bash_profile"; do
  if [ -f "$rc_file" ] && grep -qE "sk-ant-|sk-or-|pa-[A-Za-z0-9]{10}" "$rc_file" 2>/dev/null; then
    warn "Possible API key in ${rc_file}"
  fi
done

# ═══════════════════════════════════════════════════════════════════
header "13. TCC Permissions"

check_tcc_permissions() {
  # Only meaningful for bot (non-admin) users
  if dscl . -read /Groups/admin GroupMembership 2>/dev/null | grep -qw "$CURRENT_USER"; then
    info "Running as admin user — TCC check is for bot (non-admin) accounts"
    return
  fi

  local tcc_system="/Library/Application Support/com.apple.TCC/TCC.db"
  local tcc_user="$HOME/Library/Application Support/com.apple.TCC/TCC.db"
  local grants_found=0
  local services="kTCCServiceAccessibility kTCCServiceScreenCapture kTCCServiceSystemPolicyAllFiles"

  for db in "$tcc_system" "$tcc_user"; do
    if [ -f "$db" ]; then
      for svc in $services; do
        local count
        count=$(sqlite3 "$db" "SELECT COUNT(*) FROM access WHERE service='$svc' AND auth_value=2;" 2>/dev/null || echo "0")
        if [ "$count" -gt 0 ] 2>/dev/null; then
          local label
          case "$svc" in
            kTCCServiceAccessibility)       label="Accessibility" ;;
            kTCCServiceScreenCapture)       label="Screen Recording" ;;
            kTCCServiceSystemPolicyAllFiles) label="Full Disk Access" ;;
          esac
          warn "TCC grant found: ${label} (${count} entry/entries in $(basename "$db"))"
          grants_found=$((grants_found + 1))
        fi
      done
    fi
  done

  if [ "$grants_found" -eq 0 ]; then
    pass "No unexpected TCC grants for user '${CURRENT_USER}'"
  else
    info "Full Disk Access may be intentional (e.g. iMessage integration)"
  fi
}

check_tcc_permissions

# ═══════════════════════════════════════════════════════════════════
header "14. Memory Search"

check_memory_search() {
  if [ ! -f "$CONFIG_FILE" ]; then
    info "Skipping memory search check (no config file)"
    return
  fi

  local mem_result
  mem_result=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    config = json.load(f)
agents = config.get('agents', {})
defaults = agents.get('defaults', {})
mem = defaults.get('memorySearch', {})
enabled = mem.get('enabled', False)
provider = mem.get('provider', '')
if enabled and provider:
    print('ENABLED:' + provider)
elif provider:
    print('DISABLED:' + provider)
else:
    print('NOT_CONFIGURED')
" 2>/dev/null || echo "ERROR")

  case "$mem_result" in
    ENABLED:*)
      local provider="${mem_result#ENABLED:}"
      pass "Memory search: enabled (provider: ${provider})"
      # Validate API key prefix for Voyage AI
      if echo "$provider" | grep -qi "voyage"; then
        local has_key
        has_key=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    config = json.load(f)
key = config.get('providers', {}).get('voyage', {}).get('apiKey', '')
if not key:
    key = config.get('auth', {}).get('voyage', {}).get('apiKey', '')
if key.startswith('pa-'):
    print('VALID_PREFIX')
elif key:
    print('BAD_PREFIX')
else:
    print('NO_KEY')
" 2>/dev/null || echo "ERROR")
        case "$has_key" in
          VALID_PREFIX) pass "Voyage AI key prefix looks correct (pa-...)" ;;
          BAD_PREFIX)   warn "Voyage AI key does not start with expected prefix 'pa-'" ;;
          NO_KEY)       warn "Voyage AI provider set but no API key found in config" ;;
        esac
      fi
      ;;
    DISABLED:*)
      local provider="${mem_result#DISABLED:}"
      warn "Memory search provider set (${provider}) but not enabled"
      info "Enable it in openclaw.json: agents.defaults.memorySearch.enabled = true"
      ;;
    NOT_CONFIGURED)
      info "Memory search not configured (optional — improves agent recall)"
      info "Recommended: enable Voyage AI in openclaw.json → agents.defaults.memorySearch"
      ;;
    *)
      info "Could not check memory search config"
      ;;
  esac
}

check_memory_search

# ═══════════════════════════════════════════════════════════════════
header "15. API Connectivity"

check_api_connectivity() {
  # OpenRouter reachability
  local or_status
  or_status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 https://openrouter.ai/api/v1/models 2>/dev/null || echo "000")
  if [ "$or_status" = "200" ]; then
    pass "OpenRouter API reachable (HTTP ${or_status})"
  else
    warn "OpenRouter API not reachable (HTTP ${or_status}) — may be a transient issue"
  fi

  # Discord token check (only if configured)
  if [ -f "$CONFIG_FILE" ]; then
    local discord_token
    discord_token=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    config = json.load(f)
channels = config.get('channels', {})
discord = channels.get('discord', config.get('discord', {}))
token = discord.get('token', discord.get('botToken', ''))
if token:
    print(token)
" 2>/dev/null || echo "")

    if [ -n "$discord_token" ]; then
      local discord_resp
      discord_resp=$(curl -s --max-time 5 -H "Authorization: Bot ${discord_token}" https://discord.com/api/v10/users/@me 2>/dev/null || echo "")
      if echo "$discord_resp" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null | grep -qE "^[0-9]+$"; then
        pass "Discord bot token is valid"
      else
        warn "Discord bot token may be invalid or expired"
      fi
    else
      info "No Discord bot token configured — skipping Discord connectivity check"
    fi
  fi
}

check_api_connectivity

# ═══════════════════════════════════════════════════════════════════
header "16. Docker Sandbox"

check_docker_sandbox() {
  if [ ! -f "$CONFIG_FILE" ]; then
    info "Skipping Docker sandbox check (no config file)"
    return
  fi

  local sandbox_mode
  sandbox_mode=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    config = json.load(f)
agents = config.get('agents', {})
defaults = agents.get('defaults', {})
sandbox = defaults.get('sandbox', {})
mode = sandbox.get('mode', 'off')
print(mode)
" 2>/dev/null || echo "unknown")

  case "$sandbox_mode" in
    non-main|all)
      pass "Sandbox mode: ${sandbox_mode}"
      if command -v docker &>/dev/null; then
        pass "Docker is installed: $(docker --version 2>/dev/null | head -1)"
        if docker ps &>/dev/null; then
          pass "Docker daemon is running"
        else
          warn "Docker is installed but daemon is not running"
          info "Fix: open -a Docker (or start Docker Desktop)"
        fi
      else
        warn "Sandbox mode '${sandbox_mode}' requires Docker, but Docker is not installed"
        info "Fix: brew install --cask docker"
      fi
      ;;
    off|"")
      info "Sandbox: off (no Docker required)"
      ;;
    *)
      info "Sandbox mode: ${sandbox_mode}"
      ;;
  esac
}

check_docker_sandbox

# ═══════════════════════════════════════════════════════════════════
header "17. Workspace Templates"

check_workspace_templates() {
  local template_dir="$HOME/.openclaw/workspace"
  local expected_files="AGENTS.md BOOTSTRAP.md HEARTBEAT.md IDENTITY.md MEMORY.md SOUL.md USER.md"
  local total=7
  local found=0
  local missing=""

  if [ ! -d "$template_dir" ]; then
    warn "Workspace directory not found: ${template_dir}"
    info "Templates will be created on first agent run"
    return
  fi

  for f in $expected_files; do
    if [ -s "${template_dir}/${f}" ]; then
      found=$((found + 1))
    else
      if [ -z "$missing" ]; then
        missing="$f"
      else
        missing="${missing}, $f"
      fi
    fi
  done

  if [ "$found" -eq "$total" ]; then
    pass "Workspace templates: ${found}/${total} present"
  else
    warn "Workspace templates: ${found}/${total} present"
    info "Missing or empty: ${missing}"
  fi
}

check_workspace_templates

# ═══════════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  Results${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${GREEN}${pass_count} passed${NC}  ${RED}${fail_count} failed${NC}  ${YELLOW}${warn_count} warnings${NC}"
echo ""

if [ "$fail_count" -eq 0 ] && [ "$warn_count" -eq 0 ]; then
  echo -e "  ${GREEN}${BOLD}PERFECT SETUP!${NC} Everything looks great."
  echo -e "  You're ready for the Foundation Playbook."
elif [ "$fail_count" -eq 0 ]; then
  echo -e "  ${GREEN}${BOLD}SETUP COMPLETE${NC} with ${warn_count} warning(s)."
  echo -e "  Warnings are non-blocking but worth addressing."
  echo -e "  You can proceed to the Foundation Playbook."
elif [ "$fail_count" -le 2 ]; then
  echo -e "  ${YELLOW}${BOLD}ALMOST THERE${NC} — ${fail_count} issue(s) to fix."
  echo -e "  Address the failures above, then re-run this script."
else
  echo -e "  ${RED}${BOLD}NEEDS WORK${NC} — ${fail_count} failures found."
  echo -e "  Review the guide and fix the issues above."
fi

echo ""
echo -e "  Re-run anytime: ${CYAN}bash ~/Downloads/openclaw-verify.sh${NC}"
echo ""
