#!/usr/bin/env bash
# ==============================================================================
# Script: settings.sh
# Description: Application parameters, cache flush, and configuration backup engine.
# ==============================================================================

# ------------------------------------------------------------------------------
# Function: settings_backup
# Description: Exports current vmcopy configurations and history to archive tar.
# ------------------------------------------------------------------------------
settings_backup() {
  local backup_tar="${HOME}/vmcopy_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
  tar -czf "${backup_tar}" -C "${HOME}" ".config/vmcopy" ".local/share/vmcopy"
  ui_msg_info "Configuration exported to: ${backup_tar}"
  sleep 2
}

# ------------------------------------------------------------------------------
# Function: settings_restore
# Description: Restores vmcopy state from tarball backup archive.
# ------------------------------------------------------------------------------
settings_restore() {
  local archive
  archive=$(gum input --placeholder "/path/to/vmcopy_backup.tar.gz")
  if [[ -f "${archive}" ]]; then
    tar -xzf "${archive}" -C "${HOME}"
    ui_msg_info "Configuration restored successfully!"
  else
    ui_msg_error "Specified archive does not exist."
  fi
  sleep 2
}

# ------------------------------------------------------------------------------
# Function: settings_menu
# Description: Main interactive configuration dashboard.
# ------------------------------------------------------------------------------
settings_menu() {
  while true; do
    ui_header "Settings & Utilities"

    local choice
    choice=$(gum choose \
      "Clear Remote Directory Cache" \
      "Export Backup Archive" \
      "Import Backup Archive" \
      "Edit Configuration File" \
      "View System Logs" \
      "Back to Main Menu")

    case "${choice}" in
    "Clear Remote Directory Cache")
      cache_clear
      ui_msg_info "All cached indexes flushed."
      sleep 1
      ;;
    "Export Backup Archive")
      settings_backup
      ;;
    "Import Backup Archive")
      settings_restore
      ;;
    "Edit Configuration File")
      ${EDITOR:-nano} "${VMCOPY_CONFIG_DIR}/config.sh"
      source "${VMCOPY_CONFIG_DIR}/config.sh"
      ;;
    "View System Logs")
      if [[ -f "${VMCOPY_LOG_DIR}/vmcopy.log" ]]; then
        bat --style=numbers "${VMCOPY_LOG_DIR}/vmcopy.log" || tail -n 100 "${VMCOPY_LOG_DIR}/vmcopy.log"
      else
        ui_msg_info "Log file is currently empty."
      fi
      echo "Press enter to continue..."
      read -r
      ;;
    "Back to Main Menu" | *)
      break
      ;;
    esac
  done
}
