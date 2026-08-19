#!/usr/bin/env bash
# ==============================================================================
# Script: preview.sh
# Description: Dynamic multi-format file viewer engine.
# ==============================================================================

# ------------------------------------------------------------------------------
# Function: preview_file
# Description: Inspects a path and renders output based on MIME/Extension.
# Arguments: $1 - Target File Path
# ------------------------------------------------------------------------------
preview_file() {
  local target="$1"

  if [[ ! -e "${target}" ]]; then
    echo "File does not exist: ${target}"
    return 1
  fi

  if [[ -d "${target}" ]]; then
    if utils_has_tool "eza"; then
      eza --tree --level=2 --icons "${target}"
    elif utils_has_tool "tree"; then
      tree -L 2 "${target}"
    else
      ls -la "${target}"
    fi
    return 0
  fi

  local mime_type
  mime_type=$(file --mime-type -b "${target}" 2>/dev/null || echo "unknown/unknown")

  case "${mime_type}" in
  text/* | application/json | application/xml | application/x-sh | application/javascript)
    if utils_has_tool "bat"; then
      bat --color=always --style=numbers --line-range :500 "${target}"
    else
      head -n 500 "${target}"
    fi
    ;;
  application/pdf)
    if utils_has_tool "pdfinfo"; then
      pdfinfo "${target}"
    else
      echo "PDF Document [Install poppler-utils/pdfinfo for details]"
    fi
    ;;
  application/zip | application/x-tar | application/x-compressed-tar | application/x-gzip | application/x-bzip2)
    if utils_has_tool "bsdtar"; then
      bsdtar -tf "${target}" | head -n 100
    elif utils_has_tool "tar"; then
      tar -tvf "${target}" 2>/dev/null | head -n 100 || unzip -l "${target}" 2>/dev/null | head -n 100
    else
      echo "Archive File [No extraction previewer found]"
    fi
    ;;
  image/*)
    file "${target}"
    ;;
  *)
    file "${target}"
    ;;
  esac
}
