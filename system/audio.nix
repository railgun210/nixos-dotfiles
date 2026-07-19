# system/audio.nix
# Audio configuration with PipeWire
{ config, pkgs, ... }:
{
  imports = [ 
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  # Disable PulseAudio (we use PipeWire)
  services.pulseaudio.enable = false;

  # Enable PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # RealtimeKit for audio priority
  security.rtkit.enable = true;

  # Audio utilities
  environment.systemPackages = with pkgs; [
    pamixer
    pavucontrol
    playerctl
  ];
}
