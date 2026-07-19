{
  config,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
in
{
  home.packages = [ pkgs.swaylock-effects ];

  xdg.configFile."swaylock/config".text = ''
    ignore-empty-password
    fade-in=0.2
    font=${config.stylix.fonts.monospace.name}
    clock
    timestr=%H:%M
    datestr=%A, %B %d
    screenshots
    show-failed-attempts
    disable-caps-lock-text
    indicator-idle-visible
    line-uses-inside
    effect-blur=7x3

    inside-color=#${c.base00}
    inside-clear-color=#${c.base0D}
    inside-ver-color=#${c.base0D}
    inside-wrong-color=#${c.base08}

    ring-color=#${c.base03}
    ring-clear-color=#${c.base0D}
    ring-ver-color=#${c.base0D}
    ring-wrong-color=#${c.base08}

    keyhl-color=#${c.base0D}
    bs-hl-color=#${c.base08}

    line-color=#${c.base01}
    line-clear-color=#${c.base0D}
    line-ver-color=#${c.base0D}
    line-wrong-color=#${c.base08}

    separator-color=#${c.base03}

    text-color=#${c.base05}
    text-clear-color=#${c.base05}
    text-ver-color=#${c.base05}
    text-wrong-color=#${c.base05}

    layout-text-color=#${c.base04}
  '';
}
