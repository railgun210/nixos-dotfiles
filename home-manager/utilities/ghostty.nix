# home-manager/utilities/ghostty.nix
# Ghostty terminal configuration
{config, ...}: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      font-family = "${config.stylix.fonts.monospace.name}";
      font-size = 14;

      background-opacity = 0.9; # 0.0 = fully transparent, 1.0 = fully opaque;
      background-blur = false;

      window-padding-x = 10;
      window-padding-y = 10;
      # GNOME/mutter has no server-side decorations, so let Ghostty draw its own
      # libadwaita titlebar (window can be moved, resized and snapped).
      window-decoration = "auto";
      gtk-titlebar = true;
      window-width = 120; # initial size in cells; also stops the tiny corner window
      window-height = 35;
      window-save-state = "never";
      confirm-close-surface = false;
      gtk-single-instance = false; # one process per window, so closing one window never affects another

      shell-integration = "zsh";

      clipboard-read = "allow";
      clipboard-write = "allow";

      mouse-hide-while-typing = true;

      scrollback-limit = 100000;

      # Standard base16 -> ANSI mapping (same as base16-shell / Stylix terminals).
      # 0-15 are the ANSI colors, 16-21 hold the remaining base16 slots.
      palette = [
        "0=#${config.lib.stylix.colors.base00}"
        "1=#${config.lib.stylix.colors.base08}"
        "2=#${config.lib.stylix.colors.base0B}"
        "3=#${config.lib.stylix.colors.base0A}"
        "4=#${config.lib.stylix.colors.base0D}"
        "5=#${config.lib.stylix.colors.base0E}"
        "6=#${config.lib.stylix.colors.base0C}"
        "7=#${config.lib.stylix.colors.base05}"
        "8=#${config.lib.stylix.colors.base03}"
        "9=#${config.lib.stylix.colors.base08}"
        "10=#${config.lib.stylix.colors.base0B}"
        "11=#${config.lib.stylix.colors.base0A}"
        "12=#${config.lib.stylix.colors.base0D}"
        "13=#${config.lib.stylix.colors.base0E}"
        "14=#${config.lib.stylix.colors.base0C}"
        "15=#${config.lib.stylix.colors.base07}"
        "16=#${config.lib.stylix.colors.base09}"
        "17=#${config.lib.stylix.colors.base0F}"
        "18=#${config.lib.stylix.colors.base01}"
        "19=#${config.lib.stylix.colors.base02}"
        "20=#${config.lib.stylix.colors.base04}"
        "21=#${config.lib.stylix.colors.base06}"
      ];
    };
  };
}
