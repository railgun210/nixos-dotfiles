{ pkgs, ... }:
pkgs.writeShellScriptBin "keyboard-toggle" ''
  # Detect which compositor is running and use the appropriate input method.
  if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    # Hyprland: cycle to next keyboard layout via hyprctl
    kb_name=$(hyprctl devices -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.keyboards[0].name' 2>/dev/null)
    if [ -n "$kb_name" ]; then
      hyprctl switchxkblayout "$kb_name" next 2>/dev/null
    fi
  elif [ -n "$SWAYSOCK" ]; then
    # Sway: get keyboard ID and toggle layout via swaymsg
    kb_id=$(${pkgs.sway}/bin/swaymsg -t get_inputs 2>/dev/null | ${pkgs.jq}/bin/jq -r '[.[] | select(.type == "keyboard") | .identifier] | first' 2>/dev/null)
    layout=$(${pkgs.sway}/bin/swaymsg -t get_inputs 2>/dev/null | ${pkgs.jq}/bin/jq -r '[.[] | select(.type == "keyboard") | .xkb_active_layout_name] | first' 2>/dev/null)
    if [ -n "$kb_id" ] && echo "$layout" | ${pkgs.gnugrep}/bin/grep -qi "english"; then
      ${pkgs.sway}/bin/swaymsg input "$kb_id" xkb_switch_layout 1
    elif [ -n "$kb_id" ]; then
      ${pkgs.sway}/bin/swaymsg input "$kb_id" xkb_switch_layout 0
    fi
  fi

  # Signal waybar to refresh the keyboard layout module
  ${pkgs.procps}/bin/pkill -x -RTMIN+2 waybar 2>/dev/null || true
''
