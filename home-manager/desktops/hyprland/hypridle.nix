{
  pkgs,
  ...
}:
{
  # ── Hypridle ──────────────────────────────────────────────────────────────
  # Idle manager for Hyprland. Same timeouts as swayidle:
  #   300s (5 min) — lock screen
  #   600s (10 min) — turn off displays (DPMS)
  #
  # NOTE: System sleep is disabled (see system/nvidia.nix).
  # Only screen lock and DPMS are used here — no systemctl sleep calls.
  #
  # To change timeouts, edit the 'timeout' values below (in seconds).
  # To disable DPMS, remove or comment out the second listener block.
  home.packages = [ pkgs.hypridle ];

  xdg.configFile."hypr/hypridle.conf".text = ''
    # Lock the screen after 5 minutes (300 seconds)
    listener {
        timeout = 300
        on-timeout = hyprlock
    }

    # Turn off displays after 10 minutes (600 seconds)
    # Displays turn back on automatically on mouse/keyboard activity
    listener {
        timeout = 600
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
    }
  '';
}
