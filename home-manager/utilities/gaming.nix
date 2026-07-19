# home-manager/utilities/gaming.nix
# User-level gaming packages and configuration
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    goverlay # GUI for MangoHud
  ];
}
