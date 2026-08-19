#!/usr/bin/env bash
# ==============================================================================
# Script: ssh.sh
# Description: ControlMaster persistent SSH connection manager with password prompt.
# ==============================================================================

declare -A ACTIVE_SSH_SESSIONS

# ------------------------------------------------------------------------------
# Function: ssh_get_socket
# Description: Returns the control socket path for a VM key.
# ------------------------------------------------------------------------------
ssh_get_socket() {
  local vm_key="$1"
  echo "${SSH_CONTROL_DIR}/cm_${vm_key}.sock"
}

# ------------------------------------------------------------------------------
# Function: ssh_is_connected
# Description: Checks if an SSH ControlMaster multiplex socket is active.
# ------------------------------------------------------------------------------
ssh_is_connected() {
  local vm_key="$1"
  local socket
  socket=$(ssh_get_socket "${vm_key}")

  if [[ ! -S "${socket}" ]]; then
    return 1
  fi

  vm_get_by_key "${vm_key}"
  ssh -O check -S "${socket}" "${VM_USER}@${HOST}" -p "${VM_PORT}" >/dev/null 2>&1
}

# ------------------------------------------------------------------------------
# Function: ssh_connect
# Description: Single-step password authentication using ControlMaster persistence.
# ------------------------------------------------------------------------------
ssh_connect() {
  local vm_key="$1"

  if ssh_is_connected "${vm_key}"; then
    return 0
  fi

  vm_get_by_key "${vm_key}"
  local socket
  socket=$(ssh_get_socket "${vm_key}")

  mkdir -p "$(dirname "${socket}")"

  ui_msg_info "Opening persistent connection to ${VM_NAME} (${HOST}:${VM_PORT})..."

  # Single-step Password Prompt via gum
  local pass
  pass=$(gum input --password --placeholder "Enter password for ${VM_USER}@${VM_NAME}")

  if [[ -z "${pass}" ]]; then
    ui_msg_error "Password input canceled."
    return 1
  fi

  # Create temporary askpass file descriptor to pass raw password safely (supports special chars)
  local pass_file
  pass_file=$(mktemp "${VMCOPY_CACHE_DIR}/pass_XXXXXX")
  chmod 600 "${pass_file}"
  printf "%s" "${pass}" >"${pass_file}"

  local askpass_script
  askpass_script=$(mktemp "${VMCOPY_CACHE_DIR}/askpass_XXXXXX.sh")
  chmod 700 "${askpass_script}"

  cat <<EOF >"${askpass_script}"
#!/usr/bin/env bash
cat "${pass_file}"
EOF

  # Authenticate and spawn background ControlMaster socket
  DISPLAY="${DISPLAY:-:0}" \
    SSH_ASKPASS="${askpass_script}" \
    SSH_ASKPASS_REQUIRE="force" \
    ssh -M -S "${socket}" -fN \
    -o ExitOnForwardFailure=yes \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o PubkeyAuthentication=no \
    -p "${VM_PORT}" "${VM_USER}@${HOST}" </dev/null >/dev/null 2>&1 || true

  rm -f "${askpass_script}" "${pass_file}"

  # Verify session establishment
  if ssh_is_connected "${vm_key}"; then
    ACTIVE_SSH_SESSIONS["${vm_key}"]=1
    utils_log "INFO" "Opened persistent ControlMaster SSH connection to ${vm_key}"
    ui_msg_info "Successfully authenticated!"
    sleep 1
    return 0
  else
    rm -f "${socket}"
    utils_log "WARN" "Authentication failed for ${vm_key}"
    ui_msg_error "Authentication failed! Check password or VM SSH configuration."
    echo "Press Enter to return to menu..."
    read -r
    return 1
  fi
}

# ------------------------------------------------------------------------------
# Function: ssh_exec
# ------------------------------------------------------------------------------
ssh_exec() {
  local vm_key="$1"
  shift
  local socket
  socket=$(ssh_get_socket "${vm_key}")

  if ! ssh_is_connected "${vm_key}"; then
    ssh_connect "${vm_key}" || return 1
  fi

  vm_get_by_key "${vm_key}"
  ssh -S "${socket}" -p "${VM_PORT}" "${VM_USER}@${HOST}" "$@"
}

# ------------------------------------------------------------------------------
# Function: ssh_disconnect
# ------------------------------------------------------------------------------
ssh_disconnect() {
  local vm_key="$1"
  local socket
  socket=$(ssh_get_socket "${vm_key}")

  if [[ -S "${socket}" ]]; then
    vm_get_by_key "${vm_key}"
    ssh -O exit -S "${socket}" "${VM_USER}@${HOST}" -p "${VM_PORT}" >/dev/null 2>&1 || true
    rm -f "${socket}"
    unset "ACTIVE_SSH_SESSIONS[${vm_key}]"
    utils_log "INFO" "Closed SSH connection to ${vm_key}"
  fi
}

# ------------------------------------------------------------------------------
# Function: ssh_disconnect_all
# ------------------------------------------------------------------------------
ssh_disconnect_all() {
  for vm_key in "${!ACTIVE_SSH_SESSIONS[@]}"; do
    ssh_disconnect "${vm_key}"
  done
}
