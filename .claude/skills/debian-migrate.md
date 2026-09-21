# Debian Migration Plan

> **Status: implemented** — all steps below have been applied to the `Debian`
> branch. This file remains as a reference for what changed and why.
>
> **Superseded:** the desktop later moved from MATE to GNOME (Wayland, GDM).
> `desktops/mate/` no longer exists; see `desktops/gnome/default.nix` and
> `docs/debian-setup.md`. MATE-specific notes below are historical.

Convert this NixOS dotfiles repo into a standalone **home-manager** setup that
runs on Debian with MATE as the desktop environment. MATE itself is installed
and configured manually via `apt`; home-manager manages everything else.

---

## Goals

1. Replace the NixOS system configuration with a standalone home-manager flake.
2. Keep all non-Hyprland packages and program configurations.
3. Drop Wayland/Hyprland-only components; MATE handles the desktop session.
4. Stylix manages fonts, wallpaper, and color schemes — but does **not** theme
   GTK (MATE owns that).
5. The `desktops/mate/` module installs extra utilities that complement MATE;
   it does not configure MATE at all (no XDG autostart, no dconf, no panel).

---

## What changed

### `flake.nix` — rewritten as standalone home-manager flake

Dropped:
- `lanzaboote` (Secure Boot — NixOS kernel concern)
- `pia` input (PIA VPN NixOS module)
- `winapps` input (NixOS-only)
- `nixosConfigurations` output

Kept:
- `nixpkgs`, `home-manager`, `sops-nix`, `stylix`
- `cozette`, `hm-ricing-mode`, `buuf-icon-theme` (theming)
- `nix-doom-emacs-unstraightened`, `doomdir` (editor)

Added:
- `homeConfigurations."railgun"` using
  `home-manager.lib.homeManagerConfiguration`
- Explicit `pkgs = import nixpkgs { ... overlays ... config.allowUnfree = true }`

### `home-manager/home.nix` — updated for standalone use

Added:
- `targets.genericLinux.enable = true` — required on non-NixOS

Removed:
- `osConfig` argument reference
- NixOS-specific comment

### `home-manager/theming/stylix.nix` — GTK and Wayland targets disabled

- `image` now points directly to a wallpaper in the repo (no `osConfig`)
- `targets.gtk.enable = false` — MATE manages GTK theming
- `gtk { }` block removed
- `dconf.settings` (gnome button layout) removed
- `home.pointerCursor.gtk.enable = false`, `x11.enable = true`
- `targets.waybar.enable = false`, `targets.hyprlock.enable = false`
- `targets.kde.enable = false`

### `home-manager/desktops/` — restructured

Deleted:
- `desktops/hyprland/` (all files)
- `desktops/components/` (Waybar, bemenu, screenshot)
- `desktops/common-packages.nix` (Wayland-only packages)

Created:
- `desktops/mate/default.nix` — X11 utility packages: flameshot, xclip,
  xdotool, brightnessctl, file-roller, eog, polkit_gnome

### `system/` — deleted entirely

All NixOS system modules removed. Secrets moved to `secrets/` at repo root.

### `secrets/` — moved from `system/secrets/`

All sops secret files (`github-ssh-key.age`, `github-ssh-key.pub`,
`secrets.yaml`, `pia.age`, `weather-api-key.age`) are now at `secrets/`.

Secret path references updated in:
- `utilities/ssh.nix`
- `utilities/retroarch.nix`
- `utilities/anki.nix`

### `docs/` — updated

Removed: `hyprland-animations.md`, `virtualisation-winapps.md`
Added: `debian-setup.md` — full Debian + nix + MATE install walkthrough

### `README.md` — rewritten for Debian branch

---

## Remaining manual steps (not managed by nix)

1. Install Debian with MATE (tasksel)
2. Install NVIDIA drivers via `apt` if needed
3. Install nix daemon: `sh <(curl -L https://nixos.org/nix/install) --daemon`
4. Enable flakes in `~/.config/nix/nix.conf`
5. Place age private key at `/etc/sops/age/keys.txt`
6. Run `nix run home-manager/release-25.11 -- switch --flake .#railgun`
7. `chsh` to the nix-managed zsh
8. Configure MATE panel, appearance, shortcuts via MATE Control Center
9. Install PIA VPN via their official `.run` installer
10. Add polkit agent to MATE autostart (path: `polkit-gnome-authentication-agent-1`)

See [docs/debian-setup.md](../docs/debian-setup.md) for the full walkthrough.
