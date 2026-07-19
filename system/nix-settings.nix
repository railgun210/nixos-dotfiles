# system/nix-settings.nix
# Basic nix settings
{ ... }:
{
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Ryzen 5800X has 8 cores / 16 threads. Using 4 parallel builds
      # with 8 cores each cuts rebuild times by ~3-4x vs the previous
      # max-jobs=2/cores=2 which was bottlenecking every nixos-rebuild.
      max-jobs = 4;
      cores = 8;
      # Cachix binary cache for Doom Emacs
      substituters = [
        "https://doom-emacs-unstraightened.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "doom-emacs-unstraightened.cachix.org-1:O5oOlRPnmQEvVaFyuMTmthCEooHbrg54WgSLR07tmg4="
      ];
    };
    gc = {
      # Garabage collector to automatically delete old builds
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };
  system.stateVersion = "25.11";
}
