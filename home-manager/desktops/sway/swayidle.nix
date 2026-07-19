{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.swayidle ];

  xdg.configFile."swayidle/config".text = ''
    # NOTE: System sleep is disabled (see system/nvidia.nix).
    # Only screen lock and DPMS are used here — no systemctl sleep calls.
    # 300s (5 min) — Lock the screen with swaylock
    timeout 300 '${pkgs.swaylock-effects}/bin/swaylock -f'
    # 600s (10 min) — Turn off displays via DPMS; resume turns them back on on activity
    timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"'
  '';
}
