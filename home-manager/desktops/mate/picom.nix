# home-manager/desktops/mate/picom.nix
# picom replaces Marco's built-in compositor for blur, shadows and rounded
# corners. Marco stays as the window manager (decorations, move/resize,
# alt-tab); picom is only a compositor and cannot manage windows itself.
{pkgs, ...}: {
  home.packages = [pkgs.picom];

  xdg.configFile."picom/picom.conf".source = ./picom.conf;

  # Turn off Marco's compositor, otherwise picom refuses to start with
  # "another composite manager is already running".
  dconf.settings."org/mate/marco/general".compositing-manager = false;

  # Started by mate-session through XDG autostart. Debian's MATE session does
  # not reliably activate graphical-session.target, so a systemd user service
  # (services.picom) would never start. picom reads ~/.config/picom/picom.conf
  # by default.
  xdg.configFile."autostart/picom.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=picom
    Comment=X11 compositor
    Exec=${pkgs.picom}/bin/picom
    X-MATE-Autostart-enabled=true
    NoDisplay=true
  '';
}
