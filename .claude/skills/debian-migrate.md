# Debian Migration Plan

Convert this NixOS dotfiles repo into a standalone **home-manager** setup that runs on
Debian with MATE as the desktop environment. MATE itself is installed and configured
manually via `apt`; home-manager manages everything else.

---

## Goals

1. Replace the NixOS system configuration with a standalone home-manager flake.
2. Keep all non-Hyprland packages and program configurations.
3. Drop Wayland/Hyprland-only components; MATE handles the desktop session.

---

## Branch

All work lives on the `Debian` branch (already created).

---

## New Repo Structure

```
flake.nix                        ← standalone home-manager flake (rewrite)
home-manager/
  home.nix                       ← new entry point (targets.genericLinux)
  utilities/                     ← keep almost everything as-is
  theming/                       ← keep stylix for terminal/app theming
  desktops/
    mate/                        ← NEW: MATE-specific nix bits
      default.nix
      autostart.nix              ← XDG autostart for apps that need it
      app-defaults.nix           ← XDG MIME associations
    components/
      dunst/                     ← keep (works on X11)
      screenshot.nix             ← replace with scrot/flameshot
      (drop bar/, bemenu/)
system/                          ← DELETE entire directory (NixOS-only)
docs/
  debian-setup.md                ← NEW: manual Debian/MATE setup instructions
```

---

## Step 1 — Rewrite `flake.nix`

The current flake uses `nixosConfigurations`. Replace it with
`homeConfigurations` using `home-manager.lib.homeManagerConfiguration`.

Drop inputs:
- `lanzaboote` (Secure Boot — NixOS kernel concern)
- The NixOS `nixosConfigurations` output entirely

Keep inputs:
- `nixpkgs` (nixpkgs-unstable or 25.11 — pick one)
- `home-manager`
- `stylix`
- `nix-doom-emacs-unstraightened`
- `sops-nix` (home-manager module still works standalone)

New `flake.nix` skeleton:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    doom-emacs.url = "github:marienz/nix-doom-emacs-unstraightened";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { nixpkgs, home-manager, stylix, doom-emacs, sops-nix, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations."railgun" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit doom-emacs; };
      modules = [
        stylix.homeManagerModules.stylix
        sops-nix.homeManagerModules.sops
        ./home-manager/home.nix
      ];
    };
  };
}
```

---

## Step 2 — Rewrite `home-manager/home.nix`

Key changes from the current version:

```nix
# ADD — required for home-manager on non-NixOS
targets.genericLinux.enable = true;

# KEEP
home.username = "railgun";
home.homeDirectory = "/home/railgun";
home.stateVersion = "25.11";

# KEEP these imports
imports = [
  ./utilities
  ./theming
  ./desktops/mate
];

# REMOVE the hyprland desktop import
# REMOVE any NixOS-specific sessionVariables that only make sense there
# KEEP: EDITOR, TERMINAL, BROWSER session vars
```

---

## Step 3 — What to Keep (utilities/)

Keep all of these files with little or no modification:

| File | Notes |
|------|-------|
| `utilities/zsh.nix` | No changes needed |
| `utilities/ghostty.nix` | Works on X11/MATE |
| `utilities/kitty.nix` | Works on X11/MATE |
| `utilities/vscode.nix` | No changes needed |
| `utilities/doom.nix` | No changes needed |
| `utilities/development-tools.nix` | No changes needed |
| `utilities/devshells/` | No changes needed |
| `utilities/common-packages.nix` | No changes needed |
| `utilities/anki.nix` | No changes needed |
| `utilities/borg-backup.nix` | No changes needed |
| `utilities/dunst.nix` | Works on X11 |
| `utilities/floorp.nix` | No changes needed |
| `utilities/thunderbird.nix` | No changes needed |
| `utilities/retroarch.nix` | No changes needed |
| `utilities/ssh.nix` | See secrets note below |

Minor edits needed:

- `utilities/default-apps.nix` — remove Wayland-specific MIME entries if any;
  MATE's own file manager/apps will handle most associations.
- `utilities/common-packages.nix` — remove any Wayland-only CLI tools
  (`wl-clipboard`, `wljoywake`, etc.). Add `xclip` or `xdotool` as X11
  equivalents where needed.

---

## Step 4 — What to Drop

Delete or leave unimported:

| Path | Reason |
|------|--------|
| `system/` (entire dir) | NixOS system config — not applicable on Debian |
| `desktops/hyprland/` | Hyprland WM — replaced by MATE |
| `desktops/components/bar/` | Waybar — Wayland-only; MATE has its own panel |
| `desktops/components/bemenu/` | Wayland launcher; use MATE's built-in or rofi |
| `desktops/hyprland/hyprlock.nix` | Hyprlock — use MATE Screensaver instead |
| `desktops/hyprland/hypridle.nix` | Hypridle — MATE Power Manager handles idle |

---

## Step 5 — New `desktops/mate/` Module

MATE is installed via `apt`. The nix module only manages things home-manager
can own: XDG autostart entries and application defaults.

**`desktops/mate/default.nix`**
```nix
{ ... }: {
  imports = [
    ./autostart.nix
    ./app-defaults.nix
  ];
}
```

**`desktops/mate/autostart.nix`**

Use `xdg.configFile` to drop `.desktop` files in `~/.config/autostart/` for
apps that aren't system services:

- Maestral (Dropbox sync daemon)
- Thunderbird (mail client)
- Dunst (notification daemon — if not started by MATE session)
- playerctld (media key daemon)

Example entry:
```nix
xdg.configFile."autostart/maestral.desktop".text = ''
  [Desktop Entry]
  Type=Application
  Name=Maestral
  Exec=maestral gui
  Hidden=false
  X-GNOME-Autostart-enabled=true
'';
```

**`desktops/mate/app-defaults.nix`**

Port `utilities/default-apps.nix` XDG MIME associations to work with
MATE/X11 apps (Atril for PDF, Thunar for files, Floorp for web, etc.).

---

## Step 6 — Theming

Stylix works as a standalone home-manager module — no NixOS system module
needed. Keep `theming/stylix.nix` as-is. It will continue to theme:

- Terminal colors (Ghostty, Kitty)
- VS Code color scheme
- Dunst colors
- Doom Emacs theme
- GTK theme (important for MATE — stylix generates GTK 2/3/4 themes)

Drop from theming:
- Any import of `stylix.nixosModules.stylix` (that was system-level)
- The `system/stylix.nix` file entirely

---

## Step 7 — Secrets

`sops-nix` has a home-manager module (`sops-nix.homeManagerModules.sops`)
that works without NixOS. It still uses age keys for decryption.

Keep:
- The `.sops.yaml` file
- The `secrets/` directory structure
- `home-manager/utilities/ssh.nix` pattern for injecting keys

Change:
- Remove `system/secrets.nix` (was NixOS-level)
- Ensure age key is available at `~/.config/sops/age/keys.txt` on Debian

For initial Debian setup, secrets can be bootstrapped manually before
running `home-manager switch`.

---

## Step 8 — Manual Debian Setup (`docs/debian-setup.md`)

Create a short guide for the parts nix cannot manage:

1. **Install Debian** with MATE desktop environment selected in tasksel.
2. **Install nix** (single-user or multi-user):
   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```
3. **Enable flakes** in `~/.config/nix/nix.conf`:
   ```
   experimental-features = nix command flakes
   ```
4. **Install home-manager** channel or use the flake directly:
   ```bash
   nix run home-manager -- init --switch
   # then replace generated config with this repo
   ```
5. **Clone this repo** and apply:
   ```bash
   git clone <repo> ~/nixos-dotfiles
   cd ~/nixos-dotfiles
   nix run home-manager -- switch --flake .#railgun
   ```
6. **Set zsh as default shell** (nix-managed zsh needs manual `chsh`):
   ```bash
   echo "$HOME/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
   chsh -s "$HOME/.nix-profile/bin/zsh"
   ```
7. **MATE customization** (manual — outside nix scope):
   - Panel layout, applets, and keyboard shortcuts via MATE Control Center
   - Screen resolution / DPI settings
   - Login screen (LightDM) theme
   - NVIDIA driver via `apt` or Debian backports
8. **PIA VPN** — install the official PIA client via their `.run` installer;
   not managed by nix on Debian.
9. **Age key** — copy your age private key to `~/.config/sops/age/keys.txt`
   before running `home-manager switch` if using sops secrets.

---

## Package Mapping: NixOS system → Debian apt + nix

Packages previously in `system/base-packages.nix` or other system modules
that should move to home-manager `home.packages` or be installed via apt:

| Package | Move to |
|---------|---------|
| `bash` | Debian base (always present) |
| `zsh` | `home.packages` in nix |
| `fastfetch` | `home.packages` in nix |
| `git` | `programs.git` in nix |
| `curl`, `wget` | `home.packages` in nix |
| `htop`, `btop` | `home.packages` in nix |
| PipeWire / audio stack | Debian MATE install (via apt) |
| NVIDIA driver | Debian backports / apt |
| Bluetooth | Debian base (`blueman` via apt or nix) |
| Fonts (system-wide) | `home.packages` (nix manages user fonts via `~/.local/share/fonts`) |
| Printing (CUPS) | Debian (`sudo apt install cups`) |
| Gaming (Steam) | `home.packages` in nix OR steam flatpak |

---

## Implementation Order

1. [ ] Rewrite `flake.nix` as standalone home-manager flake
2. [ ] Rewrite `home-manager/home.nix` (add `targets.genericLinux`, remove hyprland import)
3. [ ] Create `desktops/mate/` module (autostart + app defaults)
4. [ ] Audit `utilities/common-packages.nix` — remove Wayland-only packages
5. [ ] Update `utilities/default-apps.nix` for X11/MATE
6. [ ] Delete `system/` directory
7. [ ] Delete `desktops/hyprland/` and Wayland bar/bemenu components
8. [ ] Create `docs/debian-setup.md` with manual setup steps
9. [ ] Test: `nix flake check` on the new flake
10. [ ] Test: `home-manager switch --flake .#railgun` on a Debian VM
