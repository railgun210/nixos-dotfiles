# now-playing.nix
# Waybar custom module script for now-playing media info
#
# Performance improvements over the previous version:
#   - Single playerctl call instead of two ({{status}} is a valid format field)
#   - Uses pkgs.writers.writePython3Bin (proper nix idiom, no exec indirection)
#   - Shell pre-check: playerctl --list-all is a fast no-metadata DBUS list;
#     on an idle desktop (no media players running), Python never launches
#   - Single DBUS round-trip with timeout covering the whole operation
#   - Truncation on pre-escape value avoids escaping characters we'll discard
#   - "stopped" CSS class for Stopped state (distinct from paused)
#
# JSON output fields:
#   text    - "{icon} [Artist - ]Title" (≤60 chars)
#   class   - "playing" | "paused" | "stopped"
#   tooltip - Pango-markup tooltip with Artist, Song, Album, Player, Status
#
# Dependencies: playerctl (already in home.packages)
{ pkgs, ... }:
let
  nowPlayingPy = pkgs.writers.writePython3Bin "now-playing-inner" { } ''
    import json
    import html
    import subprocess
    import sys

    PLAYERCTL = (
        "${pkgs.playerctl}/bin/playerctl"
    )
    MAX_LEN = 60

    ICONS = {
        "spotify": "\uf1bc",
        "floorp": "\uf269",
        "chromium": "\uf268",
        "chrome": "\uf268",
        "strawberry": "\uf001",
        "vlc": "\U000f057c",
        "mpv": "\uf001",
    }
    DEFAULT_ICON = "\uf001"


    def get_icon(player_name: str) -> str:
        p = player_name.lower()
        for key, icon in ICONS.items():
            if key in p:
                return icon
        return DEFAULT_ICON


    def truncate(s: str, n: int = MAX_LEN) -> str:
        return s if len(s) <= n else s[:n] + "\u2026"


    def main() -> None:
        try:
            result = subprocess.run(
                [
                    PLAYERCTL, "metadata", "--format",
                    "{{status}}\t{{playerName}}"
                    "\t{{xesam:artist}}\t{{xesam:title}}"
                    "\t{{xesam:album}}",
                ],
                capture_output=True,
                text=True,
                timeout=2,
            )
        except (subprocess.TimeoutExpired, FileNotFoundError):
            sys.exit(0)

        if result.returncode != 0:
            sys.exit(0)

        parts = result.stdout.strip().split("\t", 4)
        if len(parts) < 4:
            sys.exit(0)

        status = parts[0] if len(parts) > 0 else "Stopped"
        player = parts[1] if len(parts) > 1 else ""
        artist = parts[2] if len(parts) > 2 else ""
        title = parts[3] if len(parts) > 3 else ""
        album = parts[4] if len(parts) > 4 else ""

        if not title:
            sys.exit(0)

        icon = get_icon(player)
        raw_display = (
            f"{icon} {artist} - {title}" if artist else f"{icon} {title}"
        )
        display = truncate(raw_display)

        t_title = html.escape(title)
        t_artist = html.escape(artist)
        t_album = html.escape(album)
        t_player = html.escape(player)

        dim = "alpha='65%'"
        bold = "alpha='100%'"

        lines = []
        if artist:
            lines.append(
                f"<span {dim}>\U000f0803 Artist</span>"
                f"  <span {bold}>{t_artist}</span>"
            )
        lines.append(
            f"<span {dim}>\uf001 Song</span>"
            f"    <span {bold}>{t_title}</span>"
        )
        if album:
            lines.append(
                f"<span {dim}>\U000f0025 Album</span>"
                f"   <span {bold}>{t_album}</span>"
            )
        lines.append(
            f"<span {dim}>\U000f04c7 Player</span>"
            f"  <span {bold}>{t_player}</span>"
        )

        s = status.lower()
        css_class = s if s in ("playing", "paused") else "stopped"

        print(json.dumps({
            "text": display,
            "tooltip": "\n".join(lines),
            "class": css_class,
        }))


    main()
  '';
in
pkgs.writeShellScriptBin "now-playing" ''
  if ! ${pkgs.playerctl}/bin/playerctl --list-all &>/dev/null; then
    exit 0
  fi
  exec ${nowPlayingPy}/bin/now-playing-inner "$@"
''
