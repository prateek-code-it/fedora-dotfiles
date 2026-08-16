# ============================================================
# ZSH CONFIGURATION
# Oh My Zsh + Powerlevel10k
# ============================================================


# ------------------------------------------------------------
# Powerlevel10k Instant Prompt
# KEEP THIS NEAR THE TOP
# ------------------------------------------------------------

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# ------------------------------------------------------------
# Oh My Zsh
# ------------------------------------------------------------

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"


# ------------------------------------------------------------
# Plugins
# ------------------------------------------------------------

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"


# ------------------------------------------------------------
# History
# ------------------------------------------------------------

HISTFILE="$HOME/.zsh_history"

HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY


# ------------------------------------------------------------
# Shell Behaviour
# ------------------------------------------------------------

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS


# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'


# ------------------------------------------------------------
# Environment
# ------------------------------------------------------------

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"


# ------------------------------------------------------------
# PATH
# ------------------------------------------------------------

export PATH="$HOME/.local/bin:$PATH"

if [[ -d "$HOME/.cargo/bin" ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi


# ------------------------------------------------------------
# Basic Aliases
# ------------------------------------------------------------

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias c='printf "\033[2J\033[3J\033[1;1H"'
alias cls='printf "\033[2J\033[3J\033[1;1H"'
alias clear='printf "\033[2J\033[3J\033[1;1H"'

alias mic="bash ~/.config/hypr/scripts/toggle-mic.sh"


# ------------------------------------------------------------
# Config files
# ------------------------------------------------------------

dotpush() {
  local msg="${1:-Config update: $(date '+%Y-%m-%d %H:%M')}"
  git -C ~/.config add .
  git -C ~/.config commit -m "$msg"
  git -C ~/.config push origin main
}


alias dot-push='dotpush'
alias dot-pull='git -C ~/.config pull origin main'
alias dot-status='git -C ~/.config status'
alias dot-diff='git -C ~/.config diff'

# ------------------------------------------------------------
# File Safety
# ------------------------------------------------------------

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'


# ------------------------------------------------------------
# ZSH
# ------------------------------------------------------------

alias zshrc='nvim ~/.zshrc'
alias p10k='nvim ~/.p10k.zsh'

alias reload='source ~/.zshrc'


# ------------------------------------------------------------
# Git
# ------------------------------------------------------------

alias gs='git status'
alias ga='git add'
alias gaa='git add --all'

alias gc='git commit'
alias gcm='git commit -m'

alias gp='git push'
alias gpl='git pull'

alias gd='git diff'
alias gds='git diff --staged'

alias gl='git log --oneline --graph --decorate'
alias gla='git log --all --oneline --graph --decorate'

alias gb='git branch'
alias gba='git branch -a'

alias gco='git checkout'
alias gcb='git checkout -b'

alias gst='git stash'
alias gstp='git stash pop'

alias gr='git remote -v'

# ------------------------------------------------------------
# Clipboard and Output Management
# ------------------------------------------------------------

copylast() {
  fc -ln -1 | sed 's/^[[:space:]]*//' | bash | wl-copy
  echo "Copied output of last command to clipboard."
}

alias cl='copylast'

alias empty='echo " " >'
alias c='wl-copy'
alias ctee='wl-copy -t text/plain | tee'

# ------------------------------------------------------------
# System
# ------------------------------------------------------------

sysup() {
  echo "📦 Updating system packages..."
  sudo dnf upgrade --refresh -y
  if command -v flatpak &>/dev/null; then
    echo "📦 Updating Flatpaks..."
    flatpak update -y
  fi
  echo "✅ System update complete."
}

alias sysup='sysup'
alias update='sudo dnf upgrade --refresh'
alias cleanup='sudo dnf autoremove'

alias fpupdate="flatpak update"
alias fpclean="flatpak uninstall --unused"
alias fp="flatpak"

alias reboot='systemctl reboot'
alias poweroff='systemctl poweroff'
alias suspend='systemctl suspend'

# ------------------------------------------------------------
# VPN
# ------------------------------------------------------------

alias vpn="warp-cli status"
alias vpnon="warp-cli connect"
alias vpnoff="warp-cli disconnect"

# ------------------------------------------------------------
# Package Managers
# ------------------------------------------------------------

alias dnfup='sudo dnf upgrade --refresh'
alias dnfclean='sudo dnf autoremove'

alias flatup='flatpak update'
alias snapup='sudo snap refresh'


# ------------------------------------------------------------
# Development
# ------------------------------------------------------------

alias py='python3'
alias pip='python3 -m pip'

alias venv='python3 -m venv .venv'
alias activate='source .venv/bin/activate'


# ------------------------------------------------------------
# FZF
# ------------------------------------------------------------

if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi


# ------------------------------------------------------------
# Fastfetch
# ------------------------------------------------------------

alias sys="fastfetch"
alias ff="fastfetch --logo-type kitty-direct --logo ~/.config/fastfetch/fedora.png --logo-width 24 --logo-height 12  "



# ------------------------------------------------------------
# Powerlevel10k Configuration
# KEEP THIS AT THE END
# ------------------------------------------------------------

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# ============================================================
# END OF ZSH CONFIGURATION
# ============================================================



#fastfetch --logo-type kitty-direct \
#  --logo ~/.config/fastfetch/fedora.png \
#  --logo-width 24 \
#  --logo-height 12
