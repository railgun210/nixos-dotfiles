{
  lib,
  pkgs,
  ...
}:
{
  # Sway Wayland compositor — SwayFX (sway fork with blur, shadows, animations).
  # The overlay in flake.nix replaces sway-unwrapped with swayfx-unwrapped-git,
  # so the NixOS module wraps the SwayFX binary automatically.
  programs.sway = {
    enable = true;
    xwayland.enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway
    '';
  };

  programs.dconf.enable = true;

  # ── Hyprland ──────────────────────────────────────────────────────────────
  # Enable Hyprland alongside Sway. Both are selectable at the SDDM login screen.
  # programs.hyprland creates the .desktop file that SDDM uses for session selection.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # NOTE: defaultSession is intentionally removed so SDDM remembers
  # whichever session you last selected. Both Sway and Hyprland will
  # appear in the session dropdown on the login screen.

  # ── XDG desktop portal ───────────────────────────────────────────────────────

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    # Use xdg-desktop-portal-wlr-git from Chaotic-Nyx for the latest
    # Wayland screen-capture, screenshot, and RemoteDesktop support.
    # The wlr module has no 'package' option, so we override it via an
    # overlay in flake.nix (see overlay-chaotic-packages).
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      sway = {
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        default = [ "gtk" ];
      };
      hyprland = {
        "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
        "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        default = [ "gtk" ];
      };
      common.default = [ "gtk" ];
    };
  };

  # ── File manager (Thunar) ────────────────────────────────────────────────────

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-vcs-plugin
      thunar-dropbox-plugin
      thunar-media-tags-plugin
      thunar-volman
    ];
  };

  programs.xfconf.enable = true;

  environment.etc."udisks2/mount_options.conf".text = ''
    [defaults]
    ntfs_defaults=uid=$UID,gid=$GID
  '';

  # ── Filesystem performance ───────────────────────────────────────────────────
  #
  # BTRFS optimizations for SSD + desktop workload:
  #   compress=zstd — reduces disk I/O by compressing data in RAM before writing;
  #                   zstd offers the best ratio/speed tradeoff and is built into
  #                   the kernel. Reads are decompressed on the fly, which is fast
  #                   on modern CPUs and effectively increases SSD read throughput.
  #   noatime       — skips writing access-time metadata on every file read,
  #                   eliminating a huge source of small random writes.
  #   ssd           — tells BTRFS the device is an SSD, enabling TRIM/discard
  #                   and disabling page-cache alignment hacks meant for HDDs.
  #   discard=async — queues TRIM commands asynchronously so they don't block
  #                   the submitting thread; the kernel batches them via kworker.
  fileSystems."/".options = lib.mkAfter [
    "compress=zstd"
    "noatime"
    "ssd"
    "discard=async"
  ];
  fileSystems."/home".options = lib.mkAfter [
    "compress=zstd"
    "noatime"
    "ssd"
    "discard=async"
  ];

  # ── Cursor ───────────────────────────────────────────────────────────────────

  environment.variables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "16";
  };

  # ── Wayland core packages from Chaotic-Nyx ──────────────────────────────────
  #
  # Using the git version of wayland from Chaotic-Nyx to stay aligned with the
  # bleeding-edge SwayFX build. SwayFX bundles its own wlroots, so only the
  # wayland library is needed here.
  environment.systemPackages = with pkgs; [
    wayland_git
  ];

  # ── Wayland application compatibility ────────────────────────────────────────

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";

    # Disable driver vsync — gamescope handles its own presentation pipeline
    __GL_SYNC_TO_VBLANK = "0";
  };
}
