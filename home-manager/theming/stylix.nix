{pkgs, ...}: {
  config = {
    stylix = {
      enable = true;

      # Wallpaper is declared directly here; color scheme is generated from it.
      image = ../wallpapers/still_wallpapers/wallhaven-ogyeol.jpg;
      imageScalingMode = "fit";

      polarity = "dark";
      opacity = {
        applications = 0.8;
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
        gtk.enable = true;

        vesktop.enable = true;

        ghostty.enable = false;
        kitty.enable = true;

        vscode.enable = false;
        neovide.enable = true;

        # i3 session (desktops/i3): window borders, i3bar and notifications.
        # feh is started by i3 itself; Stylix's feh target only works through
        # xsession.initExtra, which is left off so GNOME's Xorg path is untouched.
        i3.enable = true;
        dunst.enable = true;
        feh.enable = false;

        # Qt apps still pick up the palette.
        qt.enable = true;
        kde.enable = false;
      };
    };

    # GTK/GNOME (Wayland) and Xwayland apps all use this cursor.
    home.pointerCursor = {
      enable = true;
      gtk.enable = true;
      x11.enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 16;
    };
  };
}
