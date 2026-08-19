#!/usr/bin/env bash
# ==============================================================================
# Script: cache.sh
# Description: Remote file index and directory tree caching system with auto-ttl.
# ==============================================================================

# ------------------------------------------------------------------------------
# Function: cache_get_key
# Description: Generates a filesystem safe cache path for remote target.
# Arguments: $1 - VM Key, $2 - Remote Path
# ------------------------------------------------------------------------------
cache_get_key() {
  local vm_key="$1"
  local remote_path="$2"
  local safe_path
  safe_path=$(echo "${remote_path}" | tr '/' '_')
  echo "${VMCOPY_CACHE_DIR}/${vm_key}_${safe_path}.cache"
}

# ------------------------------------------------------------------------------
# Function: cache_is_valid
# Description: Evaluates if cached data exists and is within timeout limits.
# Arguments: $1 - Cache File, $2 - Timeout Seconds
# Returns: 0 if valid, 1 if expired/missing
# ------------------------------------------------------------------------------
cache_is_valid() {
  local cache_file="$1"
  local timeout="${2:-${DEFAULT_CACHE_TIMEOUT:-30}}"

  if [[ ! -f "${cache_file}" ]]; then
    return 1
  fi

  local last_mod current_time age
  last_mod=$(stat -c %Y "${cache_file}" 2>/dev/null || stat -f %m "${cache_file}")
  current_time=$(date +%s)
  age=$((current_time - last_mod))

  if ((age < timeout)); then
    return 0
  else
    return 1
  fi
}

# ------------------------------------------------------------------------------
# Function: cache_write
# Description: Writes content to specified cache target.
# Arguments: $1 - Cache File Path, Data via STDIN
# ------------------------------------------------------------------------------
cache_write() {
  local cache_file="$1"
  cat >"${cache_file}"
}

# ------------------------------------------------------------------------------
# Function: cache_clear
# Description: Flushes cached file list items for a specific VM or all VMs.
# Arguments: $1 - (Optional) VM Key
# ------------------------------------------------------------------------------
cache_clear() {
  local vm_key="${1:-}"
  if [[ -n "${vm_key}" ]]; then
    rm -f "${VMCOPY_CACHE_DIR}/${vm_key}_"*.cache
    utils_log "INFO" "Cleared cache for VM: ${vm_key}"
  else
    rm -f "${VMCOPY_CACHE_DIR}/"*.cache
    utils_log "INFO" "Cleared all remote directory caches"
  fi
}
