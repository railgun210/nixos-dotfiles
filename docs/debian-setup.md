# Debian + Home Manager Setup

This guide covers everything that cannot be managed by nix: installing Debian,
setting up GNOME (Wayland, GDM), installing nix itself, and then wiring in home-manager so the
rest of the configuration takes over.

---

## 1. Install Debian

Boot the Debian installer. During software selection (tasksel), check
**standard system utilities** only; GNOME is installed by hand in section 7 so
it can be kept minimal. (Checking **GNOME** here also works, but pulls in the
full `gnome-core` app set.)

After install, do a basic system update:

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Install NVIDIA drivers (if applicable)

On Debian 13 (Trixie) the installer only enables `non-free-firmware`, so
`nvidia-driver` shows "has no installation candidate" until you also enable
`contrib` and `non-free` in `/etc/apt/sources.list`:

```bash
sudo sed -i -E '/^deb/ s/ main non-free-firmware$/ main contrib non-free non-free-firmware/' /etc/apt/sources.list
sudo apt update
sudo apt install linux-headers-amd64 nvidia-driver nvidia-driver-libs:i386 firmware-misc-nonfree
sudo reboot
```

The `nvidia-driver` package from `non-free` installs the proprietary driver.
`nvidia-driver-libs:i386` provides the 32-bit GL libraries that 32-bit Steam
needs: the driver's `glx-diversions` moves Mesa's 32-bit `libGL.so.1` aside, so
without it Steam dies with `steamui.so failed: libGL.so.1: wrong ELF class`.
(Requires `sudo dpkg --add-architecture i386` first.)
Confirm the GPU is working after reboot:

```bash
nvidia-smi
```

### Enable DRM modesetting (required for GNOME on Wayland)

Debian's NVIDIA packages leave `nvidia-drm` modesetting off, and GDM then
silently falls back to Xorg. Turn it on and rebuild the initramfs:

```bash
echo 'options nvidia-drm modeset=1 fbdev=1' | sudo tee /etc/modprobe.d/nvidia-drm-modeset.conf
sudo update-initramfs -u
sudo reboot
```

After the reboot this must print `Y`:

```bash
sudo cat /sys/module/nvidia_drm/parameters/modeset
```

---

## 3. Install nix (multi-user)

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

After install, open a new shell or source the profile:

```bash
. /etc/profile.d/nix.sh
```

Enable flakes by creating `~/.config/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

---

## 4. Set up the age key for secrets

The sops-nix home-manager module decrypts secrets at activation. The age
private key must be in place before running `home-manager switch`.

If you already have the key, copy it:

```bash
sudo mkdir -p /etc/sops/age
sudo cp your-age-key.txt /etc/sops/age/keys.txt
sudo chmod 600 /etc/sops/age/keys.txt
```

If this is a new machine, generate a new key and re-encrypt the secrets
with it:

```bash
age-keygen -o ~/.config/age/keys.txt
# get the public key:
age-keygen -y ~/.config/age/keys.txt
```

Then update `.sops.yaml` (or the relevant `creation_rules`) in the repo
with the new public key, and re-encrypt:

```bash
sops updatekeys secrets/secrets.yaml
sops updatekeys secrets/github-ssh-key.age
# ... repeat for each secret file
```

See [secrets.md](secrets.md) for more detail.

---

## 5. Clone the repo and apply home-manager

```bash
git clone https://github.com/railgun210/nixos-dotfiles ~/GitRepos/nixos-dotfiles
cd ~/GitRepos/nixos-dotfiles
git checkout Debian
```

Run home-manager for the first time:

```bash
nix run home-manager/release-25.11 -- switch --flake .#railgun
```

On subsequent runs, use the `home-manager` command that is now on your PATH:

```bash
home-manager switch --flake ~/GitRepos/nixos-dotfiles#railgun
```

---

## 6. Change your default shell to zsh

The nix-managed zsh binary lives outside `/etc/shells` by default. Add it and
switch:

```bash
echo "$HOME/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
chsh -s "$HOME/.nix-profile/bin/zsh"
```

Log out and back in for the change to take effect.

---

## 7. Install GNOME (GDM, Wayland)

Install a minimal GNOME Classic session plus the extensions the nix config
enables. Choose **gdm3** if the installer asks which display manager to use:

```bash
sudo apt install \
  gdm3 gnome-session gnome-classic gnome-shell-extensions \
  gnome-shell-extension-appindicator gnome-shell-extension-desktop-icons-ng \
  gnome-shell-extension-user-theme gnome-tweaks \
  nautilus gnome-control-center gnome-terminal file-roller loupe papers \
  gnome-system-monitor xdg-desktop-portal-gnome
sudo systemctl enable gdm3
```

Run `sudo dpkg-reconfigure gdm3` if LightDM is still the active display
manager, then reboot. At the GDM login screen click the gear icon and pick
**GNOME Classic** (Wayland). After `home-manager switch` the extensions,
icons, workspaces and font rendering are configured automatically.

Optionally remove MATE and LightDM once GNOME works:

```bash
sudo apt purge lightdm lightdm-gtk-greeter
sudo apt autoremove --purge
```

GNOME's own settings (keyboard shortcuts, power, lock screen) are managed in
**GNOME Settings**; the pieces declared in
`home-manager/desktops/gnome/default.nix` are re-applied on every switch.

### Optional: i3 as a second session

`home-manager/desktops/i3/` configures an i3 (X11) session next to GNOME. Only
the pieces that need root live in apt: the GDM session entry, the PAM-backed
screen locker and the compositor (which uses Debian's NVIDIA GL directly).

```bash
sudo apt install i3-wm i3lock xss-lock picom
# optional: Bluetooth tray icon
sudo apt install blueman
```

`mate-polkit` (polkit agent) and `network-manager-gnome` (nm-applet) are
already installed. Everything else (dmenu, i3status, conky, dunst, feh, ...)
comes from nix. At the GDM login screen click the gear icon and pick **i3**;
GNOME stays the default and is not changed by the i3 module.

---

## 8. PIA VPN

PIA is not managed by nix on Debian. Download and install the official client:

```bash
wget https://installers.privateinternetaccess.com/download/pia-linux-<version>.run
chmod +x pia-linux-<version>.run
sudo ./pia-linux-<version>.run
```

---

## 9. Login screen

GDM's greeter is GNOME Shell itself and is not themed by Stylix on Debian.
Its wallpaper and colours stay at the Debian defaults unless changed manually
for the `gdm` user.

---

## 10. Rebuilding after changes

```bash
home-manager switch --flake ~/GitRepos/nixos-dotfiles#railgun
```

To update all flake inputs:

```bash
nix flake update
home-manager switch --flake ~/GitRepos/nixos-dotfiles#railgun
```
