#!/usr/bin/env bash
# ==============================================================================
# Script: browser.sh
# Description: Interactive local and remote path navigation engines.
# ==============================================================================

# ------------------------------------------------------------------------------
# Function: browser_local
# Description: Explores local filesystem using fd/find and preview using bat.
# Returns: Selected file/folder absolute path
# ------------------------------------------------------------------------------
browser_local() {
  local start_dir="${1:-${HOME}}"
  local selected

  local find_cmd
  if utils_has_tool "fd"; then
    find_cmd="fd --hidden --exclude .git . '${start_dir}'"
  else
    find_cmd="find '${start_dir}' -maxdepth 3 -not -path '*/.*'"
  fi

  selected=$(eval "${find_cmd}" | fzf \
    --prompt="Local Filesystem (${start_dir}) > " \
    --header="CTRL-R: Toggle Home | Enter: Select" \
    --preview='bash -c "source ${VMCOPY_MODULES_DIR}/utils.sh; source ${VMCOPY_MODULES_DIR}/preview.sh; preview_file {}"' \
    --preview-window=right:50%)

  echo "${selected}"
}

# ------------------------------------------------------------------------------
# Function: browser_remote
# Description: Remote file navigation using SSH & cached directory trees.
# Arguments: $1 - VM Key, $2 - Initial Path
# Returns: Selected remote absolute path
# ------------------------------------------------------------------------------
browser_remote() {
  local vm_key="$1"
  local remote_dir="${2:-}"

  vm_get_by_key "${vm_key}"
  if [[ -z "${remote_dir}" ]]; then
    remote_dir="${VM_HOME}"
  fi

  local cache_file
  cache_file=$(cache_get_key "${vm_key}" "${remote_dir}")

  local remote_files
  if cache_is_valid "${cache_file}" "${VM_PROF_TIMEOUT}"; then
    remote_files=$(cat "${cache_file}")
  else
    remote_files=$(ssh_exec "${vm_key}" "find '${remote_dir}' -maxdepth 2 -not -path '*/.*' 2>/dev/null" || true)
    echo "${remote_files}" | cache_write "${cache_file}"
  fi

  if [[ -z "${remote_files}" ]]; then
    ui_msg_error "Failed to retrieve remote path index or directory empty."
    echo "${remote_dir}"
    return 0
  fi

  local selected
  selected=$(echo "${remote_files}" | fzf \
    --prompt="Remote Filesystem (${VM_NAME}:${remote_dir}) > " \
    --header="Enter: Select path" \
    --preview="bash -c \"source ${VMCOPY_MODULES_DIR}/ssh.sh; source ${VMCOPY_MODULES_DIR}/utils.sh; source ${VMCOPY_MODULES_DIR}/preview.sh; ssh_exec ${vm_key} file -b {} 2>/dev/null\"" \
    --preview-window=right:50%)

  if [[ -n "${selected}" ]]; then
    echo "${selected}"
  else
    echo "${remote_dir}"
  fi
}
