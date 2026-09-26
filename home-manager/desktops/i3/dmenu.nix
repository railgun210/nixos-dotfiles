# home-manager/desktops/i3/dmenu.nix
# dmenu versions of the main branch's bemenu launcher and power menu
# (desktops/components/bemenu on `main`), coloured from the Stylix palette.
{
  config,
  lib,
  pkgs,
  ...
}: let
  c = config.lib.stylix.colors;
  font = config.utils.fonts.status;

  dmenuArgs = lib.escapeShellArgs [
    "-i"
    "-fn"
    "${font.family}:size=${toString font.size}"
    "-nb"
    "#${c.base00}"
    "-nf"
    "#${c.base05}"
    "-sb"
    "#${c.base0D}"
    "-sf"
    "#${c.base00}"
  ];

  dmenu = pkgs.writeShellScriptBin "dmenu-themed" ''
    exec ${pkgs.dmenu}/bin/dmenu ${dmenuArgs} "$@"
  '';

  # j4-dmenu-desktop reads .desktop files from XDG_DATA_DIRS, so Debian, Nix
  # and Flatpak apps all show up (like rofi's drun mode).
  desktopLauncher = pkgs.writeShellScriptBin "desktop-launcher" ''
    exec ${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop \
      --dmenu="${dmenu}/bin/dmenu-themed -p Run" \
      --no-generic \
      --term-mode custom \
      --term "ghostty -e {cmdline@}"
  '';

  powerMenu = pkgs.writeShellScriptBin "powermenu-dmenu" ''
    chosen=$(printf '⏻ Shutdown\n⏼ Restart\n󰤄 Suspend\n Lock\n󰍃 Logout' \
      | ${dmenu}/bin/dmenu-themed -p "Power" -l 5)

    case "$chosen" in
      "⏻ Shutdown") systemctl poweroff ;;
      "⏼ Restart")   systemctl reboot ;;
      "󰤄 Suspend")   systemctl suspend ;;
      " Lock")      loginctl lock-session ;;
      "󰍃 Logout")    i3-msg exit ;;
    esac
  '';
in {
  home.packages = [
    dmenu
    desktopLauncher
    powerMenu
  ];
}
