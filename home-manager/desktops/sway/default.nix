{
  pkgs,
  ...
}:
{
  imports = [
    ./sway.nix
    ./swaylock.nix
    ./swayidle.nix
  ];

  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;
    extraOptions = [ "--unsupported-gpu" ];
    xwayland = true;
    systemd.enable = true;
    extraSessionCommands = "";
  };

  wayland.windowManager.sway.config.bars = [ ];

  home.packages = with pkgs; [
    wf-recorder
  ];
}
