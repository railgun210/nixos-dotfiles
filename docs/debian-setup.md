# Debian + Home Manager Setup

This guide covers everything that cannot be managed by nix: installing Debian,
setting up MATE, installing nix itself, and then wiring in home-manager so the
rest of the configuration takes over.

---

## 1. Install Debian

Boot the Debian installer. During software selection (tasksel), check
**MATE desktop environment** and **standard system utilities**. Uncheck
everything else unless you have a specific reason to include it.

After install, do a basic system update:

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Install NVIDIA drivers (if applicable)

Add non-free and contrib to your sources list, then:

```bash
sudo apt install nvidia-driver firmware-misc-nonfree
sudo reboot
```

For Debian 12+, the `nvidia-driver` package from `non-free` installs the
proprietary driver. Confirm the GPU is working after reboot:

```bash
nvidia-smi
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
experimental-features = nix command flakes
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

## 7. MATE configuration (manual)

MATE is intentionally left unmanaged by nix. Configure these through the
**MATE Control Center** and the panel right-click menu:

- **Panel layout** — add/remove applets, move/resize panels
- **Keyboard shortcuts** — MATE's own shortcut system for window management
- **Appearance** — GTK theme, icon theme, window borders, fonts in MATE apps
- **Screensaver / lock screen** — MATE Screensaver settings
- **Power management** — idle timeout, suspend behavior via MATE Power Manager
- **Default apps** — MATE preferred applications dialog

---

## 8. PIA VPN

PIA is not managed by nix on Debian. Download and install the official client:

```bash
wget https://installers.privateinternetaccess.com/download/pia-linux-<version>.run
chmod +x pia-linux-<version>.run
sudo ./pia-linux-<version>.run
```

---

## 9. Starting Polkit

The nix config installs `polkit_gnome` as a polkit agent. You need to
autostart it in your MATE session. In **MATE Session > Startup Programs**, add:

```
/run/current-system/sw/bin/...
```

Actually, since this is nix-managed, the binary path is:

```bash
$(which polkit-gnome-authentication-agent-1)
```

Add that to your MATE autostart applications list.

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
