{ pkgs, ... }:
# Packages shared across all Wayland desktops (Hyprland + Sway).
# Compositor-specific tools (hyprlock, hypridle, swaylock, swayidle)
# live in their respective module files.
{
  home.packages = with pkgs; [
    # Screenshot (grimshot works on any wlroots compositor)
    sway-contrib.grimshot

    # Clipboard
    wl-clipboard
    cliphist

    # Media/audio controls
    brightnessctl

    # File manager + utilities
    loupe
    file-roller
    kdePackages.kate

    # Wallpaper (awww + waypaper)
    swaybg
    waypaper
    awww
  ];
}
