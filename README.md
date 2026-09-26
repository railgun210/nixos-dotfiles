# railgun's Dotfiles — Debian + Home Manager

This is a standalone **home-manager** configuration for Debian with GNOME
(Wayland, GDM) as the desktop environment, themed to feel like MATE. Everything
user-level — shell, terminals, editors, development tools, GUI apps, theming,
and GNOME's settings (via dconf) — is declared in nix and applied with one
command. GNOME, GDM and the shell extensions are installed through `apt`.

> **Branch note:** This `Debian` branch targets standalone home-manager on
> Debian. The `main` branch contains the original NixOS + Hyprland
> configuration.

---

## What's managed by nix

| Category | What I use |
|----------|-----------|
| Shell | Zsh + Oh-My-Zsh + Powerlevel10k |
| Terminals | Ghostty (primary), Kitty (backup) |
| Editor | Doom Emacs + vanilla Neovim |
| Browser | Firefox ESR (from `apt`) |
| Theme engine | Stylix — generates color scheme from wallpaper, applies to GNOME, GTK, terminals, Qt apps, etc. |
| Desktop settings | GNOME extensions, icons, workspaces and font rendering via `dconf.settings` |
| Fonts | Terminess Nerd Font (mono), Overpass Nerd Font (sans), Tinos Nerd Font (serif) |
| Notifications | GNOME Shell (system) |
| Email | Thunderbird |
| Dev tools | Rust, Python (uv), Node, C/C++, Nix LSP, Docker |
| Secrets | SOPS-nix (encrypted with age) |
| Backups | BorgBackup |
| Emulation | RetroArch with cores |

## What's managed by Debian/GNOME

| Category | Handled by |
|----------|-----------|
| Desktop session | GNOME Classic on Wayland (installed via `apt`) |
| Alternate session | i3 on X11 — `i3-wm`, `i3lock`, `xss-lock`, `picom` via `apt`; configs from nix |
| Login screen | GDM |
| GNOME Shell extensions | Installed via `apt`, enabled from nix |
| Screen lock, power management | GNOME Settings |
| Audio stack | PipeWire or PulseAudio via `apt` |
| NVIDIA drivers | Debian non-free |
| VPN | PIA official client |

---

## Quick start

Run the interactive bootstrap script — it handles everything from Nix installation
through the first `home-manager switch`:

```bash
git clone https://github.com/railgun210/nixos-dotfiles ~/GitRepos/nixos-dotfiles
cd ~/GitRepos/nixos-dotfiles && git checkout Debian
bash scripts/bootstrap.sh
```

The script will prompt you for your **sops age private key** (needed to decrypt
secrets) and walk through each step with clear output. It is idempotent — safe to
re-run if something fails partway through.

See **[docs/debian-setup.md](docs/debian-setup.md)** for the full manual walkthrough
and **[docs/secrets.md](docs/secrets.md)** for age key setup details.

After the initial switch, subsequent rebuilds use:

```bash
home-manager switch --flake ~/GitRepos/nixos-dotfiles#railgun
```

---

## Folder structure

```
nixos-dotfiles/
├── flake.nix                       # Standalone home-manager flake
├── scripts/
│   └── bootstrap.sh                # Interactive Debian Trixie setup script
├── secrets/                        # SOPS-encrypted secrets (age keys)
│   ├── secrets.yaml                # RetroAchievements + (unused) Anki credentials
│   ├── github-ssh-key.age          # SSH private key
│   └── github-ssh-key.pub          # SSH public key
│
└── home-manager/                   # Everything managed by home-manager
    ├── home.nix                    # Entry point — imports theming, utilities, desktops
    ├── wallpapers/                 # Wallpapers; also synced to ~/Wallpapers/
    │
    ├── theming/                    # Loaded first so colors/fonts propagate everywhere
    │   ├── stylix.nix              # Wallpaper, color scheme, font declarations
    │   ├── font-settings.nix       # Font sizes and per-context overrides
    │   └── fastfetch/              # System info display (logo + modules)
    │
    ├── utilities/                  # User applications and CLI tools
    │   ├── common-packages.nix     # Main app list (gimp, vlc, bat, eza, lazygit, etc.)
    │   ├── default-apps.nix        # XDG MIME associations (Office formats → apt LibreOffice)
    │   ├── development-tools.nix   # Rust, Python, C/C++, Nix LSP
    │   ├── devshells/              # Isolated dev environments (`nix develop`)
    │   │   ├── c-general-devshell.nix
    │   │   ├── ml-devshell.nix     # numpy, pandas, sklearn, jupyterlab (`ml-dev`)
    │   │   ├── python-devshell.nix
    │   │   └── rust-devshell.nix
    │   ├── doom.nix                # Installs plain emacs (Doom managed manually)
    │   ├── ghostty.nix             # Primary terminal
    │   ├── kitty.nix               # Backup terminal
    │   ├── vscode.nix              # VSCode with Everforest Dark theme
    │   ├── thunderbird.nix         # Email client
    │   ├── retroarch.nix           # RetroArch emulation + RetroAchievements
    │   ├── borg-backup.nix         # Automated backups
    │   ├── ssh.nix                 # SSH config + sops-managed GitHub key
    │   └── zsh.nix                 # Zsh shell + Powerlevel10k
    │
    └── desktops/
        ├── gnome/
        │   └── default.nix         # GNOME dconf settings, extensions, Wayland env
        └── i3/                     # Alternate i3 (X11) session, see below
            ├── i3.nix              # Keybindings, workspaces, autostart, i3bar
            ├── i3status.nix        # Status line, Stylix colours
            ├── dmenu.nix           # dmenu-themed, desktop-launcher, powermenu-dmenu
            ├── picom.nix           # Compositor config (picom from apt)
            ├── conky.nix           # System/weather panel (key from sops)
            └── dunst.nix           # Notifications (Stylix colours)
```

---

## i3 session (alternate)

GNOME stays the default desktop. Pick **i3** from the gear menu on GDM's
login screen to get an X11 i3 session instead. It is themed from the same
Stylix palette: window borders, the stock i3bar + i3status, dmenu, dunst and
conky all recolour when `stylix.image` in `theming/stylix.nix` changes and
`home-manager switch` runs (i3 reloads itself).

| Key | Action |
|-----|--------|
| `Super+d` | App launcher (dmenu over .desktop files) |
| `Super+t` / `Super+Enter` | Ghostty |
| `Super+Shift+x` | Power menu (Shutdown / Restart / Suspend / Lock / Logout) |
| `Super+x` | Lock (i3lock with the wallpaper) |
| `Super+j/k/l/;` | Focus left/down/up/right (add Shift to move) |
| `Super+1..0` | Workspaces 1–10 (add Shift to move the window) |
| `Super+s` | Screenshot a region to the clipboard |
| `Super+Shift+a` | Anki (same as GNOME) |
| `Super+Shift+.` | Smile emoji picker (same as GNOME) |
| `Super+Shift+[` / `]` | Move window to previous / next workspace |
| `Super+q` | Close window |

Needs `sudo apt install i3-wm i3lock xss-lock picom` (see
[docs/debian-setup.md](docs/debian-setup.md)). Home Manager never sets
`xsession.enable`, so nothing it writes is read by the GNOME session.

---

## Editors

### Doom Emacs

Nix installs the `emacs` package; Doom itself is managed manually. Clone the
config from [railgun210/doom-emacs](https://github.com/railgun210/doom-emacs)
(use the `debian` branch) and run `doom sync` after cloning. This keeps Doom
upgrades and package management under Doom's own control rather than Nix.

### Vanilla Neovim

A zero-plugin Neovim is always available for quick edits. `EDITOR` and
`VISUAL` both point to `emacsclient`, but Neovim is there when you need
something fast without starting a daemon.

---

## Theming (Stylix)

Stylix generates a 16-color base16 palette from the wallpaper declared in
`home-manager/theming/stylix.nix` and applies it to: Kitty, Dunst, Qt apps,
and Neovide. GNOME's wallpaper, fonts and colour scheme come from
Stylix's own GNOME target.

Fonts are also declared in `stylix.nix`:

| Role | Font |
|------|------|
| Monospace | Terminess Nerd Font Mono |
| Sans-serif | Overpass Nerd Font Mono |
| Serif | Tinos Nerd Font |
| Emoji | Noto Color Emoji |

VSCode uses the [Everforest Dark](https://marketplace.visualstudio.com/items?itemName=sainnhe.everforest)
theme and is excluded from Stylix.

---

## Dev shells

Isolated development environments activated with `nix develop`:

| Shell | Command | What's in it |
|-------|---------|-------------|
| Python | `nix develop .#python` | uv, ruff, ipython |
| Rust | `nix develop .#rust` | rustc, cargo, clippy, rust-analyzer |
| C/General | `nix develop .#c-general` | gcc, clang, cmake, gdb, lldb |
| ML | `nix develop .#ml` | numpy, pandas, sklearn, scipy, matplotlib, jupyterlab |

See [docs/devshells.md](docs/devshells.md) for details.

---

## Secrets

Secrets (SSH keys, RetroAchievements credentials) are
encrypted with [SOPS](https://github.com/getsops/sops) using an age key. The
encrypted files live in `secrets/` and are safe to commit.

Edit a secret:

```bash
export EDITOR="emacsclient -a ''"
sops secrets/secrets.yaml
```

See [docs/secrets.md](docs/secrets.md) for age key setup on a new machine.

---

## Gaming

Gaming packages (Steam, RetroArch, MangoHud, GOverlay) are managed by
home-manager and work on Debian without any special configuration. Steam with
Proton runs Windows games. Gamescope is available but requires the session to
support it.

RetroArch cores included: Mesen (NES), bsnes-hd + snes9x (SNES), mupen64plus
(N64), beetle-psx-hw (PS1), pcsx2 (PS2), Dolphin (GCN/Wii), mGBA (GBA),
Flycast (Dreamcast), beetle-saturn (Saturn). RetroAchievements credentials come
from sops and are seeded into the RetroArch config at activation.

---

## Documentation

| Doc | What's in it |
|-----|-------------|
| [docs/debian-setup.md](docs/debian-setup.md) | Full Debian + nix + GNOME install walkthrough |
| [docs/devshells.md](docs/devshells.md) | How to use the isolated dev environments |
| [docs/secrets.md](docs/secrets.md) | SOPS age key setup on a new machine |
| [docs/base16-reference.md](docs/base16-reference.md) | Base16 color slot reference for theming |
