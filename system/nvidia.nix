# system/nvidia.nix
# NVIDIA RTX 4060 (Ada Lovelace) — Wayland/Sway optimized
#
# Sleep/suspend is intentionally disabled system-wide because the nvidia driver
# causes black screens or broken resume on this hardware. All suspend, hibernate,
# hybrid-sleep, and suspend-then-hibernate targets are turned off below.
# Use screen lock (swaylock) + DPMS off for security instead.
{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ── Graphics stack ───────────────────────────────────────────────────────────

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ── NVIDIA driver ────────────────────────────────────────────────────────────

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    open = false;

    nvidiaSettings = true;

    # Sleep is disabled system-wide — power management options are irrelevant.
    # On this RTX 4060, enabling powerManagement causes black screens on resume.
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    package = pkgs.nvidia_cachyos;
  };

  # ── Kernel modules ───────────────────────────────────────────────────────────

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];
  # sched-ext: scx_rusty is more mature than the default scx_rustland and
  # provides better NUMA-aware scheduling for desktop/gaming workloads on
  # multi-core CPUs like the Ryzen 5800X.
  services.scx = {
    enable = true;
    scheduler = "scx_rusty";
  };

  # ── Disable all sleep/hibernate targets ──────────────────────────────────────
  #
  # The nvidia driver does not suspend/resume reliably on this hardware.
  # Rather than fight broken sleep, we disable it entirely and rely on
  # screen lock (swaylock) + DPMS off for security.

  systemd.services.systemd-suspend.enable = false;
  systemd.services.systemd-hibernate.enable = false;
  systemd.services.systemd-hybrid-sleep.enable = false;
  systemd.services.systemd-suspend-then-hibernate.enable = false;

  # ── Wayland environment variables ────────────────────────────────────────────

  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
  };
}
