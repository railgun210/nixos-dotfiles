# home-manager/home.nix
# Main home-manager configuration
{
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.stylix.homeModules.stylix
    ./theming # This has to get loaded first
    ./utilities
    ./desktops
  ];

  config = {
    # Allow unfree packages
    nixpkgs.config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      permittedInsecurePackages = [
        "electron-39.8.10"
      ];
    };

    # User information
    home = {
      username = "railgun";
      homeDirectory = "/home/railgun";

      # Load wallpapers to the correct folder
      # Is it insane to hard-code wallpapers? Yes of course it is.
      file."Wallpapers" = {
        source = ./wallpapers;
        recursive = true;
      };

      # Session variables
      sessionVariables = {
        EDITOR = "emacsclient -a ''";
        VISUAL = "emacsclient -a ''";
        TERMINAL = "ghostty";
        BROWSER = "floorp";
        # NH flake location
        # NH_FLAKE previously pointed to a local dotfiles folder; use the repo-relative path
        NH_FLAKE = "${config.home.homeDirectory}/GitRepos/nixos-dotfiles";
      };
    };

    # Enable home-manager
    programs.home-manager.enable = true;

    # Vanilla neovim (no plugins, for quick terminal edits)
    programs.neovim = {
      enable = true;
      withRuby = false;
      withPython3 = false;
    };

    # Systemd user services
    systemd.user.startServices = "sd-switch";

    # State version - do not change after initial setup
    home.stateVersion = "25.11";
  };
}
