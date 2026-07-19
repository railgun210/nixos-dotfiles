{ pkgs, ... }:
pkgs.writeShellScriptBin "keyboard-layout" ''
  # Detect which compositor is running and use the appropriate query method.
  if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    # Hyprland: query active keyboard layout via hyprctl
    layout=$(hyprctl devices -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.keyboards[0].active_keymap' 2>/dev/null)
  elif [ -n "$SWAYSOCK" ]; then
    # Sway: query active keyboard layout via swaymsg
    layout=$(${pkgs.sway}/bin/swaymsg -t get_inputs 2>/dev/null | ${pkgs.jq}/bin/jq -r '[.[] | select(.type == "keyboard") | .xkb_active_layout_name] | first' 2>/dev/null)
  fi

  cache="''${XDG_RUNTIME_DIR:-/tmp}/kbd-layout"

  if [ -f "$cache" ]; then
    prev=$(cat "$cache")
    if [ "$prev" != "$layout" ]; then
      :
    fi
  fi
  printf '%s' "$layout" > "$cache"

  if echo "$layout" | ${pkgs.gnugrep}/bin/grep -qi "english"; then
    echo '{"text": "en", "class": "en"}'
  else
    echo '{"text": "es", "class": "es"}'
  fi
''
