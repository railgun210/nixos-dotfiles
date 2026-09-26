# home-manager/desktops/i3/i3status.nix
# Status line for the stock i3bar. Stylix has no i3status target, so the
# good/degraded/bad colours come straight from the Stylix palette.
{config, ...}: let
  c = config.lib.stylix.colors;
in {
  programs.i3status = {
    enable = true;
    enableDefault = false;

    general = {
      colors = true;
      interval = 5;
      color_good = "#${c.base0B}";
      color_degraded = "#${c.base0A}";
      color_bad = "#${c.base08}";
    };

    modules = {
      "wireless _first_" = {
        position = 1;
        settings = {
          format_up = "󰖩 %essid %quality";
          format_down = "󰖪 down";
        };
      };
      "ethernet _first_" = {
        position = 2;
        settings = {
          format_up = "󰈀 %ip";
          format_down = "";
        };
      };
      "cpu_usage" = {
        position = 3;
        settings.format = " %usage";
      };
      "cpu_temperature 0" = {
        position = 4;
        settings = {
          format = " %degrees°C";
          max_threshold = 85;
          path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp1_input";
        };
      };
      "memory" = {
        position = 5;
        settings = {
          format = " %used";
          threshold_degraded = "10%";
        };
      };
      "disk /" = {
        position = 6;
        settings.format = "󰋊 %avail";
      };
      "volume master" = {
        position = 7;
        settings = {
          format = " %volume";
          format_muted = " muted";
          device = "pulse";
        };
      };
      "tztime local" = {
        position = 8;
        settings.format = "%a %d %b  %H:%M";
      };
    };
  };
}
