#!/usr/bin/env bash
# ==============================================================================
# Script: ui.sh
# Description: User Interface visual rendering engine using gum and formatting.
# ==============================================================================

# Source default theme variables
if [[ -f "${VMCOPY_THEMES_DIR}/${DEFAULT_THEME:-default}.sh" ]]; then
  source "${VMCOPY_THEMES_DIR}/${DEFAULT_THEME:-default}.sh"
fi

# ------------------------------------------------------------------------------
# Function: ui_header
# Description: Displays clean LazyGit-inspired banner top header.
# Arguments: $1 - Title String
# ------------------------------------------------------------------------------
ui_header() {
  clear
  gum style \
    --foreground "${GUM_PRIMARY_COLOR}" \
    --border-foreground "${GUM_BORDER_COLOR}" \
    --border double \
    --align center \
    --width 60 \
    --margin "0 1" \
    --padding "0 2" \
    "vmcopy v2 :: Terminal VirtualBox Manager" "${1:-Dashboard}"
}

# ------------------------------------------------------------------------------
# Function: ui_msg_info / ui_msg_error / ui_msg_confirm
# Description: Standard interactive visual alerts.
# ------------------------------------------------------------------------------
ui_msg_info() {
  gum style --foreground "${GUM_PRIMARY_COLOR}" "ℹ $1"
}

ui_msg_error() {
  gum style --foreground 196 "✖ $1"
}

ui_msg_confirm() {
  gum confirm "$1"
}

# ------------------------------------------------------------------------------
# Function: ui_render_dashboard
# Description: Renders the VM network overview table.
# ------------------------------------------------------------------------------
ui_render_dashboard() {
  ui_header "VM Dashboard"

  echo -e "Checking Virtual Machine Status...\n"

  local rows=()
  rows+=("Key|Name|Port|Status|Session")
  rows+=("---|---|---|---|---")

  for entry in "${VMS[@]}"; do
    IFS='|' read -r k n u p h <<<"${entry}"
    local status
    status=$(vm_check_status "${p}")

    local active="Inactive"
    if ssh_is_connected "${k}"; then
      active="🟢 Connected"
    fi

    rows+=("${k}|${n}|${p}|${status}|${active}")
  done

  printf "%s\n" "${rows[@]}" | column -t -s '|'
  echo ""
}
