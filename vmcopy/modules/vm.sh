#!/usr/bin/env bash
# ==============================================================================
# Script: vm.sh
# Description: Inventory manager and network latency dashboard checker.
# ==============================================================================

# Global exported variables populated on record lookup
export VM_KEY=""
export VM_NAME=""
export VM_USER=""
export VM_PORT=""
export VM_HOME=""

# Connection Profile Overrides
export VM_PROF_COMPRESSION=""
export VM_PROF_TIMEOUT=""
export VM_PROF_RSYNC_FLAGS=""

# ------------------------------------------------------------------------------
# Function: vm_validate_config
# Description: Parses and verifies structure of VMS array in config.sh.
# ------------------------------------------------------------------------------
vm_validate_config() {
  if [[ ${#VMS[@]} -eq 0 ]]; then
    utils_log "ERROR" "No Virtual Machines defined in VMS array."
    ui_msg_error "No Virtual Machines configured in config.sh."
    exit 1
  fi

  for entry in "${VMS[@]}"; do
    IFS='|' read -r k n u p h <<<"${entry}"
    if [[ -z "${k}" || -z "${n}" || -z "${u}" || -z "${p}" || -z "${h}" ]]; then
      utils_log "ERROR" "Malformed VM definition: ${entry}"
      ui_msg_error "Malformed configuration entry: ${entry}"
      exit 1
    fi
  done
}

# ------------------------------------------------------------------------------
# Function: vm_get_by_key
# Description: Sets active global VM metrics for given inventory key.
# Arguments: $1 - VM Key
# ------------------------------------------------------------------------------
vm_get_by_key() {
  local target_key="$1"
  for entry in "${VMS[@]}"; do
    IFS='|' read -r k n u p h <<<"${entry}"
    if [[ "${k}" == "${target_key}" ]]; then
      VM_KEY="${k}"
      VM_NAME="${n}"
      VM_USER="${u}"
      VM_PORT="${p}"
      VM_HOME="${h}"

      # Load Connection Profile Overrides
      local prof_var="PROFILE_${k}"
      if [[ -n "${!prof_var:-}" ]]; then
        IFS='|' read -r c t r <<<"${!prof_var}"
        VM_PROF_COMPRESSION="${c}"
        VM_PROF_TIMEOUT="${t}"
        VM_PROF_RSYNC_FLAGS="${r}"
      else
        VM_PROF_COMPRESSION="${DEFAULT_COMPRESSION}"
        VM_PROF_TIMEOUT="${DEFAULT_CACHE_TIMEOUT}"
        VM_PROF_RSYNC_FLAGS=""
      fi
      return 0
    fi
  done

  utils_log "ERROR" "Requested non-existent VM key: ${target_key}"
  return 1
}

# ------------------------------------------------------------------------------
# Function: vm_check_status
# Description: Tests TCP connection readiness and calculates network latency.
# Arguments: $1 - SSH Port
# Output: Returns formatted status string
# ------------------------------------------------------------------------------
vm_check_status() {
  local port="$1"
  local start_time end_time latency

  start_time=$(date +%s%3N)
  if nc -z -w 1 "${HOST}" "${port}" >/dev/null 2>&1; then
    end_time=$(date +%s%3N)
    latency=$((end_time - start_time))
    echo "🟢 Online (${latency}ms)"
  else
    echo "🔴 Offline"
  fi
}
