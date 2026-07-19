{
  config,
  lib,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
  modifier = "Mod4";
  terminal = "ghostty";
  bemenu-cmd = "${pkgs.bemenu}/bin/bemenu-run";
  ws1 = "1";
  ws2 = "2";
  ws3 = "3";
  ws4 = "4";
  ws5 = "5";
  ws6 = "6";
  ws7 = "7";
  ws8 = "8";
  ws9 = "9";
  ws10 = "10";
in
{
  home.packages = with pkgs; [
    socat
    autotiling
  ];

  wayland.windowManager.sway.config = {
    inherit modifier terminal;

    input = {
      "*" = {
        xkb_layout = "us,latam";
        xkb_options = "grp:alt_shift_toggle";
      };
    };

    output = {
      "*" = {
        scale = "1.6";
      };
    };

    gaps = {
      inner = 5;
      outer = 5;
      smartBorders = "off";
    };

    window = {
      titlebar = false;
      border = 3;
    };

    floating = {
      modifier = modifier;
      border = 3;
      titlebar = false;
    };

    defaultWorkspace = "workspace ${ws1}";

    assigns = {
      "${ws4}" = [ { class = "^vlc$"; } ];
      "${ws5}" = [ { class = "^Strawberry$"; } ];
      "${ws6}" = [ { class = "^steam$"; } ];
      "${ws7}" = [ { class = "^org.mozilla.Thunderbird$"; } ];
    };

    floating.criteria = [
      { class = "Pavucontrol"; }
      { class = "Blueman-manager"; }
      { class = "Nm-connection-editor"; }
      { instance = "floating_term"; }
      { window_role = "pop-up"; }
      { window_role = "task_dialog"; }
    ];

    fonts = {
      names = [
        config.stylix.customFonts.status.family
        config.stylix.customFonts.symbols.family
      ];
      style = "Regular";
      size = lib.mkForce 14.0;
    };

    colors = lib.mkForce (
      let
        border = "#${c.base0D}";
        background = "#${c.base00}";
        text = "#${c.base05}";
        indicator = "#${c.base0D}";
      in
      {
        focused = {
          border = border;
          background = background;
          text = text;
          indicator = indicator;
          childBorder = border;
        };
        focusedInactive = {
          border = "#${c.base02}";
          background = background;
          text = text;
          indicator = indicator;
          childBorder = "#${c.base02}";
        };
        unfocused = {
          border = "#${c.base02}";
          background = background;
          text = text;
          indicator = indicator;
          childBorder = "#${c.base02}";
        };
        urgent = {
          border = "#${c.base08}";
          background = background;
          text = text;
          indicator = indicator;
          childBorder = "#${c.base08}";
        };
        placeholder = {
          border = background;
          background = background;
          text = text;
          indicator = indicator;
          childBorder = background;
        };
        background = background;
      }
    );

    keybindings = lib.mkOptionDefault {
      "${modifier}+j" = "focus left";
      "${modifier}+k" = "focus down";
      "${modifier}+l" = "focus up";
      "${modifier}+semicolon" = "focus right";

      "${modifier}+Shift+j" = "move left";
      "${modifier}+Shift+k" = "move down";
      "${modifier}+Shift+l" = "move up";
      "${modifier}+Shift+semicolon" = "move right";

      "${modifier}+h" = "splith";
      "${modifier}+v" = "splitv";
      "${modifier}+f" = "fullscreen toggle";
      "${modifier}+space" = "floating toggle";
      "${modifier}+Shift+space" = "focus mode_toggle";
      "${modifier}+a" = "focus parent";
      "${modifier}+q" = "kill";

      "${modifier}+s" = "layout stacking";
      "${modifier}+w" = "layout tabbed";
      "${modifier}+e" = "layout toggle split";

      "${modifier}+d" = "exec ${bemenu-cmd}";
      "${modifier}+Shift+d" = "exec window-switcher";
      "${modifier}+t" = "exec ${terminal}";
      "${modifier}+Return" = "exec ${terminal}";
      "${modifier}+b" = "exec ${pkgs.floorp-bin}/bin/floorp";
      "${modifier}+Shift+e" = "exec ${pkgs.thunar}/bin/thunar";

      "${modifier}+Shift+s" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
      "${modifier}+Shift+v" =
        "exec cliphist list | ${pkgs.bemenu}/bin/bemenu -l 20 | cliphist decode | wl-copy";

      "${modifier}+x" = "exec ${pkgs.swaylock-effects}/bin/swaylock";
      "${modifier}+Shift+x" = "exec powermenu-bemenu";

      "Ctrl+Alt+p" = "exec pia-selector";
      "${modifier}+Shift+c" = "reload";
      "${modifier}+Shift+r" = "restart";

      "Ctrl+Alt+z" = "exec emacsclient -c -a emacs";
      "Ctrl+Alt+e" = "exec bemoji";
      "Ctrl+Alt+a" = "exec ${pkgs.anki-bin}/bin/anki";

      "${modifier}+1" = "workspace ${ws1}";
      "${modifier}+2" = "workspace ${ws2}";
      "${modifier}+3" = "workspace ${ws3}";
      "${modifier}+4" = "workspace ${ws4}";
      "${modifier}+5" = "workspace ${ws5}";
      "${modifier}+6" = "workspace ${ws6}";
      "${modifier}+7" = "workspace ${ws7}";
      "${modifier}+8" = "workspace ${ws8}";
      "${modifier}+9" = "workspace ${ws9}";
      "${modifier}+0" = "workspace ${ws10}";

      "${modifier}+Shift+1" = "move container to workspace ${ws1}";
      "${modifier}+Shift+2" = "move container to workspace ${ws2}";
      "${modifier}+Shift+3" = "move container to workspace ${ws3}";
      "${modifier}+Shift+4" = "move container to workspace ${ws4}";
      "${modifier}+Shift+5" = "move container to workspace ${ws5}";
      "${modifier}+Shift+6" = "move container to workspace ${ws6}";
      "${modifier}+Shift+7" = "move container to workspace ${ws7}";
      "${modifier}+Shift+8" = "move container to workspace ${ws8}";
      "${modifier}+Shift+9" = "move container to workspace ${ws9}";
      "${modifier}+Shift+0" = "move container to workspace ${ws10}";

      "${modifier}+Tab" = "workspace next";
      "${modifier}+Shift+Tab" = "workspace prev";
      "${modifier}+bracketright" = "workspace next";
      "${modifier}+bracketleft" = "workspace prev";

      "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
      "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
      "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";

      "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
      "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
    };
  };

  wayland.windowManager.sway.extraConfig = ''
    for_window [instance="floating_term"] floating enable, resize set 800 600

    # -- Center floating popup windows (save dialogs, settings, etc.) --
    for_window [app_id="floorp" floating] center

    # -- Disable blur for transparent terminals and editors --
    for_window [app_id="ghostty"] blur disable
    for_window [app_id="emacs"] blur disable

    # -- SwayFX effects --
    blur enable
    blur_xray disable
    blur_passes 4
    blur_radius 7
    corner_radius 5
    shadows enable
    shadow_blur_radius 20
    scratchpad_minimize disable

    # -- SwayFX Waybar effects --
    layer_effects "waybar" {
        blur enable;
        blur_xray enable;
        blur_ignore_transparent enable;
    }

    smart_gaps on
    focus_follows_mouse no

    exec ${pkgs.swaybg}/bin/swaybg -i ~/Wallpapers/still_wallpapers/bveqqcq4fo5h1.jpeg -m fill
    # awww daemon must be running before waypaper can set wallpapers
    exec ${pkgs.awww}/bin/awww-daemon
    # Restore last wallpaper waypaper set (waypaper saves its choice to ~/.config/waypaper/config.ini)
    exec ${pkgs.waypaper}/bin/waypaper --restore
    exec ${pkgs.maestral}/bin/maestral start
    exec ${pkgs.swayidle}/bin/swayidle
    exec ${pkgs.autotiling}/bin/autotiling
    exec ${pkgs.waybar}/bin/waybar
    exec ${pkgs.dunst}/bin/dunst
  '';
}
