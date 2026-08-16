#!/usr/bin/env bash
set -e

# Colors
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

log_info()    { echo -e "${BLUE}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_error()   { echo -e "${RED}[ERROR]${RESET} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LISTS_DIR="$DOTFILES_DIR/lists"

# 1. Update & DNF Packages
if [ -f "$LISTS_DIR/dnf_packages.txt" ] && [ -s "$LISTS_DIR/dnf_packages.txt" ]; then
    log_info "Updating system and installing DNF packages from lists/dnf_packages.txt..."
    sudo dnf upgrade --refresh -y
    sudo dnf install -y $(cat "$LISTS_DIR/dnf_packages.txt" | tr '\n' ' ')
    log_success "DNF packages installed."
fi

# 2. Flatpaks
if [ -f "$LISTS_DIR/flatpak_packages.txt" ] && [ -s "$LISTS_DIR/flatpak_packages.txt" ]; then
    log_info "Configuring Flathub and installing Flatpaks..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    xargs -a "$LISTS_DIR/flatpak_packages.txt" -r flatpak install -y flathub
    log_success "Flatpaks installed."
fi

# 3. Cargo Packages
if [ -f "$LISTS_DIR/cargo_packages.txt" ] && [ -s "$LISTS_DIR/cargo_packages.txt" ]; then
    log_info "Installing Cargo packages..."
    xargs -a "$LISTS_DIR/cargo_packages.txt" -r cargo install --locked
    log_success "Cargo packages installed."
fi

# 4. Python User Packages
if [ -f "$LISTS_DIR/pip_packages.txt" ] && [ -s "$LISTS_DIR/pip_packages.txt" ]; then
    log_info "Installing Python user packages..."
    pip3 install --user --upgrade -r "$LISTS_DIR/pip_packages.txt" || true
    log_success "Python packages installed."
fi

# 5. JetBrains Mono Nerd Font
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
if [ ! -d "$FONT_DIR" ]; then
    log_info "Installing JetBrains Mono Nerd Font..."
    mkdir -p "$FONT_DIR"
    wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz -O /tmp/JetBrainsMono.tar.xz
    tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONT_DIR"
    rm /tmp/JetBrainsMono.tar.xz
    fc-cache -fv
    log_success "Nerd Font installed."
fi

# 6. Oh My Zsh & Plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true
fi

# 7. Symlink Dotfiles (.config and home dotfiles)
log_info "Symlinking configuration files..."
mkdir -p "$HOME/.config"

if [ -d "$DOTFILES_DIR/.config" ]; then
    for item in "$DOTFILES_DIR/.config"/*; do
        name=$(basename "$item")
        dest="$HOME/.config/$name"
        [ -e "$dest" ] || [ -L "$dest" ] && mv "$dest" "${dest}.bak"
        ln -sf "$item" "$dest"
        log_info "Linked .config/$name -> $dest"
    done
fi

for dotfile in .zshrc .tmux.conf; do
    if [ -f "$DOTFILES_DIR/$dotfile" ]; then
        [ -f "$HOME/$dotfile" ] && mv "$HOME/$dotfile" "$HOME/${dotfile}.bak"
        ln -sf "$DOTFILES_DIR/$dotfile" "$HOME/$dotfile"
        log_info "Linked $dotfile -> $HOME/$dotfile"
    fi
done

log_success "Installation and linking complete!"
