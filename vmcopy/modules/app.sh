#!/usr/bin/env bash
# ==============================================================================
# Script: app.sh
# Description: Main controller workflow and runtime lifecycle.
# ==============================================================================

trap 'app_cleanup' EXIT INT TERM

app_cleanup() {
  ssh_disconnect_all
}

app_select_vm() {
  local options=()
  for entry in "${VMS[@]}"; do
    IFS='|' read -r k n u p h <<<"${entry}"
    options+=("${k} - ${n} (${u}@${HOST}:${p})")
  done

  local choice
  choice=$(gum choose "${options[@]}")
  if [[ -n "${choice}" ]]; then
    echo "${choice}" | cut -d' ' -f1
  fi
}

app_vm_menu() {
  local vm_key="$1"
  vm_get_by_key "${vm_key}"

  if ! ssh_connect "${vm_key}"; then
    return 1
  fi

  while true; do
    ui_header "VM Session: ${VM_NAME}"

    local action
    action=$(gum choose \
      "Upload File/Folder (Host -> VM)" \
      "Download File/Folder (VM -> Host)" \
      "Transfer Directly to Another VM (VM -> VM)" \
      "Browse Remote Directory" \
      "Browse Local Directory" \
      "Open Terminal (SSH Shell)" \
      "Disconnect Session" \
      "Back to Dashboard")

    case "${action}" in
    "Upload File/Folder (Host -> VM)")
      transfer_upload "${vm_key}"
      ;;
    "Download File/Folder (VM -> Host)")
      transfer_download "${vm_key}"
      ;;
    "Transfer Directly to Another VM (VM -> VM)")
      transfer_vm_to_vm "${vm_key}"
      ;;
    "Browse Remote Directory")
      local target
      target=$(browser_remote "${vm_key}" "${VM_HOME}")
      if [[ -n "${target}" ]]; then
        ui_msg_info "Selected: ${target}"
        sleep 1
      fi
      ;;
    "Browse Local Directory")
      local target
      target=$(browser_local "${HOME}")
      if [[ -n "${target}" ]]; then
        ui_msg_info "Selected: ${target}"
        sleep 1
      fi
      ;;
    "Open Terminal (SSH Shell)")
      ui_msg_info "Launching interactive shell on ${VM_NAME}..."
      ssh_exec "${vm_key}" -t "cd '${VM_HOME}' && exec \$SHELL -l" || true
      ;;
    "Disconnect Session")
      ssh_disconnect "${vm_key}"
      ui_msg_info "Disconnected SSH master connection."
      sleep 1
      break
      ;;
    "Back to Dashboard" | *)
      break
      ;;
    esac
  done
}

app_interactive() {
  while true; do
    ui_render_dashboard

    local choice
    choice=$(gum choose \
      "Connect / Manage VM" \
      "Operation History" \
      "Settings & Config" \
      "Exit")

    case "${choice}" in
    "Connect / Manage VM")
      local target_vm
      target_vm=$(app_select_vm)
      if [[ -n "${target_vm}" ]]; then
        app_vm_menu "${target_vm}"
      fi
      ;;
    "Operation History")
      history_view
      ;;
    "Settings & Config")
      settings_menu
      ;;
    "Exit" | *)
      ui_msg_info "Shutting down vmcopy v2..."
      exit 0
      ;;
    esac
  done
}

app_main() {
  utils_check_dependencies
  vm_validate_config

  if [[ $# -eq 0 ]]; then
    app_interactive
    return 0
  fi

  case "$1" in
  --ssh)
    if [[ -n "${2:-}" ]]; then
      app_vm_menu "$2"
    else
      ui_msg_error "Missing VM key parameter. Usage: vmcopy --ssh <vm_key>"
    fi
    ;;
  --upload)
    if [[ -n "${2:-}" ]]; then
      transfer_upload "$2"
    else
      ui_msg_error "Missing VM key parameter. Usage: vmcopy --upload <vm_key>"
    fi
    ;;
  --download)
    if [[ -n "${2:-}" ]]; then
      transfer_download "$2"
    else
      ui_msg_error "Missing VM key parameter. Usage: vmcopy --download <vm_key>"
    fi
    ;;
  --browse)
    if [[ -n "${2:-}" ]]; then
      browser_remote "$2"
    else
      ui_msg_error "Missing VM key parameter. Usage: vmcopy --browse <vm_key>"
    fi
    ;;
  --history)
    history_view
    ;;
  --config)
    ${EDITOR:-nano} "${VMCOPY_CONFIG_DIR}/config.sh"
    ;;
  --help | -h)
    echo "vmcopy v2 CLI Commands:"
    echo "  vmcopy                     Launch interactive TUI"
    echo "  vmcopy --ssh <key>         Open connection menu / shell"
    echo "  vmcopy --upload <key>      Trigger upload workflow"
    echo "  vmcopy --download <key>    Trigger download workflow"
    echo "  vmcopy --browse <key>      Browse remote directory"
    echo "  vmcopy --history           Search transfer logs"
    echo "  vmcopy --config            Open configuration file"
    ;;
  *)
    ui_msg_error "Unknown argument: $1"
    echo "Use 'vmcopy --help' for usage commands."
    exit 1
    ;;
  esac
}
