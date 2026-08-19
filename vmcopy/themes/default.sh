#!/usr/bin/env bash
# ==============================================================================
# Script: default.sh
# Description: Default color theme variables for gum and fzf integrations.
# ==============================================================================

export THEME_NAME="default"

# Gum Color Schemes (ANSI / Hex)
export GUM_PRIMARY_COLOR="212"
export GUM_SECONDARY_COLOR="99"
export GUM_ACCENT_COLOR="208"
export GUM_BORDER_COLOR="63"
export GUM_TEXT_COLOR="255"

# FZF Color Customizations
export FZF_DEFAULT_OPTS="--height=70% --layout=reverse --border --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
