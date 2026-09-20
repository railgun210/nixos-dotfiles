{pkgs, ...}:
# Extra utilities installed alongside the MATE desktop.
# MATE itself (panel, applets, themes, session) is configured manually in Debian.
# This module only provides additional packages that complement the MATE session.
{
  home.packages = with pkgs; [
    # Screenshots (X11)
    flameshot

    # Clipboard tools (X11)
    xclip
    xdotool

    # Brightness control (works via backlight sysfs or ddcutil)
    brightnessctl

    # Archive manager
    file-roller

    # Image viewer
    eog

    # Polkit agent — handles privilege escalation dialogs in the desktop session
    polkit_gnome

    # Icon theme (from the buuf-icon-theme flake input via the overlay in
    # flake.nix). Select it in MATE Appearance after re-login.
    buuf-icon-theme
  ];

  # Debian's X11 session (LightDM -> Xsession) never reads HM's environment.d
  # file or ~/.zshenv, so MATE's panel/menu would not see ~/.nix-profile.
  # Xsession sources ~/.xsessionrc before starting mate-session; without this,
  # Nix apps have no .desktop entries in the MATE menu and aren't on PATH.
  # Takes effect on the next login.
  #
  # XDG_DATA_DIRS is usually UNSET when LightDM starts the session. Appending
  # to an unset value leaves only the nix dirs, which drops the implicit
  # /usr/local/share:/usr/share default. Debian's 55mate-session_materc then
  # sees a non-empty value and only prepends /usr/share/mate, so mate-session
  # can't find any GSettings schemas and aborts ("No GSettings schemas are
  # installed on the system"). Always seed the spec default first.
  home.file.".xsessionrc".text = ''
    export XDG_DATA_DIRS="$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
  '';
}
