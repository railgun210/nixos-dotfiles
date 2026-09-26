# home-manager/desktops/i3/conky.nix
# Conky panel for the i3 session, ported from the wallust template in
# ~/GitRepos/dotfiles. Colours come from the Stylix palette, so a new
# stylix.image recolours it; conky reloads the file itself after a switch.
{
  config,
  pkgs,
  ...
}: let
  c = config.lib.stylix.colors;

  # Helper scripts (Nerd Font glyph lookups, SSID), copied from the old repo.
  scripts = ./conky-scripts;

  # OpenWeatherMap current weather -> ~/.cache/weather.json. The API key comes
  # from sops instead of being written into the script.
  weather = pkgs.writeShellScript "conky-weather" ''
    key=$(cat ${config.sops.secrets.weather-api-key.path} 2>/dev/null) || exit 0
    ${pkgs.curl}/bin/curl -s -o "$HOME/.cache/weather.json" \
      "https://api.openweathermap.org/data/2.5/weather?id=4726206&appid=$key&units=imperial&lang=en"
  '';
in {
  sops.secrets.weather-api-key = {
    sopsFile = ../../../secrets/weather-api-key.age;
    format = "binary";
  };

  xdg.configFile."conky/conky.conf".text = ''
    conky.config = {
        -- Window behaviour
        own_window = true,
        own_window_type = 'override',
        own_window_class = 'Conky',
        own_window_transparent = false,
        own_window_argb_visual = true,
        own_window_argb_value = 60,
        own_window_colour = '#${c.base00}',
        background = true,

        -- Layout
        alignment = 'top_right',
        gap_x = 20,
        gap_y = 60,
        maximum_width = 260,
        draw_borders = false,
        draw_outline = false,
        border_width = 1,
        border_inner_margin = 1,
        border_outer_margin = 0,

        -- Font & colours (from Stylix)
        font = 'Cozette:size=14',
        default_color = '#${c.base05}',
        color1 = '#${c.base0D}',
        color2 = '#${c.base04}',
        color3 = '#${c.base08}',
        color4 = '#${c.base0B}',

        -- Behaviour
        update_interval = 2,
        double_buffer = true,
        no_buffers = true,
        use_xft = true,
        xftalpha = 1.0,
    };

    conky.text = [[
    ''${execi 3600 ${weather}}\
    ''${font Cozette:bold:size=20}$alignr''${time %A}
    ''${voffset -2}''${font Cozette:bold:size=14}$alignr''${time %d %B %Y}
    ''${font Cozette:size=40}$alignr''${time %H:%M}
    ''${voffset -2}''${color1}''${font Weather Icons:size=20}''${execi 60 ${scripts}/weather-icon.sh}''${font} ''${color2}''${execi 120 cat ~/.cache/weather.json | jq '.main.temp' | awk '{print int($1+0.5)}'}°F  $alignr''${execi 10 cat ~/.cache/weather.json | jq -r '.name'}

    ''${voffset 15}''${color1}''${font Symbols Nerd Font:Regular:size=14}''${execi 60 ${scripts}/distro-icon.sh}''${font} ''${color1}SYSTEM''${font}''${color}
    ''${hr 1}
    ''${color1}Distro   ''${color2}''${execi 10000 . /etc/os-release && echo "$PRETTY_NAME"}
    ''${color1}Kernel   ''${color2}$kernel
    ''${color1}Uptime   ''${color2}$uptime

    ''${voffset 10}''${color1}''${font Symbols Nerd Font:Regular:size=14}''${font} ''${color1}CPU''${font}''${color}
    ''${hr 1}
    ''${color1}Usage   ''${color2}''${cpu cpu0}%
    ''${color1}Freq    ''${color2}$freq_g GHz
    ''${color1}Temp    ''${color2}''${if_match ''${hwmon k10temp temp 1}<80}''${hwmon k10temp temp 1}°C''${else}''${if_match ''${hwmon k10temp temp 1}<90}''${color3}''${hwmon k10temp temp 1}°C''${else}''${color3}''${blink ''${hwmon k10temp temp 1}°C}''${endif}''${endif}''${color2}

    ''${voffset 10}''${color1}''${font Symbols Nerd Font:Regular:size=14}''${font} ''${color1}RAM''${font}''${color}
    ''${hr 1}
    ''${color1}Used    ''${color2}$mem / $memmax
    ''${color1}Free    ''${color2}$memfree

    ''${voffset 10}''${color1}GPU (RTX 4060)''${font}''${color}
    ''${hr 1}
    ''${color1}VRAM   ''${color2}''${execi 2 nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits} / ''${execi 2 nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits} MiB
    ''${color1}Temp   ''${color2}''${execi 5 nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits}°C
    ''${color1}Load   ''${color2}''${execi 2 nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits}%

    ''${voffset 10}''${color1}''${font Symbols Nerd Font:Regular:size=14}󱛟''${font} ''${color1}STORAGE''${font}''${color}
    ''${hr 1}
    ''${color1}Root    ''${color2}''${fs_used /} / ''${fs_size /}
    ''${color2}''${fs_bar 5}
    ''${color1}Home    ''${color2}''${fs_used /home} / ''${fs_size /home}
    ''${color2}''${fs_bar 5 /home}

    ''${voffset 10}''${color1}''${font Symbols Nerd Font:Regular:size=14}''${font} ''${color1}NETWORK''${font}''${color}
    ''${hr 1}
    ''${color1}Wi-fi   ''${color2}''${execi 5 ${scripts}/ssid}
    ''${color1}Up      ''${color2}''${upspeed wlo1}
    ''${color1}Down    ''${color2}''${downspeed wlo1}
    ]];
  '';
}
