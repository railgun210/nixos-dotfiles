{pkgs, ...}: {
  config = {
    stylix = {
      enable = true;

      # Wallpaper is declared directly here; color scheme is generated from it.
      image = ../wallpapers/still_wallpapers/wallhaven-jee8ry.jpg;
      imageScalingMode = "fit";

      polarity = "dark";
      opacity = {
        applications = 0.7;
      };

      fonts = {
        serif = {
          package = pkgs.nerd-fonts.tinos;
          name = "Tinos Nerd Font";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.overpass;
          name = "Overpass Nerd Font Mono";
        };
        monospace = {
          package = pkgs.nerd-fonts.terminess-ttf;
          name = "Terminess Nerd Font Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };

      targets = {
        # GTK is managed by MATE; Stylix must not touch it.
        gtk.enable = false;

        bemenu.enable = false;
        dunst.enable = false;
        vesktop.enable = true;

        ghostty.enable = false;
        kitty.enable = true;
        alacritty.enable = false;

        vscode.enable = false;
        neovide.enable = true;
        anki.enable = true;

        # Qt apps still pick up the palette.
        qt.enable = true;
        kde.enable = false;

        # Wayland-only targets — not applicable on MATE/X11.
        waybar.enable = false;
        hyprlock.enable = false;

        neovim.enable = false;
      };
    };

    # X11 cursor only; MATE manages the GTK cursor via its own settings.
    home.pointerCursor = {
      enable = true;
      gtk.enable = false;
      x11.enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 16;
    };
  };
}
