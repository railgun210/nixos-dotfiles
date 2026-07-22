# home-manager/utilities/mpd-mpris.nix
# Bridges MPD to the MPRIS D-Bus interface so waybar and other
# MPRIS-aware tools (playerctl, etc.) can detect and control MPD.
{ config, ... }:
{
  services.mpd-mpris = {
    enable = true;
  };
}
