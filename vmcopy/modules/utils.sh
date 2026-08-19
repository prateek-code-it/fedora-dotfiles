#!/usr/bin/env bash
# ==============================================================================
# Script: utils.sh
# Description: Core helper utilities, dependency checks, and logging engine.
# ==============================================================================

# Internal Tool Discovery Cache
declare -A TOOL_CACHE

# ------------------------------------------------------------------------------
# Function: utils_log
# Description: Writes formatted entry to system log.
# Arguments: $1 - Log Level (INFO, WARN, ERROR), $2 - Log Message
# ------------------------------------------------------------------------------
utils_log() {
  local level="${1:-INFO}"
  local message="${2:-}"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[${timestamp}] [${level}] ${message}" >>"${VMCOPY_LOG_DIR}/vmcopy.log"
}

# ------------------------------------------------------------------------------
# Function: utils_has_tool
# Description: Checks if a command exists, using a cached lookup.
# Arguments: $1 - Command name
# Returns: 0 if tool exists, 1 otherwise
# ------------------------------------------------------------------------------
utils_has_tool() {
  local cmd="$1"
  if [[ -n "${TOOL_CACHE[${cmd}]:-}" ]]; then
    return "${TOOL_CACHE[${cmd}]}"
  fi

  if command -v "${cmd}" >/dev/null 2>&1; then
    TOOL_CACHE["${cmd}"]=0
    return 0
  else
    TOOL_CACHE["${cmd}"]=1
    return 1
  fi
}

# ------------------------------------------------------------------------------
# Function: utils_check_dependencies
# Description: Validates system dependencies on execution.
# Returns: 0 on success, aborts on missing mandatory tools.
# ------------------------------------------------------------------------------
utils_check_dependencies() {
  local mandatory=("gum" "fzf" "bat" "rsync" "ssh" "scp" "find")
  local missing=()

  for cmd in "${mandatory[@]}"; do
    if ! utils_has_tool "${cmd}"; then
      missing+=("${cmd}")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    utils_log "ERROR" "Missing mandatory dependencies: ${missing[*]}"
    echo -e "\033[0;31m[CRITICAL ERROR] Missing required dependencies:\033[0m" >&2
    for item in "${missing[@]}"; do
      echo "  - ${item}" >&2
    done
    echo -e "\nPlease install missing tools using Fedora dnf:" >&2
    echo "  sudo dnf install ${missing[*]}" >&2
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# Function: utils_trigger_hook
# Description: Executes optional hook scripts in plugins directory.
# Arguments: $1 - Hook Event Name (e.g., pre-upload, post-download)
# ------------------------------------------------------------------------------
utils_trigger_hook() {
  local hook_name="$1"
  shift
  local hook_script="${VMCOPY_CONFIG_DIR}/hooks/${hook_name}.sh"

  if [[ -x "${hook_script}" ]]; then
    utils_log "INFO" "Executing hook: ${hook_name}"
    "${hook_script}" "$@" || utils_log "WARN" "Hook ${hook_name} returned non-zero exit code"
  fi
}
