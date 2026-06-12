# dotfiles

Personal Linux dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

**Stack:** Ubuntu 26.04 · Hyprland (Wayland) · ghostty + zsh · Neovim
**Theme:** TokyoNight Storm across the whole environment.

---

## Structure

Each top-level folder is a Stow *package* that mirrors its target layout under `$HOME`:

```
dotfiles/
├── ghostty/      .config/ghostty/        → terminal config + shaders
├── zsh/           .zshrc, .p10k.zsh      → shell (oh-my-zsh + powerlevel10k)
├── tmux/         .config/tmux/           → tmux.conf (plugins via TPM, not committed)
├── hypr/         .config/hypr/           → hyprland, hypridle, hyprlock + Scripts
├── rofi/         .config/rofi/           → config + tokyonight theme
├── waybar/       .config/waybar/         → config.jsonc + style.css
├── environment/  .config/environment.d/  → systemd user PATH (~/.local/bin)
├── thunderbird/  chrome/                 → userChrome/userContent (copied, not stowed)
├── gtk-interface.dconf                   → GTK theme/icons/cursor dump
└── install.sh                            → bootstrap script
```

Running `stow <package>` from the repo root creates symlinks like
`~/.config/hypr/hyprland.conf → ~/dotfiles/hypr/.config/hypr/hyprland.conf`.

> **nvim** is a separate repo: [wnchstrr/nvim-config](https://github.com/wnchstrr/nvim-config).
> `install.sh` clones it into `~/.config/nvim`.

> **thunderbird/** is *not* a stow package — the TB profile directory name is
> machine-generated, so `install.sh` finds the active profile via `profiles.ini`
> and copies the CSS into `<profile>/chrome/` instead of symlinking.

---

## Install (fresh machine)

### 1. SSH key for GitHub

`install.sh` clones the nvim repo over SSH, so set up a key first:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub   # add this to GitHub → Settings → SSH keys
ssh -T git@github.com        # verify
```

If port 22 is blocked, use SSH over 443 — add to `~/.ssh/config`:

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
- copy the Thunderbird userChrome/userContent theme into the active TB profile

### 3. Post-install (manual)

- **tmux:** open tmux, press `prefix + I` to install plugins
- **Thunderbird:** Settings → Config Editor →
  `toolkit.legacyUserProfileCustomizations.stylesheets = true`, then restart TB
  (otherwise userChrome.css is ignored)
- Install the actual programs yourself (see below) — `install.sh` only lays down configs

---

## Dependencies

`install.sh` only creates symlinks and restores settings. Install programs yourself.

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

## Applications (snap-free)

This system runs **without snap**. Snapd is purged and held (`apt-mark hold snapd`).
Install GUI apps via apt / tarball / flatpak instead — snap sandboxing breaks custom
GTK themes and keeps profiles in non-standard paths.

| App | Method | Notes |
|-----|--------|-------|
| Firefox | Mozilla apt repo | needs pinning (below) so apt doesn't pull the snap transitional |
| Thunderbird | tarball → `~/.local/lib/thunderbird` | self-updating; symlink in `~/.local/bin`; theme via this repo |
| Telegram | tarball → `/opt/Telegram` | self-updating; symlink in `/usr/local/bin` |
| Signal | flatpak `org.signal.Signal` | set encrypted backend: `flatpak override --user --env=SIGNAL_PASSWORD_STORE=gnome-libsecret org.signal.Signal` |
| Bitwarden, Discord, Spotify | official `.deb` | Discord/Spotify on Wayland may need `--enable-features=UseOzonePlatform --ozone-platform=wayland` in their `.desktop` |
| speedtest | Ookla apt repo | use `jammy` codename if your release isn't published yet |

### Firefox / Mozilla repo pinning

```bash
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list

# pin so apt always prefers Mozilla over the Ubuntu snap-transitional
sudo tee /etc/apt/preferences.d/mozilla <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000

Package: firefox thunderbird
Pin: release o=Ubuntu
Pin-Priority: -1
EOF

sudo apt update && sudo apt install firefox
```

---

## Usage

```bash
cd ~/dotfiles
stow hypr        # link a single package
stow */          # link all packages
stow -D hypr     # unlink (remove symlinks)
stow -R hypr     # restow (re-link after changes)
```

After editing a config the symlink already points at the repo file — just
`git add` / `commit`. No re-stow needed unless you add new files.

---

## Notes

- Secrets are excluded via `.gitignore` (keys, tokens, `.env`, `*secret*`).
- GTK theme lives in dconf (binary), not a file — dumped to `gtk-interface.dconf`,
  restored by install.sh. Re-dump after changing it:
  `dconf dump /org/gnome/desktop/interface/ > gtk-interface.dconf`
- `hyprpaper.conf` is intentionally absent — wallpaper is set via `swaybg`.
- ghostty ANSI palette is tweaked (`palette = 2/10` green, `3/11` yellow→magenta) —
  see comments in `ghostty/.config/ghostty/config`.
