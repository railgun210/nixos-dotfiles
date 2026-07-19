{
  pkgs,
  ...
}:
let
  powerMenuScript = pkgs.writeShellScriptBin "powermenu-bemenu" ''
    chosen=$(printf '⏻ Shutdown\n⏼ Restart\n󰤄 Suspend\n Lock\n󰍃 Logout' \
      | ${pkgs.bemenu}/bin/bemenu -p "Power" -l 5)

    case "$chosen" in
      "⏻ Shutdown") systemctl poweroff ;;
      "⏼ Restart")   systemctl reboot ;;
      "󰤄 Suspend")   systemctl suspend ;;
      " Lock")
        # Use the appropriate lock screen for the running compositor
        if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
          ${pkgs.hyprlock}/bin/hyprlock
        else
          ${pkgs.swaylock-effects}/bin/swaylock
        fi
        ;;
      "󰍃 Logout")
        # Use the appropriate exit command for the running compositor
        if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
          hyprctl dispatch exit
        else
          swaymsg exit
        fi
        ;;
    esac
  '';
in
{
  home.packages = [ powerMenuScript ];
}
