# home-manager/home.nix
# Standalone Home Manager configuration for Debian + MATE.
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
    targets.genericLinux.enable = true;

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
        BROWSER = "floorp";
        NH_FLAKE = "${config.home.homeDirectory}/GitRepos/nixos-dotfiles";
      };
    };

    programs.home-manager.enable = true;

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
