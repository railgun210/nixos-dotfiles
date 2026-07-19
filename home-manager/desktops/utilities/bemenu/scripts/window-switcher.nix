{
  pkgs,
  ...
}:
let
  windowSwitcher = pkgs.writeShellScriptBin "window-switcher" ''
    # Detect which compositor is running and use the appropriate IPC method.
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
      # Hyprland: list all clients via hyprctl and display in bemenu
      hyprctl clients -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '
        .[] |
        "\(.address)\u0000\(.class)\u0000\(.title // "")"
      ' | while IFS=$'\0' read -r addr class title; do
        [ -z "$addr" ] && continue
        case "$class" in
          "floorp"|"Floorp")             icon="" ;;
          "Alacritty"|"Ghostty"|"kitty") icon="" ;;
          "thunar"|"Thunar")             icon="" ;;
          "code"|"Code"|"code-oss")      icon="" ;;
          "vlc"|"VLC")                   icon="󰕼" ;;
          "strawberry"|"Strawberry")     icon="" ;;
          "thunderbird"|"Thunderbird")   icon="" ;;
          "steam"|"Steam")               icon="" ;;
          "Anki")                        icon="" ;;
          *)                             icon="" ;;
        esac
        short=$(echo "$title" | head -c 60)
        echo -e "$icon $short\t$addr"
      done | ${pkgs.bemenu}/bin/bemenu -p "Window" -l 20 -n | awk '{print $NF}' | {
        read -r addr
        [ -n "$addr" ] && hyprctl dispatch focuswindow "address:0x$addr" 2>/dev/null
      }
    elif [ -n "$SWAYSOCK" ]; then
      # Sway: list all windows via swaymsg and display in bemenu
      ${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq -r '
        ..
        | objects
        | select(.type == "floating_con" or (.type == "con" and .window != null))
        | select(.window_properties.class != null)
        | "\(.id)\u0000\(.window_properties.class)\u0000\(.name // "")"
      ' | while IFS=$'\0' read -r id class title; do
        [ -z "$id" ] && continue
        case "$class" in
          "floorp"|"Floorp")             icon="" ;;
          "Alacritty"|"Ghostty"|"kitty") icon="" ;;
          "thunar"|"Thunar")             icon="" ;;
          "code"|"Code"|"code-oss")      icon="" ;;
          "vlc"|"VLC")                   icon="󰕼" ;;
          "strawberry"|"Strawberry")     icon="" ;;
          "thunderbird"|"Thunderbird")   icon="" ;;
          "steam"|"Steam")               icon="" ;;
          "Anki")                        icon="" ;;
          *)                             icon="" ;;
        esac
        short=$(echo "$title" | head -c 60)
        echo -e "$icon $short\t$id"
      done | ${pkgs.bemenu}/bin/bemenu -p "Window" -l 20 -n | awk '{print $NF}' | {
        read -r con_id
        [ -n "$con_id" ] && ${pkgs.sway}/bin/swaymsg "[con_id=$con_id]" focus
      }
    fi
  '';
in
{
  home.packages = [ windowSwitcher ];
}
