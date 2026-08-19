#!/usr/bin/env bash
# ==============================================================================
# Script: history.sh
# Description: Tracks and queries all file operations performed by vmcopy.
# ==============================================================================

export HISTORY_FILE="${VMCOPY_SHARE_DIR}/history.log"

# ------------------------------------------------------------------------------
# Function: history_log
# Description: Appends structured file transfer record to history storage.
# Arguments: $1-Op, $2-VM, $3-Src, $4-Dst, $5-Size, $6-Duration
# ------------------------------------------------------------------------------
history_log() {
  local op="$1"
  local vm_key="$2"
  local src="$3"
  local dst="$4"
  local size="$5"
  local duration="$6"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  echo "${timestamp}\t${op}\t${vm_key}\t${src}\t${dst}\t${size}\t${duration}s" >>"${HISTORY_FILE}"
  utils_log "INFO" "History entry created: ${op} for ${vm_key}"
}

# ------------------------------------------------------------------------------
# Function: history_view
# Description: Interactive history search visualizer powered by fzf.
# ------------------------------------------------------------------------------
history_view() {
  if [[ ! -f "${HISTORY_FILE}" ]] || [[ ! -s "${HISTORY_FILE}" ]]; then
    ui_msg_info "No history logs recorded yet."
    return 0
  fi

  cat "${HISTORY_FILE}" | fzf \
    --header="TIMESTAMP | OPERATION | VM | SOURCE | DESTINATION | SIZE | DURATION" \
    --delimiter="\t" \
    --preview='echo -e "Timestamp: {1}\nOperation: {2}\nVM: {3}\nSource: {4}\nDestination: {5}\nSize: {6}\nDuration: {7}"' \
    --preview-window=bottom:40% \
    --prompt="Search History > " || true
}
