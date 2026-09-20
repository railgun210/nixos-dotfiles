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

if command -v nix &>/dev/null; then
    info "Nix already installed: $(nix --version)"
else
    info "Running the Nix multi-user installer..."
    sh <(curl -L https://nixos.org/nix/install) --daemon < /dev/tty

    # Source nix for the rest of this session
    NIX_DAEMON_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    if [[ -f "$NIX_DAEMON_PROFILE" ]]; then
        # shellcheck source=/dev/null
        . "$NIX_DAEMON_PROFILE"
    fi

    if ! command -v nix &>/dev/null; then
        die "Nix was installed but 'nix' is not in PATH.
  Try opening a new terminal and re-running this script from step 4 onwards,
  or run: source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi
    info "Nix installed: $(nix --version)"
fi

# ── 4. Enable flakes ─────────────────────────────────────────────────────────
section "Enabling Nix flakes"

NIX_CONF="$HOME/.config/nix/nix.conf"
FLAKE_LINE="experimental-features = nix command flakes"

mkdir -p "$(dirname "$NIX_CONF")"
if grep -qxF "$FLAKE_LINE" "$NIX_CONF" 2>/dev/null; then
    info "Flakes already enabled in $NIX_CONF"
else
    echo "$FLAKE_LINE" >> "$NIX_CONF"
    info "Flakes enabled in $NIX_CONF"
fi

# ── 5. sops age key ───────────────────────────────────────────────────────────
section "Setting up sops age key"

AGE_KEY_DIR="/etc/sops/age"
AGE_KEY_FILE="$AGE_KEY_DIR/keys.txt"

if sudo test -f "$AGE_KEY_FILE" 2>/dev/null; then
    info "Age key already exists at $AGE_KEY_FILE"
else
    echo ""
    echo "The home-manager config uses SOPS to decrypt secrets (SSH keys, API keys, etc.)."
    echo "You need to provide your age private key before the config can be applied."
    echo ""
    echo "How do you want to provide the age private key?"
    echo "  [1] Paste the key content here"
    echo "  [2] Provide the path to an existing key file"
    echo ""
    prompt AGE_INPUT_METHOD "Enter choice" "1"

    AGE_KEY_CONTENT=""

    case "$AGE_INPUT_METHOD" in
        1)
            echo ""
            echo "Paste your age private key below."
            echo "It should look like: AGE-SECRET-KEY-1..."
            echo "Press Enter then Ctrl+D when done."
            echo ""
            AGE_KEY_CONTENT="$(cat)"
            ;;
        2)
            prompt AGE_KEY_PATH "Path to your age key file" ""
            AGE_KEY_PATH="${AGE_KEY_PATH/#\~/$HOME}"
            [[ -f "$AGE_KEY_PATH" ]] || die "File not found: $AGE_KEY_PATH"
            AGE_KEY_CONTENT="$(cat "$AGE_KEY_PATH")"
            ;;
        *)
            die "Invalid choice: $AGE_INPUT_METHOD"
            ;;
    esac

    # Basic validation
    if ! echo "$AGE_KEY_CONTENT" | grep -q "^AGE-SECRET-KEY-"; then
        die "The provided content does not look like an age private key.
  Expected a line starting with 'AGE-SECRET-KEY-1...'
  Double-check your key and re-run the script."
    fi

    # Write to /etc/sops/age/keys.txt
    sudo mkdir -p "$AGE_KEY_DIR"
    echo "$AGE_KEY_CONTENT" | sudo tee "$AGE_KEY_FILE" > /dev/null
    sudo chmod 600 "$AGE_KEY_FILE"
    sudo chown root:root "$AGE_KEY_FILE"
    info "Age key written to $AGE_KEY_FILE"
fi

# ── 6. Clone dotfiles repo ────────────────────────────────────────────────────
section "Cloning nixos-dotfiles (Debian branch)"

DEFAULT_REPO_PATH="$HOME/GitRepos/nixos-dotfiles"
prompt REPO_PATH "Where should the repo be cloned?" "$DEFAULT_REPO_PATH"
REPO_PATH="${REPO_PATH/#\~/$HOME}"

REPO_URL="https://github.com/railgun210/nixos-dotfiles"

if [[ -d "$REPO_PATH/.git" ]]; then
    EXISTING_REMOTE="$(git -C "$REPO_PATH" remote get-url origin 2>/dev/null || echo '')"
    if [[ "$EXISTING_REMOTE" == "$REPO_URL" ]]; then
        CURRENT_BRANCH="$(git -C "$REPO_PATH" branch --show-current)"
        if [[ "$CURRENT_BRANCH" != "Debian" ]]; then
            warn "Repo exists but is on branch '$CURRENT_BRANCH' — switching to Debian..."
            git -C "$REPO_PATH" checkout Debian
        fi
        info "Repo already cloned at $REPO_PATH (Debian branch)"
    else
        die "A different git repo already exists at $REPO_PATH (remote: $EXISTING_REMOTE).
  Remove it or choose a different path and re-run."
    fi
else
    mkdir -p "$(dirname "$REPO_PATH")"
    info "Cloning $REPO_URL ..."
    git clone "$REPO_URL" "$REPO_PATH"
    git -C "$REPO_PATH" checkout Debian
    info "Cloned to $REPO_PATH"
fi

# ── 7. Apply home-manager config ──────────────────────────────────────────────
section "Applying home-manager config"

echo ""
info "Running: nix run home-manager/release-25.11 -- switch --flake ${REPO_PATH}#railgun"
echo ""
warn "This step downloads ~1 GB of packages on first run. Be patient."
echo ""

if ! nix run home-manager/release-25.11 -- switch --flake "${REPO_PATH}#railgun"; then
    echo ""
    error "home-manager switch failed. Common causes:"
    echo "  • Age key is wrong or was for a different key recipient"
    echo "    → Check $AGE_KEY_FILE and compare with the age recipient in secrets/secrets.yaml"
    echo "  • Network issue mid-download"
    echo "    → Re-run this script; it's idempotent"
    echo "  • Nix store permission issue"
    echo "    → Make sure the nix-daemon is running: sudo systemctl status nix-daemon"
    exit 1
fi

info "home-manager config applied successfully"

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
echo "       sudo apt install nvidia-driver firmware-misc-nonfree"
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
