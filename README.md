# railgun's Dotfiles — Debian + Home Manager

This is a standalone **home-manager** configuration for Debian with MATE as
the desktop environment. Everything user-level — shell, terminals, editors,
development tools, GUI apps, theming — is declared in nix and applied with one
command. MATE itself is installed and configured manually through Debian.

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
| Browser | Floorp (Firefox fork) |
| Theme engine | Stylix — generates color scheme from wallpaper, applies to terminals, Qt apps, Anki, etc. |
| Fonts | Terminess Nerd Font (mono), Overpass Nerd Font (sans), Tinos Nerd Font (serif) |
| Notifications | Dunst |
| Email | Thunderbird |
| Dev tools | Rust, Python (uv), Node, C/C++, Nix LSP, Docker |
| Secrets | SOPS-nix (encrypted with age) |
| Backups | BorgBackup |
| Emulation | RetroArch with cores |

## What's managed by Debian/MATE

| Category | Handled by |
|----------|-----------|
| Desktop session | MATE (installed via `apt`) |
| Panel, applets | MATE Control Center |
| GTK theming | MATE Appearance settings |
| Screen lock | MATE Screensaver |
| Power management | MATE Power Manager |
| Audio stack | PipeWire or PulseAudio via `apt` |
| NVIDIA drivers | Debian non-free |
| VPN | PIA official client |

---

## Quick start

See **[docs/debian-setup.md](docs/debian-setup.md)** for the full walkthrough.
The short version:

```bash
# 1. Install nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# 2. Enable flakes
echo "experimental-features = nix command flakes" >> ~/.config/nix/nix.conf

# 3. Set up age key at /etc/sops/age/keys.txt (see docs/secrets.md)

# 4. Clone and apply
git clone https://github.com/railgun210/nixos-dotfiles ~/GitRepos/nixos-dotfiles
cd ~/GitRepos/nixos-dotfiles && git checkout Debian
nix run home-manager/release-25.11 -- switch --flake .#railgun

# 5. Set zsh as default shell
echo "$HOME/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
chsh -s "$HOME/.nix-profile/bin/zsh"
```

After the initial `switch`, subsequent rebuilds use:

```bash
home-manager switch --flake ~/GitRepos/nixos-dotfiles#railgun
```

---

## Folder structure

```
nixos-dotfiles/
├── flake.nix                       # Standalone home-manager flake
├── secrets/                        # SOPS-encrypted secrets (age keys)
│   ├── secrets.yaml                # RetroAchievements + Anki credentials
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
    │   ├── default-apps.nix        # XDG MIME associations (Office formats → LibreOffice)
    │   ├── development-tools.nix   # Rust, Python, C/C++, Nix LSP
    │   ├── devshells/              # Isolated dev environments (`nix develop`)
    │   │   ├── c-general-devshell.nix
    │   │   ├── ml-devshell.nix     # numpy, pandas, sklearn, jupyterlab (`ml-dev`)
    │   │   ├── python-devshell.nix
    │   │   └── rust-devshell.nix
    │   ├── doom.nix                # Doom Emacs via nix-doom-emacs-unstraightened
    │   ├── ghostty.nix             # Primary terminal
    │   ├── kitty.nix               # Backup terminal
    │   ├── floorp.nix              # Floorp browser config
    │   ├── vscode.nix              # VSCode with extensions
    │   ├── thunderbird.nix         # Email client
    │   ├── anki.nix                # Spaced repetition + AnkiWeb sync (via sops)
    │   ├── retroarch.nix           # RetroArch emulation + RetroAchievements
    │   ├── borg-backup.nix         # Automated backups
    │   ├── dunst.nix               # Notification daemon
    │   ├── ssh.nix                 # SSH config + sops-managed GitHub key
    │   └── zsh.nix                 # Zsh shell + Powerlevel10k
    │
    └── desktops/
        └── mate/
            └── default.nix         # Extra utilities that complement the MATE session
```

---

## Editors

### Doom Emacs

Managed via [nix-doom-emacs-unstraightened](https://github.com/marienz/nix-doom-emacs-unstraightened),
which builds Doom from Nix — no separate `doom sync` needed. The Doom config
lives in [railgun210/doom-emacs](https://github.com/railgun210/doom-emacs) and
is pulled as a flake input. Fast builds come from the
[nix-doom-emacs-unstraightened Cachix cache](https://app.cachix.org/cache/doom-emacs-unstraightened).

### Vanilla Neovim

A zero-plugin Neovim is always available for quick edits. `EDITOR` and
`VISUAL` both point to `emacsclient`, but Neovim is there when you need
something fast without starting a daemon.

---

## Theming (Stylix)

Stylix generates a 16-color base16 palette from the wallpaper declared in
`home-manager/theming/stylix.nix` and applies it to: Kitty, Dunst, Qt apps,
Anki, and Neovide. GTK theming is intentionally disabled — MATE controls that.

Fonts are also declared in `stylix.nix`:

| Role | Font |
|------|------|
| Monospace | Terminess Nerd Font Mono |
| Sans-serif | Overpass Nerd Font Mono |
| Serif | Tinos Nerd Font |
| Emoji | Noto Color Emoji |

VSCode uses the [Turbo C 3.0](https://marketplace.visualstudio.com/items?itemName=WatkinsLabs.turboc-3-0-theme)
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

Secrets (SSH keys, AnkiWeb sync key, RetroAchievements credentials) are
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
| [docs/debian-setup.md](docs/debian-setup.md) | Full Debian + nix + MATE install walkthrough |
| [docs/devshells.md](docs/devshells.md) | How to use the isolated dev environments |
| [docs/secrets.md](docs/secrets.md) | SOPS age key setup on a new machine |
| [docs/base16-reference.md](docs/base16-reference.md) | Base16 color slot reference for theming |
