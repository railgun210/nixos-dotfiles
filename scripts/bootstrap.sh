#!/usr/bin/env bash
# bootstrap.sh — Bootstrap Nix + standalone home-manager on Debian Trixie
#
# Run this on a fresh Debian Trixie install to get the full home-manager
# config applied in one shot. The script is idempotent — safe to re-run.

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${GREEN}[✓]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
error()   { echo -e "${RED}[✗]${RESET} $*" >&2; }
section() { echo -e "\n${CYAN}${BOLD}━━  $*  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }
die()     { error "$*"; exit 1; }

prompt()  {
    # prompt <variable_name> <prompt_text> [default]
    local var="$1" msg="$2" default="${3:-}"
    local display_default=""
    [[ -n "$default" ]] && display_default=" [${default}]"
    echo -en "${BOLD}${msg}${display_default}: ${RESET}"
    read -r "$var"
    # If blank and there's a default, use it
    if [[ -z "${!var}" && -n "$default" ]]; then
        printf -v "$var" '%s' "$default"
    fi
}

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "${CYAN}${BOLD}"
echo "  ┌─────────────────────────────────────────────────┐"
echo "  │  railgun's dotfiles — Debian Trixie bootstrap   │"
echo "  │  Nix + standalone home-manager setup            │"
echo "  └─────────────────────────────────────────────────┘"
echo -e "${RESET}"
echo "This script will:"
echo "  • Install Nix (multi-user daemon)"
echo "  • Enable nix flakes"
echo "  • Set up your sops age decryption key"
echo "  • Clone the nixos-dotfiles repo (Debian branch)"
echo "  • Apply the home-manager config"
echo "  • Set zsh as your default shell"
echo ""
warn "This modifies your system. Root access (sudo) is required."
echo -en "${BOLD}Continue? [y/N]: ${RESET}"
read -r CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# ── 1. Preflight ──────────────────────────────────────────────────────────────
section "Preflight checks"

# OS check
if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    if [[ "${ID:-}" != "debian" ]]; then
        warn "This script targets Debian Trixie. Detected: ${PRETTY_NAME:-unknown}"
        echo -en "${BOLD}Continue anyway? [y/N]: ${RESET}"
        read -r OVERRIDE
        [[ "$OVERRIDE" =~ ^[Yy]$ ]] || die "Aborted — unsupported OS."
    else
        info "OS: ${PRETTY_NAME}"
    fi
else
    warn "Cannot determine OS — /etc/os-release not found. Proceeding anyway."
fi

# User check — config is hardcoded to username "railgun"
CURRENT_USER="$(id -un)"
if [[ "$CURRENT_USER" != "railgun" ]]; then
    die "The home-manager config is hardcoded to username 'railgun' and homedir '/home/railgun'.
  You are logged in as '${CURRENT_USER}'.
  Either log in as 'railgun' or create that user first:
    sudo adduser railgun
    sudo usermod -aG sudo railgun"
fi
info "User: $CURRENT_USER"

# Sudo check
if ! sudo -v 2>/dev/null; then
    die "sudo is not available or you have no sudo rights. Make sure '$CURRENT_USER' is in the sudo group."
fi
info "sudo access confirmed"

# ── 2. APT prerequisites ──────────────────────────────────────────────────────
section "Installing APT prerequisites"

MISSING_PKGS=()
for pkg in curl git xz-utils; do
    dpkg -s "$pkg" &>/dev/null || MISSING_PKGS+=("$pkg")
done

if [[ ${#MISSING_PKGS[@]} -gt 0 ]]; then
    info "Installing: ${MISSING_PKGS[*]}"
    sudo apt-get update -qq
    sudo apt-get install -y "${MISSING_PKGS[@]}"
else
    info "curl, git, xz-utils already installed"
fi

# Internet check (now that curl is guaranteed available)
if ! curl -sf --max-time 10 https://nixos.org > /dev/null; then
    die "No internet access — cannot reach nixos.org. Check your connection."
fi
info "Internet connectivity confirmed"

# ── 3. Install Nix ───────────────────────────────────────────────────────────
section "Installing Nix"

NIX_DAEMON_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

# A previous run (or a fresh terminal) may have Nix installed but not on PATH
if ! command -v nix &>/dev/null && [[ -f "$NIX_DAEMON_PROFILE" ]]; then
    # shellcheck source=/dev/null
    . "$NIX_DAEMON_PROFILE"
fi

if command -v nix &>/dev/null; then
    info "Nix already installed: $(nix --version)"
elif [[ -d /nix/store ]]; then
    die "/nix exists but 'nix' is not usable (is the nix-daemon running?).
  Try: sudo systemctl restart nix-daemon
  Then open a new terminal and re-run this script."
else
    info "Running the Nix multi-user installer..."
    sh <(curl -L https://nixos.org/nix/install) --daemon < /dev/tty

    if [[ -f "$NIX_DAEMON_PROFILE" ]]; then
        # shellcheck source=/dev/null
        . "$NIX_DAEMON_PROFILE"
    fi

    if ! command -v nix &>/dev/null; then
        die "Nix was installed but 'nix' is not in PATH.
  Open a new terminal and re-run this script — it will pick up where it left off."
    fi
    info "Nix installed: $(nix --version)"
fi

# ── 4. Enable flakes ─────────────────────────────────────────────────────────
section "Enabling Nix flakes"

NIX_CONF="$HOME/.config/nix/nix.conf"
FLAKE_LINE="experimental-features = nix-command flakes"

mkdir -p "$(dirname "$NIX_CONF")"
if grep -qxF "$FLAKE_LINE" "$NIX_CONF" 2>/dev/null; then
    info "Flakes already enabled in $NIX_CONF"
else
    # Drop any earlier experimental-features line (e.g. the old misspelled
    # "nix command flakes") so we don't leave a broken one behind
    if grep -q '^experimental-features' "$NIX_CONF" 2>/dev/null; then
        sed -i '/^experimental-features/d' "$NIX_CONF"
        warn "Replaced an existing experimental-features line in $NIX_CONF"
    fi
    echo "$FLAKE_LINE" >> "$NIX_CONF"
    info "Flakes enabled in $NIX_CONF"
fi

# ── 5. sops age key ───────────────────────────────────────────────────────────
section "Setting up sops age key"

AGE_KEY_DIR="/etc/sops/age"
AGE_KEY_FILE="$AGE_KEY_DIR/keys.txt"

# An age secret key is "AGE-SECRET-KEY-1" + 58 bech32 characters (uppercase)
AGE_KEY_REGEX='^AGE-SECRET-KEY-1[QPZRY9X8GF2TVDW0S3JN54KHCE6MUA7L]{58}$'

# Clean up pasted text: drop terminal escape sequences (bracketed paste), CRs,
# and all whitespace/quotes, then uppercase. One cleaned line per input line.
normalize_age_lines() {
    sed -E 's/\x1b\[[0-9;?]*[~A-Za-z]//g' | tr -d '\r' | sed -E "s/[[:space:]\"']//g" | tr 'a-z' 'A-Z'
}

# Print only the valid secret-key line(s) from stdin
extract_age_keys() {
    normalize_age_lines | grep -E "$AGE_KEY_REGEX" || true
}

# Explain (without echoing the secret) why the input was rejected
diagnose_age_input() {
    local text="$1" line len bad
    if printf '%s\n' "$text" | normalize_age_lines | grep -q '^AGE1'; then
        error "That is the PUBLIC key (age1...). Paste the private one: AGE-SECRET-KEY-1..."
        return
    fi
    line="$(printf '%s\n' "$text" | normalize_age_lines | grep -m1 '^AGE-SECRET-KEY-' || true)"
    if [[ -z "$line" ]]; then
        error "No line starting with AGE-SECRET-KEY- was found in what was pasted."
        return
    fi
    len=${#line}
    bad="$(printf '%s' "${line#AGE-SECRET-KEY-1}" | tr -d 'QPZRY9X8GF2TVDW0S3JN54KHCE6MUA7L' | wc -c)"
    error "Found a key line, but it is ${len} characters (expected 74) with ${bad} invalid character(s)."
    echo "  The key was probably cut off, or extra text got pasted along with it."
}

# Ask the user for a key; sets AGE_KEY_CONTENT. Returns 1 if the input was invalid
# so the caller can ask again instead of exiting.
read_age_key() {
    local method raw="" line path
    echo ""
    echo "How do you want to provide the age private key?"
    echo "  [1] Paste the key content here"
    echo "  [2] Provide the path to an existing key file"
    echo ""
    prompt method "Enter choice" "1"

    case "$method" in
        1)
            echo ""
            echo "Paste your PRIVATE age key (AGE-SECRET-KEY-1..., not the age1... public key)."
            echo "Input is hidden. Press Enter after pasting; an empty line finishes."
            echo ""
            while IFS= read -r -s line; do
                [[ -z "$line" ]] && break
                raw+="$line"$'\n'
                # Stop as soon as a complete valid key has been pasted
                printf '%s\n' "$line" | extract_age_keys | grep -q . && break
            done
            echo ""
            ;;
        2)
            prompt path "Path to your age key file" ""
            path="${path/#\~/$HOME}"
            if [[ ! -f "$path" ]]; then
                error "File not found: $path"
                return 1
            fi
            raw="$(cat "$path")"
            ;;
        *)
            error "Invalid choice: $method"
            return 1
            ;;
    esac

    AGE_KEY_CONTENT="$(printf '%s\n' "$raw" | extract_age_keys)"
    if [[ -z "$AGE_KEY_CONTENT" ]]; then
        diagnose_age_input "$raw"
        return 1
    fi
    return 0
}

need_key=1
if sudo test -f "$AGE_KEY_FILE" 2>/dev/null; then
    if sudo cat "$AGE_KEY_FILE" | extract_age_keys | grep -q .; then
        info "Age key already exists at $AGE_KEY_FILE"
        echo -en "${BOLD}Replace it with a different key? [y/N]: ${RESET}"
        read -r REPLACE_KEY
        [[ "$REPLACE_KEY" =~ ^[Yy]$ ]] || need_key=0
    else
        warn "$AGE_KEY_FILE exists but doesn't contain a valid age key — it will be replaced."
    fi
fi

if [[ "$need_key" -eq 1 ]]; then
    echo ""
    echo "The home-manager config uses SOPS to decrypt secrets (SSH keys, API keys, etc.)."
    echo "You need to provide your age private key before the config can be applied."

    AGE_KEY_CONTENT=""
    until read_age_key; do
        echo -en "${BOLD}Try again? [Y/n]: ${RESET}"
        read -r RETRY
        [[ "$RETRY" =~ ^[Nn]$ ]] && die "Aborted — no valid age key provided."
    done

    sudo mkdir -p "$AGE_KEY_DIR"
    printf '%s\n' "$AGE_KEY_CONTENT" | sudo tee "$AGE_KEY_FILE" > /dev/null
    sudo chmod 600 "$AGE_KEY_FILE"
    info "Age key written to $AGE_KEY_FILE"
fi

# The sops-nix home-manager service runs as $CURRENT_USER (not root), so it must
# be able to read the key. Fix this every run — it also repairs a key that was
# saved as root-only (e.g. edited with sudo vim).
sudo chown "$CURRENT_USER":"$(id -gn)" "$AGE_KEY_FILE"
sudo chmod 600 "$AGE_KEY_FILE"
info "Age key is owned by $CURRENT_USER (mode 600)"


# ── 6. Clone dotfiles repo ────────────────────────────────────────────────────
section "nixos-dotfiles repo (Debian branch)"

REPO_PATH="$HOME/GitRepos/nixos-dotfiles"
REPO_URL="https://github.com/railgun210/nixos-dotfiles"

if [[ -d "$REPO_PATH/.git" ]]; then
    info "Repo already cloned at $REPO_PATH — skipping clone"
else
    echo -en "${BOLD}Do you need the repo cloned to $REPO_PATH? [Y/n]: ${RESET}"
    read -r NEED_CLONE
    if [[ "$NEED_CLONE" =~ ^[Nn]$ ]]; then
        prompt REPO_PATH "Path to your existing nixos-dotfiles repo" "$REPO_PATH"
        REPO_PATH="${REPO_PATH/#\~/$HOME}"
        [[ -d "$REPO_PATH/.git" ]] || die "No git repo found at $REPO_PATH.
  Re-run and answer 'y' to clone it, or give the correct path."
        info "Using existing repo at $REPO_PATH"
    else
        mkdir -p "$(dirname "$REPO_PATH")"
        info "Cloning $REPO_URL ..."
        git clone "$REPO_URL" "$REPO_PATH"
        info "Cloned to $REPO_PATH"
    fi
fi

# Make sure we're on the Debian branch (don't crash if the user has local changes)
CURRENT_BRANCH="$(git -C "$REPO_PATH" branch --show-current)"
if [[ "$CURRENT_BRANCH" != "Debian" ]]; then
    warn "Repo is on branch '$CURRENT_BRANCH' — switching to Debian..."
    git -C "$REPO_PATH" checkout Debian \
        || die "Could not switch to the Debian branch in $REPO_PATH (uncommitted changes?)."
fi
info "Repo ready at $REPO_PATH (Debian branch)"

# ── 7. Apply home-manager config ──────────────────────────────────────────────
section "Applying home-manager config"

echo ""
# Existing dotfiles (e.g. ~/.config/mimeapps.list on a desktop install) would make
# home-manager refuse with "would be clobbered". -b moves them aside instead; the
# timestamp keeps a re-run from failing because an earlier backup already exists.
BACKUP_EXT="hm-backup-$(date +%Y%m%d-%H%M%S)"

info "Running: nix run home-manager/release-25.11 -- switch -b ${BACKUP_EXT} --flake ${REPO_PATH}#railgun"
echo ""
warn "This step downloads ~1 GB of packages on first run. Be patient."
echo ""

if ! nix run home-manager/release-25.11 -- switch -b "$BACKUP_EXT" --flake "${REPO_PATH}#railgun"; then
    echo ""
    error "home-manager switch failed. Read the error above — common causes:"
    echo "  • 'experimental Nix feature ... is disabled'"
    echo "    → Check ~/.config/nix/nix.conf contains: experimental-features = nix-command flakes"
    echo "  • sops / age errors (failed to decrypt, no identity matched, permission denied)"
    echo "    → The key at $AGE_KEY_FILE is for a different recipient or unreadable."
    echo "      Re-run and answer 'y' to \"Replace it with a different key?\""
    echo "  • 'Existing file ... would be clobbered'"
    echo "    → Move or delete the named file, then re-run (normally handled by -b backup)"
    echo "  • Network issue mid-download"
    echo "    → Re-run this script; it's idempotent"
    echo "  • Nix store permission issue"
    echo "    → Make sure the nix-daemon is running: sudo systemctl status nix-daemon"
    exit 1
fi

info "home-manager config applied successfully"
if compgen -G "$HOME"/.*."$BACKUP_EXT" >/dev/null || compgen -G "$HOME"/.config/*."$BACKUP_EXT" >/dev/null; then
    warn "Existing files were backed up with the .${BACKUP_EXT} suffix (e.g. ~/.config/mimeapps.list.${BACKUP_EXT})."
    warn "Copy anything you still want out of them; they are safe to delete otherwise."
fi

# ── 8. Set zsh as default shell ───────────────────────────────────────────────
section "Setting zsh as default shell"

ZSH_PATH="$HOME/.nix-profile/bin/zsh"

if [[ "$(getent passwd "$CURRENT_USER" | cut -d: -f7)" == "$ZSH_PATH" ]]; then
    info "zsh is already the default shell"
else
    if [[ ! -f "$ZSH_PATH" ]]; then
        warn "zsh not found at $ZSH_PATH — home-manager may not have applied yet."
        warn "Skipping shell change; run 'chsh -s $ZSH_PATH' manually after re-login."
    else
        grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
        chsh -s "$ZSH_PATH"
        info "Default shell set to $ZSH_PATH"
    fi
fi

# ── 9. Done ───────────────────────────────────────────────────────────────────
section "Bootstrap complete"

echo ""
echo -e "${GREEN}${BOLD}Everything is set up. Log out and back in for the new shell.${RESET}"
echo ""
echo -e "${BOLD}Manual steps still needed:${RESET}"
echo "  □  NVIDIA drivers (if applicable):"
echo "       Trixie only enables non-free-firmware, so enable contrib + non-free first:"
echo "         sudo sed -i -E '/^deb/ s/ main non-free-firmware\$/ main contrib non-free non-free-firmware/' /etc/apt/sources.list"
echo "         sudo apt update"
echo "         sudo apt install linux-headers-amd64 nvidia-driver firmware-misc-nonfree"
echo "  □  Nix GPU drivers (GUI apps from nix may not start without this):"
echo "       home-manager printed a 'non-nixos-gpu-setup' command during the switch —"
echo "       run that exact line with sudo. Re-running the script shows it again."
echo "  □  PIA VPN client — not managed by nix:"
echo "       Download from privateinternetaccess.com and install manually"
echo "  □  MATE startup items:"
echo "       System → Preferences → Startup Applications"
echo "       Add: /usr/lib/mate-polkit/polkit-mate-authentication-agent-1"
echo "  □  MATE appearance — GTK theme, icon theme, window decorations:"
echo "       System → Preferences → Appearance"
echo ""
echo -e "${BOLD}After re-login, rebuild with:${RESET}"
echo "  home-manager switch --flake ~/GitRepos/nixos-dotfiles#railgun"
echo ""
echo -e "${BOLD}Update flake inputs and rebuild with:${RESET}"
echo "  update   (zsh alias)"
echo ""
