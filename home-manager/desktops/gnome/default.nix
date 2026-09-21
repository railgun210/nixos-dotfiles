# home-manager/desktops/gnome/default.nix
# GNOME (Wayland, GDM) on Debian, set up to feel like the old MATE desktop:
# GNOME Classic's top bar with Applications/Places menus, a bottom window list
# and a fixed set of workspaces.
#
# GNOME itself, its extensions and GDM come from apt (see docs/debian-setup.md).
# This module only configures them through dconf and adds the Nix-side pieces.
# Wallpaper, fonts and the dark colour scheme come from Stylix's own GNOME
# target (see theming/stylix.nix), so they are not repeated here.
{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Wayland clipboard CLI (replaces xclip/xdotool from the MATE/X11 setup)
    wl-clipboard

    # Brightness control (works via backlight sysfs or ddcutil)
    brightnessctl

    # Icon theme (from the buuf-icon-theme flake input via the overlay in
    # flake.nix); selected below through dconf.
    buuf-icon-theme
  ];

  # GDM starts a systemd user session, which (unlike Debian's old LightDM ->
  # Xsession path) reads ~/.config/environment.d. Home Manager already writes
  # XDG_DATA_DIRS there, so Nix apps show up in the Activities grid. PATH is the
  # one thing it does not set, so desktop entries that call a bare command name
  # (Exec=kitty) still resolve.
  xdg.configFile."environment.d/20-nix-path.conf".text = ''
    PATH=${config.home.homeDirectory}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH
  '';

  # Run Nix-built Electron apps (VS Code, Vesktop, Todoist) natively on Wayland
  # instead of through Xwayland. Written to the same environment.d file that
  # Home Manager generates for XDG_DATA_DIRS.
  systemd.user.sessionVariables.NIXOS_OZONE_WL = "1";

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      # UUIDs come from the Debian gnome-shell-extension* packages. GNOME Classic
      # enables its own set in the classic session; listing them here makes the
      # regular GNOME session look the same.
      enabled-extensions = [
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "window-list@gnome-shell-extensions.gcampax.github.com"
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
        "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "ubuntu-appindicators@ubuntu.com" # tray icons (Debian's AppIndicator package)
        "ding@rastersoft.com" # desktop icons
      ];
    };

    # Bottom window list like MATE's: windows grouped only when space runs out,
    # limited to the current workspace.
    "org/gnome/shell/extensions/window-list" = {
      grouping-mode = "auto";
      display-all-workspaces = false;
    };

    "org/gnome/desktop/interface" = {
      icon-theme = "buuf-icon-theme";
      cursor-theme = config.home.pointerCursor.name;
      cursor-size = config.home.pointerCursor.size;
      clock-show-date = true;
      enable-hot-corners = false; # MATE has no hot corner

      # Smooth text with subpixel rendering. Keep in sync with
      # theming/font-settings.nix, which sets the same values for fontconfig.
      font-antialiasing = "rgba";
      font-hinting = "slight";
      font-rgba-order = "rgb";
    };

    # Minimize/maximize/close on the right, no app-menu button.
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
      num-workspaces = 6; # same count as the MATE setup
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false; # fixed workspaces, like MATE's switcher
      edge-tiling = true;
    };
  };
}
