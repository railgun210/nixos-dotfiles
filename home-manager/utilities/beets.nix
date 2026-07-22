# home-manager/utilities/beets.nix
# Music library manager with automatic album art fetching.
#
# Usage:
#   Import music:         beet import /path/to/music
#   Fetch art only:       beet fetchart [-f]          (-f forces re-fetch)
#   Embed art into tags:  beet embedart [-f]
#   View library:         beet list
#
# fetchart sources (searched in order):
#   filesystem -> coverart (MusicBrainz CAA) -> itunes -> amazon
#   Art is saved as cover.jpg alongside album tracks.
#
# embedart takes the cover.jpg and writes it into audio file metadata tags.
{ ... }:
{
  programs.beets = {
    enable = true;

    settings = {
      directory = "~/Music";
      library = "~/.local/share/beets/library.blb";

      import = {
        write = true;
        move = true;
      };

      plugins = [
        "fetchart"
        "embedart"
        "chroma"
        "deezer"
        "discogs"
        "fromfilename"
        "musicbrainz"
        "mbpseudo"
        "spotify"
        "tidal"
      ];

      fetchart = {
        auto = true;
        cautious = false;
        minwidth = 500;
        sources = [
          "coverart"
          "itunes"
          "amazon"
          "filesystem"
        ];
      };

      embedart = {
        auto = true;
        compare_threshold = 0;
        ifempty = false;
      };
    };
  };
}
