#!/usr/bin/env bash
# ==============================================================================
# Script: transfer.sh
# Description: Production rsync upload, download, and VM-to-VM direct sync pipeline.
# ==============================================================================

# ------------------------------------------------------------------------------
# Function: transfer_upload
# ------------------------------------------------------------------------------
transfer_upload() {
  local vm_key="$1"
  local local_src="${2:-}"
  local remote_dst="${3:-}"

  vm_get_by_key "${vm_key}"

  if ! ssh_is_connected "${vm_key}"; then
    ssh_connect "${vm_key}" || return 1
  fi

  if [[ -z "${local_src}" ]]; then
    local_src=$(browser_local "${HOME}")
  fi

  if [[ -z "${local_src}" || ! -e "${local_src}" ]]; then
    ui_msg_error "Invalid or empty local source path."
    sleep 1
    return 1
  fi

  if [[ -z "${remote_dst}" ]]; then
    remote_dst="${VM_HOME}"
  fi

  if ui_msg_confirm "Upload '${local_src}' to ${VM_NAME}:'${remote_dst}'?"; then
    local socket
    socket=$(ssh_get_socket "${vm_key}")

    utils_trigger_hook "pre-upload" "${vm_key}" "${local_src}" "${remote_dst}"

    local start_time
    start_time=$(date +%s)

    local compress_flag=""
    if [[ "${VM_PROF_COMPRESSION}" == "true" ]]; then
      compress_flag="-z"
    fi

    ui_msg_info "Executing upload via rsync..."

    rsync -avz --progress --partial ${compress_flag} ${VM_PROF_RSYNC_FLAGS} \
      -e "ssh -S '${socket}' -p ${VM_PORT}" \
      "${local_src}" "${VM_USER}@${HOST}:${remote_dst}"

    local end_time duration bytes_size
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    bytes_size=$(du -sh "${local_src}" | cut -f1)

    history_log "UPLOAD" "${vm_key}" "${local_src}" "${remote_dst}" "${bytes_size}" "${duration}"
    cache_clear "${vm_key}"

    utils_trigger_hook "post-upload" "${vm_key}" "${local_src}" "${remote_dst}"
    ui_msg_info "Upload completed successfully!"
    sleep 2
  fi
}

# ------------------------------------------------------------------------------
# Function: transfer_download
# ------------------------------------------------------------------------------
transfer_download() {
  local vm_key="$1"
  local remote_src="${2:-}"
  local local_dst="${3:-}"

  vm_get_by_key "${vm_key}"

  if ! ssh_is_connected "${vm_key}"; then
    ssh_connect "${vm_key}" || return 1
  fi

  if [[ -z "${remote_src}" ]]; then
    remote_src=$(browser_remote "${vm_key}" "${VM_HOME}")
  fi

  if [[ -z "${remote_src}" ]]; then
    ui_msg_error "Invalid or empty remote source path."
    sleep 1
    return 1
  fi

  if [[ -z "${local_dst}" ]]; then
    local_dst="${HOME}/Downloads"
    mkdir -p "${local_dst}"
  fi

  if ui_msg_confirm "Download ${VM_NAME}:'${remote_src}' to '${local_dst}'?"; then
    local socket
    socket=$(ssh_get_socket "${vm_key}")

    utils_trigger_hook "pre-download" "${vm_key}" "${remote_src}" "${local_dst}"

    local start_time
    start_time=$(date +%s)

    local compress_flag=""
    if [[ "${VM_PROF_COMPRESSION}" == "true" ]]; then
      compress_flag="-z"
    fi

    ui_msg_info "Executing download via rsync..."

    rsync -avz --progress --partial ${compress_flag} ${VM_PROF_RSYNC_FLAGS} \
      -e "ssh -S '${socket}' -p ${VM_PORT}" \
      "${VM_USER}@${HOST}:${remote_src}" "${local_dst}"

    local end_time duration bytes_size
    end_time=$(date +%s)
    duration=$((end_time - start_time))

    local downloaded_file_name
    downloaded_file_name=$(basename "${remote_src}")
    bytes_size=$(du -sh "${local_dst}/${downloaded_file_name}" 2>/dev/null | cut -f1 || echo "Unknown")

    history_log "DOWNLOAD" "${vm_key}" "${remote_src}" "${local_dst}" "${bytes_size}" "${duration}"

    utils_trigger_hook "post-download" "${vm_key}" "${remote_src}" "${local_dst}"
    ui_msg_info "Download completed successfully!"
    sleep 2
  fi
}

# ------------------------------------------------------------------------------
# Function: transfer_vm_to_vm
# Description: Pipes file/folder transfers directly between two connected VMs.
# Arguments: $1 - Source VM Key
# ------------------------------------------------------------------------------
transfer_vm_to_vm() {
  local src_vm_key="$1"

  # 1. Choose Target VM
  local target_options=()
  for entry in "${VMS[@]}"; do
    IFS='|' read -r k n u p h <<<"${entry}"
    if [[ "${k}" != "${src_vm_key}" ]]; then
      target_options+=("${k} - ${n}")
    fi
  done

  ui_header "Select Destination Target VM"
  local choice
  choice=$(gum choose "${target_options[@]}")
  if [[ -z "${choice}" ]]; then
    return 0
  fi

  local dst_vm_key
  dst_vm_key=$(echo "${choice}" | cut -d' ' -f1)

  # 2. Authenticate Destination VM
  if ! ssh_connect "${dst_vm_key}"; then
    return 1
  fi

  # 3. Select Remote Source Path
  local src_path
  src_path=$(browser_remote "${src_vm_key}")
  if [[ -z "${src_path}" ]]; then
    return 0
  fi

  # 4. Get Source and Target Sockets
  local src_socket dst_socket
  src_socket=$(ssh_get_socket "${src_vm_key}")
  dst_socket=$(ssh_get_socket "${dst_vm_key}")

  vm_get_by_key "${src_vm_key}"
  local src_user="${VM_USER}"
  local src_port="${VM_PORT}"

  vm_get_by_key "${dst_vm_key}"
  local dst_user="${VM_USER}"
  local dst_port="${VM_PORT}"
  local dst_home="${VM_HOME}"

  if ui_msg_confirm "Transfer '${src_path}' from ${src_vm_key} -> ${dst_vm_key}:${dst_home}?"; then
    ui_msg_info "Streaming direct VM-to-VM transfer..."

    local start_time
    start_time=$(date +%s)

    # Pipe tar archive directly over persistent SSH sockets in host RAM
    ssh -S "${src_socket}" -p "${src_port}" "${src_user}@${HOST}" \
      "tar -czf - -C '$(dirname "${src_path}")' '$(basename "${src_path}")'" |
      ssh -S "${dst_socket}" -p "${dst_port}" "${dst_user}@${HOST}" \
        "tar -xzf - -C '${dst_home}'"

    local end_time duration
    end_time=$(date +%s)
    duration=$((end_time - start_time))

    history_log "VM2VM" "${src_vm_key}->${dst_vm_key}" "${src_path}" "${dst_home}" "Direct Pipe" "${duration}"
    cache_clear "${dst_vm_key}"

    ui_msg_info "VM-to-VM transfer completed!"
    sleep 2
  fi
}
