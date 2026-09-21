# home-manager/home.nix
# Standalone Home Manager configuration for Debian + GNOME (Wayland).
# Apply with: home-manager switch --flake .#railgun
{
  config,
  ...
}: {
  imports = [
    # theming MUST be first: Stylix variables (colors, fonts) need to be
    # evaluated before utilities and desktops consume them.
    ./theming
    ./utilities
    ./desktops
  ];

  config = {
    # Required for standalone home-manager on non-NixOS systems.
    targets.genericLinux = {
      enable = true;
      # Expose Debian's NVIDIA driver to Nix-built GL/Vulkan apps (ghostty,
      # RetroArch, ...). Version MUST match Debian's nvidia-driver package.
      # After switching (and after any version bump), run the sudo command that
      # `home-manager switch` prints: sudo /nix/store/...-non-nixos-gpu/bin/non-nixos-gpu-setup
      gpu.nvidia = {
        enable = true;
        version = "550.163.01";
        sha256 = "sha256-74FJ9bNFlUYBRen7+C08ku5Gc1uFYGeqlIh7l1yrmi4=";
      };
    };

    home = {
      username = "railgun";
      homeDirectory = "/home/railgun";

      file."Wallpapers" = {
        source = ./wallpapers;
        recursive = true;
      };

      sessionVariables = {
        EDITOR = "emacsclient -a ''";
        VISUAL = "emacsclient -a ''";
        TERMINAL = "ghostty";
        BROWSER = "firefox-esr"; # Debian's apt Firefox ESR
        NH_FLAKE = "${config.home.homeDirectory}/GitRepos/nixos-dotfiles";
      };
    };

    programs.home-manager.enable = true;

    # Git identity. Written as a plain config file (not programs.git) because
    # git itself comes from apt on Debian; programs.git would install a second copy.
    xdg.configFile."git/config".text = ''
      [user]
        name = railgun210
        email = aday56709@gmail.com
    '';

    # Vanilla neovim (no plugins, for quick terminal edits)
    programs.neovim = {
      enable = true;
      withRuby = false;
      withPython3 = false;
    };

    systemd.user.startServices = "sd-switch";

    home.stateVersion = "25.11";
  };
}
