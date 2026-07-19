{
  pkgs,
  ...
}:
{
  config = {
    stylix = {
      enable = true;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/atelier-forest.yaml";

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
        dunst.enable = false;
        gtk.enable = true;
        gnome.enable = false;
        vesktop.enable = true;

        ghostty.enable = false;
        kitty.enable = true;
        alacritty.enable = true;

        vscode.enable = true;
        neovide.enable = true;
        anki.enable = true;

        # Stylix native engine hooks for Qt and KDE ecosystem apps
        qt.enable = true;
        kde.enable = true;

        waybar.enable = true;
        swaylock.enable = true;
        hyprlock.enable = true;
        neovim.enable = false;
      };
    };

    # GTK icon theme (theme & font handled by stylix.targets.gtk)
    gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.buuf-icon-theme;
        name = "buuf-icon-theme";
      };
    };

    dconf.settings."org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:none";
    };

    # Cursor theme
    home.pointerCursor = {
      enable = true;
      gtk.enable = true;
      x11.enable = false;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 16;
    };
  };
}
