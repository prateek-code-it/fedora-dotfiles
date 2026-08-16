# ❄️ Dotfiles — Fedora & Hyprland

Personal dotfiles and system configurations for a keyboard-driven, Wayland-based workflow running on **Fedora Linux** with **Hyprland**.

---

## 🛠️ Tech Stack & Core Tools

* **OS:** Fedora Linux
* **Window Manager:** [Hyprland](https://hyprland.org/) (Wayland Compositor)
* **Shell:** Zsh with [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
* **Terminal:** Kitty
* **Menu / Launcher:** Rofi (Wayland fork)
* **Clipboard Manager:** `wl-clipboard` + `cliphist`
* **Networking & VPN:** Cloudflare WARP (`warp-cli`)
* **System Fetch:** Fastfetch

---

## 📁 Repository Structure

```text
~/.config/
├── hypr/               # Hyprland window rules, binds, and autostart
├── kitty/              # Terminal appearance and keymaps
├── rofi/               # Application launcher, calculator, clipboard menus
├── fastfetch/          # System fetch art and configuration
├── .zshrc              # Tracked shell configuration (symlinked to ~/)
└── README.md
```

##⚡ Custom Keybindings & Features

```text
#Hyprland Shortcuts
#Shortcut		 Action		Description
Super + V		#Clipboard Menu	Search and paste from cliphist history via Rofi
Super + Shift + V	#Wipe Clipboard	Clear cliphist history database
Super + Enter		#Terminal	Open Kitty terminal session
Super + Q		#Kill Window	Close active focused client
```

##🐚 Zsh Aliases & Functions

**Key shell utilities defined in .zshrc:**
* **Dotfiles Management**

    dotstat — Check Git status of ~/.config from any directory.

    dotdiff — View uncommitted changes across tracked dotfiles.

    dotpush [msg] — Stage, auto-commit with metadata (date/host/changed files), and push to GitHub.

    dotpull — Pull and sync the latest changes from the remote repo.

* **System Maintenance**

    sysup / update — Refresh and upgrade DNF packages and Flatpaks.

    cleanup — Run package autoremove.

    myaliases — Print custom user aliases with clean column alignment.

* **Network Controls**

    vpnon — Connect Cloudflare WARP (warp-cli connect).

    vpnoff — Disconnect Cloudflare WARP (warp-cli disconnect).

    vpn — Check WARP connection status.

##🚀 Installation & Syncing

   1. Clone the repository directly into ~/.config:
    ```Bash

    git clone <YOUR_REPO_URL> ~/.config
```
   2. Symlink .zshrc to $HOME:
   ``` Bash

    ln -sf ~/.config/.zshrc ~/.zshrc
```
   3. Reload shell environment:
   ``` Bash

    source ~/.zshrc
```

---

### How to Add It to Your Dotfiles

1. Make sure `README.md` is whitelisted in your `~/.config/.gitignore`:
   ```bash
   echo "!README.md" >> ~/.config/.gitignore
```
2. Write the file inside ~/.config/README.md.

3. Commit and push it:
```bash
dotpush "Add README documentation"
```
