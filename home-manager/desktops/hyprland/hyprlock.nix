{
  config,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
in
{
  # ── Hyprlock ──────────────────────────────────────────────────────────────
  # Hyprland-native lock screen. Uses the same stylix base16 colors as swaylock
  # for a consistent look. Lockscreen wallpaper is shared with the sway config.
  home.packages = [ pkgs.hyprlock ];

  xdg.configFile."hypr/hyprlock.conf".text = ''
    # ── Background ─────────────────────────────────────────────────────────
    # Uses the same lockscreen wallpaper as sway.
    # blur_passes = 3 makes the background blurry for aesthetics.
    background {
      monitor =
      path = ~/Wallpapers/lockscreen_wallpapers/lock.jpeg
      blur_passes = 3
      blur_size = 7
    }

    # ── Input Field ────────────────────────────────────────────────────────
    # Password input field. Colors match stylix atelier-forest palette.
    # EDIT: Change size, position, or blur_noise to customize the look.
    input-field {
      monitor =
      size = 300, 40
      outline_thickness = 2
      dots_size = 0.25
      dots_spacing = 0.2
      dots_center = true
      outer_color = #${c.base0D}
      inner_color = #${c.base00}
      font_color = #${c.base05}
      fade_on_empty = false
      placeholder_text = <span foreground="#${c.base04}">Password...</span>
      hide_input = false
      position = 0, -20
      halign = center
      valign = center
    }

    # ── Clock (large, above password) ──────────────────────────────────────
    # Shows current time in 24h format. Uses monospace from stylix.
    # EDIT: Change format to change how time is displayed.
    label {
      monitor =
      text = cmd[update:1000] echo "$(date +"%H:%M")"
      color = #${c.base05}
      font_size = 96
      font_family = ${config.stylix.fonts.monospace.name}
      position = 0, 80
      halign = center
      valign = center
    }

    # ── Date (below clock) ─────────────────────────────────────────────────
    # Shows the current date. Uses monospace from stylix.
    # EDIT: Change format string to customize date display.
    label {
      monitor =
      text = cmd[update:60000] echo "$(date +"%A, %B %d")"
      color = #${c.base04}
      font_size = 24
      font_family = ${config.stylix.fonts.monospace.name}
      position = 0, 20
      halign = center
      valign = center
    }
  '';
}
