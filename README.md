# ❄️ Dotfiles — Fedora & Hyprland

Personal dotfiles and system configurations for a keyboard-driven, Wayland-based workflow running on **Fedora Linux** with **Hyprland**.

---

## 🛠️ Tech Stack & Core Tools

* **OS:** Fedora Linux 44
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
---
## ⚡ Custom Keybindings & Features


### Hyprland Shortcuts
| Shortcut | Action | Description |
|:--- | :---|:--- |
| `Super + V` | Clipboard Menu | Search and paste from cliphist history via Rofi |
| `Super + Shift + V` | Wipe Clipboard | Clear cliphist history database |
| `Super + Enter` | Terminal | Open Kitty terminal session |
| `Super + Q` | Kill Window | Close active focused client |
| `Super + H` | Open Help | Open help window that contains all the shorcuts about the remaining shortcuts |

---

## 🐚 Zsh Aliases & Functions

**Key shell utilities defined in .zshrc:**
- **Dotfiles Management**

   * `dot-status` — _Check Git status of ~/.config from any directory._

   * `dot-diff` — _View uncommitted changes across tracked dotfiles._

   * `dot-push [msg]` — _Stage, auto-commit with metadata (date/host/changed files), and push to GitHub._

   * `dot-pull` — _Pull and sync the latest changes from the remote repo._

- **System Maintenance**

   * `sysup / update` — _Refresh and upgrade DNF packages and Flatpaks._

   * `cleanup` — _Run package autoremove._

   * `helpc` — _Print all the aliases available/declared_ 

   * `helpc2` — _Print custom user aliases with clean column alignment._

- **Network Controls**

   * `vpnon` — _Connect Cloudflare WARP (warp-cli connect)._

   * `vpnoff` — _Disconnect Cloudflare WARP (warp-cli disconnect)._

   * `vpn` — _Check WARP connection status._

---
## 🚀 Installation & Syncing

   1. Clone the repository directly into ~/.dotfiles :
   ``` bash

    git clone https://github.com/prateek-code-it/fedora-dotfiles.git ~/.dotfiles 
    cd ~/.dotfiles 
    chmod +x install.sh 
    ./instal.sh
   ```
   2. Symlink .zshrc to $HOME:
   ``` bash

    ln -sf ~/.config/.zshrc ~/.zshrc
   ```
   3. Reload shell environment:
   ``` bash

    source ~/.zshrc
   ```

---
