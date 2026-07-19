# system/base-packages.nix
# System-wide packages available to all users
{ pkgs, ... }:
{
  # Steam
  programs.steam.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow known insecure packages (EOL Electron required by some apps)
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  environment.systemPackages = with pkgs; [
    # Core utilities
    home-manager
    file
    wget
    curl
    git
    htop
    btop
    tree
    ntfs3g

    # Text editors
    vim

    # Terminal
    bash

    # Secure Boot
    sbctl

    # Secrets management
    sops
    age
    gnupg

    # JSON/YAML utilities
    jq
    yq
    moreutils

    # Nix utilities
    nurl
    alejandra
    nh
    nixd

    # Archive tools
    p7zip
    unzip
    zip

    # System monitoring
    lm_sensors
    pciutils
    usbutils

    # Base16 color schemes
    base16-schemes
  ];
}
