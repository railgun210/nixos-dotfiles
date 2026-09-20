{pkgs, ...}:
# Extra utilities installed alongside the MATE desktop.
# MATE itself (panel, applets, themes, session) is configured manually in Debian.
# This module only provides additional packages that complement the MATE session.
{
  home.packages = with pkgs; [
    # Screenshots (X11)
    flameshot

    # Clipboard tools (X11)
    xclip
    xdotool

    # Brightness control (works via backlight sysfs or ddcutil)
    brightnessctl

    # Archive manager
    file-roller

    # Image viewer
    eog

    # Polkit agent — handles privilege escalation dialogs in the desktop session
    polkit_gnome
  ];
}
