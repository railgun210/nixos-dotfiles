{
  config,
  lib,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
in
{
  programs.bemenu = {
    enable = true;

    settings = {
      tb = lib.mkForce "#${c.base00}";
      tf = lib.mkForce "#${c.base0D}";
      fb = lib.mkForce "#${c.base00}";
      ff = lib.mkForce "#${c.base05}";
      nb = lib.mkForce "#${c.base00}";
      nf = lib.mkForce "#${c.base05}";
      hb = lib.mkForce "#${c.base0D}";
      hf = lib.mkForce "#${c.base00}";
      fn = lib.mkForce (config.utils.fonts.describeFont config.utils.fonts.status);
    };
  };

  home.packages = with pkgs; [ bemoji ];
}
