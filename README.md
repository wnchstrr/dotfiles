# dotfiles

Personal Linux dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

**Stack:** Ubuntu 26.04 · Hyprland (Wayland) · ghostty + zsh · Neovim
**Theme:** TokyoNight Storm across the whole environment.

---

## Structure

Each top-level folder is a Stow *package* that mirrors its target layout under `$HOME`:

```
dotfiles/
├── ghostty/   .config/ghostty/   → terminal config + shaders
├── zsh/        .zshrc, .p10k.zsh → shell (oh-my-zsh + powerlevel10k)
├── tmux/      .config/tmux/      → tmux.conf (plugins managed by TPM, not committed)
├── hypr/      .config/hypr/      → hyprland, hypridle, hyprlock + Scripts
├── rofi/      .config/rofi/      → config + tokyonight theme
├── waybar/    .config/waybar/    → config.jsonc + style.css
├── gtk-interface.dconf           → GTK theme/icons/cursor dump (restored by install.sh)
└── install.sh                    → bootstrap script
```

Running `stow <package>` from the repo root creates symlinks like
`~/.config/hypr/hyprland.conf → ~/dotfiles/hypr/.config/hypr/hyprland.conf`.

> **nvim** is kept in a separate repo: [wnchstrr/nvim-config](https://github.com/wnchstrr/nvim-config).
> `install.sh` clones it into `~/.config/nvim`.

---

## Install (fresh machine)

### 1. SSH key for GitHub

`install.sh` clones the nvim repo over SSH, so set up a key first:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub   # add this to GitHub → Settings → SSH keys
ssh -T git@github.com        # verify
```

If port 22 is blocked (corporate / some ISPs), use SSH over 443 — add to `~/.ssh/config`:

```
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
```

### 2. Clone and bootstrap

```bash
git clone https://github.com/wnchstrr/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` will:
- `stow` every package (creates symlinks)
- clone TPM (tmux plugin manager)
- clone nvim-config
- restore GTK theme/icons/cursor via `dconf load`

### 3. Post-install (manual)

- **tmux:** open tmux, press `prefix + I` to install plugins
- Install package dependencies (see below) — `install.sh` does **not** install packages

---

## Dependencies

`install.sh` only creates symlinks and restores settings. Install the actual
programs yourself (versions/repos are intentionally left to you).

| Package  | Requires |
|----------|----------|
| ghostty  | `ghostty`; font **Cascadia Mono NF** (in `~/.local/share/fonts/`) |
| zsh      | `zsh`, [oh-my-zsh](https://ohmyz.sh/), [powerlevel10k](https://github.com/romkatv/powerlevel10k), `fzf`, `eza`, `bat` |
| tmux     | `tmux`; TPM (cloned by install.sh) |
| hypr     | `hyprland`, `swaybg`, `swaync`, `hyprshot`, `hyprlock`, `hypridle`, `hyprpicker`, `rofi` |
| waybar   | `waybar`; `cava` (optional — audio visualizer module) |
| rofi     | `rofi` (Wayland build) |
| GTK theme| **Tokyonight-Dark-Storm** theme, **Papirus-Dark** icons, **Bibata-Modern-Classic** cursor |

> **Note:** keybinds in `hyprland.conf` use `$mod = ALT` (this machine's Super key
> is dead at the hardware level). Change to `SUPER` on a normal keyboard.

---

## Usage

```bash
cd ~/dotfiles

stow hypr        # link a single package
stow */          # link all packages
stow -D hypr     # unlink (remove symlinks)
stow -R hypr     # restow (re-link after changes)
```

After editing a config, the symlink already points at the repo file — just
`git add` / `commit` the change. No re-stow needed unless you add new files.

---

## Notes

- Secrets are excluded via `.gitignore` (keys, tokens, `.env`, `*secret*`).
- GTK theme lives in dconf (binary), not a file — that's why it's dumped to
  `gtk-interface.dconf` and restored by the install script. To re-dump after
  changing the theme: `dconf dump /org/gnome/desktop/interface/ > gtk-interface.dconf`
- `hyprpaper.conf` is intentionally absent — wallpaper is set via `swaybg`.
