# ============================================================
# ZSH CONFIGURATION
# Oh My Zsh + Powerlevel10k
# ============================================================

# ------------------------------------------------------------
# Powerlevel10k Instant Prompt
# KEEP THIS NEAR THE TOP
# ------------------------------------------------------------

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

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
# History optimizations
setopt hist_expire_dups_first # Drop oldest duplicate entries first when limit is reached
setopt hist_ignore_dups       # Don't record a command if it matches the previous one
setopt hist_ignore_space      # Don't save commands starting with a space (great for passwords/tokens)
setopt hist_verify            # Expand history commands (like !$) to review before execution


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
# Case-insensitive tab completion (a matches A, A matches a)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:*:*:*:*' menu select

# ------------------------------------------------------------
# Environment
# ------------------------------------------------------------

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"


# Colorize man pages
export LESS_TERMCAP_mb=$'\E[1;31m'     # Begin blinking (Red)
export LESS_TERMCAP_md=$'\E[1;36m'     # Begin bold/headings (Cyan)
export LESS_TERMCAP_me=$'\E[0m'        # End mode
export LESS_TERMCAP_so=$'\E[01;33m'    # Search highlight (Yellow status bar)
export LESS_TERMCAP_se=$'\E[0m'        # End standout-mode
export LESS_TERMCAP_us=$'\E[1;32m'     # Underline / variable names (Green)
export LESS_TERMCAP_ue=$'\E[0m'        # End underline

# ------------------------------------------------------------
# PATH
# ------------------------------------------------------------

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"
export JAVA_HOME="/usr/lib/jvm/java-21-temurin-jdk"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HOME/.local/share/flatpak/exports/bin:/var/lib/flatpak/exports/bin:$PATH"

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

alias cls='printf "\033[2J\033[3J\033[1;1H"'
alias clear='printf "\033[2J\033[3J\033[1;1H"'

alias mic="bash ~/.config/hypr/scripts/toggle-mic.sh"

# ------------------------------------------------------------
# Config files
# ------------------------------------------------------------

gen_dotmsg() {
  local dt host branch changed_files

  dt=$(date '+%Y-%m-%d %H:%M:%S')
  host=$(uname -n)
  branch=$(git -C ~/.config rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

  # Extract changed file paths and join with commas, removing trailing comma
  changed_files=$(git -C ~/.config status --porcelain | sed -E 's/^...//' | paste -sd, -)

  if [[ -n "$changed_files" ]]; then
    echo "Alteration on $dt | Host: $host | Branch: $branch | Modified: [$changed_files]"
  else
    echo "Alteration on $dt | Host: $host | Branch: $branch"
  fi
}

dotpush() {
  local msg="$1"

  # Stage all changes respecting .gitignore
  git -C ~/.config add -A

  # Check if there are any staged changes before committing
  if git -C ~/.config diff --cached --quiet; then
    echo "No changes to commit in ~/.config"
    echo ":-D..."
    sleep 3
    return 0
  fi

  # Determine commit message
  if [ -z "$msg" ]; then
    if declare -f gen_dotmsg >/dev/null 2>&1; then
      msg=$(gen_dotmsg)
    else
      msg="Config update: $(date '+%Y-%m-%d %H:%M')"
    fi
  else
    msg="$msg | Config update: $(date '+%Y-%m-%d %H:%M')"
  fi

  echo "Committing with: $msg "
  echo ":-)..."
  sleep 3
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
alias reload='cls ;source ~/.zshrc'
alias clock='tclock -c Cyan'

joke() {
    local j
    j=$(curl -s -H "Accept: text/plain" https://icanhazdadjoke.com/)
    echo "🤣 DAD JOKE : $j"
}

qr() {
	local txt="$1"
	if [ -z "$txt" ]; then
		echo "[!] Empty ARGUMENT! "
		echo "[?] Usages: qr '<txt to convert in the qr-code>'"
	else
		echo "[*] QR-Code of : $txt"
		qrencode -t utf8 "$txt" 
	fi
 }

mini-train(){
        while true; do
                sl
                sleep 1
                clear
        done
}

train() {
    trap 'echo -e "\e[0m"; clear; return' INT

    local quotes=(
        "Choo choo! Next stop: Code Refactoring..."
        "All aboard the Linux Express!"
        "Taking a quick break from the terminal..."
        "Compiling... just kidding, it's a train."
    )

    while true; do
        clear
        # Print a stylized header in cyan
        echo -e "\e[1;36m========================================================\e[0m"
        echo -e "\e[1;35m               STEAM LOCOMOTIVE LOOPS                   \e[0m"
        echo -e "\e[1;36m========================================================\e[0m\n"

        # Run sl in random color
        echo -e "\e[33m"
        sl -l
        echo -e "\e[0m"

        # Print a random quote at the bottom in green
        local random_quote=${quotes[$RANDOM % ${#quotes[@]}]}
        echo -e "\n\e[1;32m> ${random_quote}\e[0m"

        sleep 1
    done
}



# ------------------------------------------------------------
# Virtual Machine's SSH Access
# ------------------------------------------------------------

alias ccserver='ssh -p 2224 admin_master@127.0.0.1'
alias debby='ssh -p 2226 debby@127.0.0.1'
alias kali='ssh -p 2222 pratique@127.0.0.1'

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

copylastcmd() {
  fc -ln -1 | sed 's/^[[:space:]]*//' | wl-copy
  echo "Copied last command string to clipboard."
}

copylast() {
  local last_cmd
  last_cmd=$(fc -ln -1 | sed 's/^[[:space:]]*//')

  if [[ -n "$last_cmd" ]]; then
    eval "$last_cmd" | wl-copy
    echo "Re-ran command and copied output to clipboard."
  fi
}

alias cl='copylast'
alias clc='copylastcmd'

# Clipboard
alias c='wl-copy'
alias p='wl-paste'
alias ctee='tee >(wl-copy)'
alias empty='echo -n >'

# ------------------------------------------------------------
# System
# ------------------------------------------------------------

sysupdate() {
  echo "📦 Updating system packages..."
  sudo dnf upgrade --refresh -y
  echo " \033[0;5m DNF DONE ... :-D" | lolcat
  sleep 1
  if command -v flatpak &>/dev/null; then
    echo "📦 Updating Flatpaks..."
    flatpak update -y 
    echo "\033[0;5m Flatpaks DONE .. :-D" | lolcat
    sleep 1
  fi
  echo "\033[0;5m [!] Cleaning the extra..." | lolcat
  cleanup | lolcat
  fpclean | lolcat
  sleep 1
  echo "📦 Updating Firmware...."
  update_firmware
 
  echo "✅ System update complete."
}

update_firmware() {
    # Define ANSI Color Codes
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local NC='\033[0m' # No Color

    echo -e "${BLUE}=== Starting System Firmware Update ===${NC}\n"

    # 1. Verify that fwupdmgr is installed
    if ! command -v fwupdmgr &> /dev/null; then
        echo -e "${RED}[ERROR] 'fwupdmgr' is not installed.${NC}"
        echo -e "Please install it via your package manager (e.g., sudo dnf install fwupd / sudo apt install fwupd)."
        return 1
    fi

    # 2. Refresh metadata from Linux Vendor Firmware Service (LVFS)
    echo -e "${YELLOW}[1/4] Refreshing device metadata from LVFS...${NC}"
    if fwupdmgr refresh --force ; then
        echo -e "${GREEN}-> Metadata successfully refreshed.${NC}\n"
    else
        echo -e "${RED}[WARNING] Failed to refresh metadata. Continuing with cached data...${NC}\n"
    fi

    # 3. Check for available firmware updates
    echo -e "${YELLOW}[2/4] Checking for available firmware updates...${NC}"
    fwupdmgr get-updates

    local cmd_status=$?
    if [ $cmd_status -ne 0 ]; then
        echo -e "\n${GREEN}\033[0;5m [INFO] Your system firmware is fully up to date!${NC}"
        return 0
    fi

    # 4. Prompt user for confirmation before applying
    echo -e "\n${YELLOW}[3/4] Firmware updates found!${NC}"
    read -rp "Do you want to proceed with applying updates? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Firmware update canceled by user.${NC}"
        return 0
    fi

    # 5. Apply the updates
    echo -e "\n${YELLOW}[4/4] Applying firmware updates...${NC}"
    echo -e "${RED}Do NOT turn off or unplug your computer during this process!${NC}\n"
    
    fwupdmgr update

    # 6. Check if a reboot is needed
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}=== Firmware Update Complete ===${NC}"
        read -rp "A system restart may be required to complete installation. Reboot now? (y/N): " reboot_confirm
        if [[ "$reboot_confirm" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Rebooting system...${NC}"
            sudo reboot
        else
            echo -e "${YELLOW}Please remember to restart your system manually later.${NC}"
        fi
    else
        echo -e "\n${RED}[ERROR] Firmware update encountered an issue.${NC}"
        return 1
    fi
}

alias hp-update='update_firmware'
alias sysup='sysupdate'
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


alias activate='source ~/development/python/bin/activate'

alias idea='idea "$PWD"'
alias weather="curl wttr.in/"


# ------------------------------------------------------------
# FZF
# ------------------------------------------------------------

if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi

# ------------------------------------------------------------
# APPS SHORTCUT
# ------------------------------------------------------------

alias discordv='flatpak run dev.vencord.Vesktop &'

# ------------------------------------------------------------ 
# some Editing tools 
# ------------------------------------------------------------ 

ansicodes() {
  printf "\n\033[1;36m=== ANSI ESCAPE CODES CHEAT SHEET ===\033[0m\n\n"

  # Styles
  printf "\033[1m-- Text Styles --\033[0m\n"
  printf "  \033[0m0: Normal\033[0m         \033[1m1: Bold\033[0m          \033[2m2: Dim\033[0m\n"
  printf "  \033[3m3: Italic\033[0m         \033[4m4: Underline\033[0m     \033[5m5: Blink\033[0m\n"
  printf "  \033[7m7: Reverse\033[0m       \033[8m8: Conceal\033[0m       \033[9m9: Strikethrough\033[0m\n\n"

  # Standard Colors
  printf "\033[1m-- Standard Foreground / Background (30-37 / 40-47) --\033[0m\n"
  local colors=("30:Black" "31:Red" "32:Green" "33:Yellow" "34:Blue" "35:Magenta" "36:Cyan" "37:White")
  for entry in "${colors[@]}"; do
    local code="${entry%%:*}"
    local name="${entry#*:}"
    local bg_code=$((code + 10))
    printf "  \033[${code}m%-10s (\033[0m%s\033[${code}m)\033[0m   \033[${bg_code};30m %-10s \033[0m (40-47)\n" "$name" "$code" "$name BG"
  done

  # Bright Colors
  printf "\n\033[1m-- Bright Foreground / Background (90-97 / 100-107) --\033[0m\n"
  local brights=("90:Bright Black" "91:Bright Red" "92:Bright Green" "93:Bright Yellow" "94:Bright Blue" "95:Bright Magenta" "96:Bright Cyan" "97:Bright White")
  for entry in "${brights[@]}"; do
    local code="${entry%%:*}"
    local name="${entry#*:}"
    local bg_code=$((code + 10))
    printf "  \033[${code}m%-16s (\033[0m%s\033[${code}m)\033[0m   \033[${bg_code};30m %-16s \033[0m (100-107)\n" "$name" "$code" "$name BG"
  done

  # Syntax
  printf "\n\033[1m-- Syntax & Usage --\033[0m\n"
  printf "  \033[33mSyntax:\033[0m  \\\\e[<STYLE>;<FG>;<BG>m\n"
  printf "  \033[33m256-Color FG:\033[0m \\\\e[38;5;<0-255>m\n"
  printf "  \033[33mTruecolor FG:\033[0m \\\\e[38;2;<R>;<G>;<B>m\n"
  printf "  \033[33mExample:\033[0m \033[1;31;40m \\\\e[1;31;40m Bold Red on Black \033[0m\n\n"
}

alias codes="ansicodes"

# ------------------------------------------------------------
# Fastfetch
# ------------------------------------------------------------

alias sys="fastfetch"
alias ff="fastfetch --logo-type kitty-direct --logo ~/.config/fastfetch/fedora.png --logo-width 24 --logo-height 12"

# ------------------------------------------------------------
# Formatted Alias Viewers
# ------------------------------------------------------------

myaliases() {
  local target="${HOME}/.config/.zshrc"
  [[ ! -f "$target" ]] && target="${HOME}/.zshrc"

  echo -e "\033[1;34mALIAS\033[0m\t\t\033[1;32mCOMMAND\033[0m"
  echo -e "\033[1;30m------------------------------------------------------------\033[0m"

  grep -E '^\s*alias\s+' "$target" | sed -E "s/^\s*alias\s+//g" | awk -F'=' '{
    name = $1;
    sub(/^['\''"]/, "", $2);
    sub(/['\''"]$/, "", $2);
    printf "%-18s \033[0;36m➜\033[0m  %s\n", name, substr($0, index($0, "=") + 1)
  }'
}

listalias() {
  echo -e "\033[1;34mALIAS\033[0m\t\t\033[1;32mCOMMAND\033[0m"
  echo -e "\033[1;30m------------------------------------------------------------\033[0m"

  alias | awk -F'=' '{
    name = $1;
    cmd = substr($0, index($0, "=") + 1);
    gsub(/^'\''|'\''$/, "", cmd);
    printf "%-18s \033[0;36m➜\033[0m  %s\n", name, cmd
  }'
}

alias helpc='listalias'
alias helpc2='myaliases'

# ------------------------------------------------------------
# Powerlevel10k Configuration
# KEEP THIS AT THE END
# ------------------------------------------------------------

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ------------------------------------------------------------
# Startup Fetch
# ------------------------------------------------------------

#fastfetch --pipe false

# Run dynamic fastfetch only in interactive sessions
fastfetch --pipe false -c ~/.config/fastfetch/config_basic.jsonc

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export PATH=$PATH:/home/patrik/.spicetify
