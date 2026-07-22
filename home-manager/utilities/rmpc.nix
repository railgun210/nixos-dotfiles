# home-manager/utilities/rmpc.nix
# Terminal-based MPD client with album art support.
# Connects to the local MPD instance and uses Stylix base16 colors for theming.
{
  config,
  lib,
  ...
}:
let
  c = config.lib.stylix.colors;
in
{
  programs.rmpc = {
    enable = true;
    config = ''
      #![enable(implicit_some)]
      #![enable(unwrap_newtypes)]
      #![enable(unwrap_variant_newtypes)]
      (
          address: "127.0.0.1:6600",
          password: None,
          theme: Some("stylix"),
          cache_dir: None,
          on_song_change: None,
          volume_step: 5,
          max_fps: 30,
          scrolloff: 0,
          wrap_navigation: false,
          enable_mouse: true,
          enable_config_hot_reload: true,
          status_update_interval_ms: 1000,
          rewind_to_start_sec: None,
          reflect_changes_to_playlist: false,
          select_current_song_on_change: false,
          browser_song_sort: [Disc, Track, Artist, Title],
          directories_sort: SortFormat(group_by_type: true, reverse: false),
          album_art: (
              method: Auto,
              max_size_px: (width: 1200, height: 1200),
              disabled_protocols: ["http://", "https://"],
              vertical_align: Center,
              horizontal_align: Center,
          ),
          keybinds: (
              global: {
                  ":":       CommandMode,
                  ",":       VolumeDown,
                  "s":       Stop,
                  ".":       VolumeUp,
                  "<Tab>":   NextTab,
                  "<S-Tab>": PreviousTab,
                  "1":       SwitchToTab("Queue"),
                  "2":       SwitchToTab("Directories"),
                  "3":       SwitchToTab("Albums"),
                  "4":       SwitchToTab("Playlists"),
                  "q":       Quit,
                  ">":       NextTrack,
                  "p":       TogglePause,
                  "<":       PreviousTrack,
                  "f":       SeekForward,
                  "z":       ToggleRepeat,
                  "x":       ToggleRandom,
                  "c":       ToggleConsume,
                  "v":       ToggleSingle,
                  "b":       SeekBack,
                  "~":       ShowHelp,
                  "?":       ShowHelp,
                  "u":       Update,
                  "U":       Rescan,
                  "I":       ShowCurrentSongInfo,
                  "O":       ShowOutputs,
                  "P":       ShowDecoders,
                  "R":       AddRandom,
              },
              navigation: {
                  "k":         Up,
                  "j":         Down,
                  "h":         Left,
                  "l":         Right,
                  "<Up>":      Up,
                  "<Down>":    Down,
                  "<Left>":    Left,
                  "<Right>":   Right,
                  "<C-k>":     PaneUp,
                  "<C-j>":     PaneDown,
                  "<C-h>":     PaneLeft,
                  "<C-l>":     PaneRight,
                  "<C-u>":     UpHalf,
                  "N":         PreviousResult,
                  "a":         Add,
                  "A":         AddAll,
                  "r":         Rename,
                  "n":         NextResult,
                  "g":         Top,
                  "<Space>":   Select,
                  "<C-Space>": InvertSelection,
                  "G":         Bottom,
                  "<CR>":      Confirm,
                  "i":         FocusInput,
                  "J":         MoveDown,
                  "<C-d>":     DownHalf,
                  "/":         EnterSearch,
                  "<C-c>":     Close,
                  "<Esc>":     Close,
                  "K":         MoveUp,
                  "D":         Delete,
                  "B":         ShowInfo,
              },
              queue: {
                  "D":       DeleteAll,
                  "<CR>":    Play,
                  "<C-s>":   Save,
                  "a":       AddToPlaylist,
                  "d":       Delete,
                  "C":       JumpToCurrent,
                  "X":       Shuffle,
              },
          ),
          search: (
              case_sensitive: false,
              mode: Contains,
              tags: [
                  (value: "any",         label: "Any Tag"),
                  (value: "artist",      label: "Artist"),
                  (value: "album",       label: "Album"),
                  (value: "albumartist", label: "Album Artist"),
                  (value: "title",       label: "Title"),
                  (value: "filename",    label: "Filename"),
                  (value: "genre",       label: "Genre"),
              ],
          ),
          artists: (
              album_display_mode: SplitByDate,
              album_sort_by: Date,
          ),
          tabs: [
              (
                  name: "Queue",
                  pane: Split(
                      direction: Horizontal,
                      panes: [(size: "40%", pane: Pane(AlbumArt)), (size: "60%", pane: Pane(Queue))],
                  ),
              ),
              (
                  name: "Directories",
                  pane: Pane(Directories),
              ),
              (
                  name: "Albums",
                  pane: Pane(Albums),
              ),
              (
                  name: "Playlists",
                  pane: Pane(Playlists),
              ),
          ],
      )
    '';
  };

  xdg.configFile."rmpc/themes/stylix.ron".text = ''
    #![enable(implicit_some)]
    #![enable(unwrap_newtypes)]
    #![enable(unwrap_variant_newtypes)]
    (
        background_color: Some("#${c.base00}"),
        text_color: Some("#${c.base05}"),
        header_background_color: Some("#${c.base01}"),
        modal_background_color: Some("#${c.base01}"),
        modal_backdrop: true,
        preview_label_style: (fg: "#${c.base0A}"),
        preview_metadata_group_style: (fg: "#${c.base0A}", modifiers: "Bold"),
        highlighted_item_style: (fg: "#${c.base0D}", modifiers: "Bold"),
        current_item_style: (fg: "#${c.base00}", bg: "#${c.base0D}", modifiers: "Bold"),
        borders_style: (fg: "#${c.base02}"),
        highlight_border_style: (fg: "#${c.base0D}"),
        format_tag_separator: " | ",
        multiple_tag_resolution_strategy: All,
        browser_column_widths: [20, 38, 42],
        symbols: (
            song: "󰝚",
            dir: "󰉋",
            playlist: "󰎈",
            marker: "󰆟",
            ellipsis: "...",
            song_style: None,
            dir_style: None,
            playlist_style: None,
            marker_style: None,
            song_highlighted_style: None,
            dir_highlighted_style: None,
            playlist_highlighted_style: None,
            marker_highlighted_style: None,
            song_current_style: None,
            dir_current_style: None,
            playlist_current_style: None,
            marker_current_style: None,
        ),
        level_styles: (
            info: (fg: "#${c.base0D}", bg: "#${c.base00}"),
            warn: (fg: "#${c.base0A}", bg: "#${c.base00}"),
            error: (fg: "#${c.base08}", bg: "#${c.base00}"),
            debug: (fg: "#${c.base0B}", bg: "#${c.base00}"),
            trace: (fg: "#${c.base0E}", bg: "#${c.base00}"),
        ),
        progress_bar: (
            symbols: ["█", "█", "█", " ", "█"],
            track_style: None,
            elapsed_style: (fg: "#${c.base0D}"),
            thumb_style: (fg: "#${c.base0D}"),
            use_track_when_empty: true,
        ),
        scrollbar: (
            symbols: ["│", "█", "▲", "▼"],
            track_style: (),
            ends_style: (),
            thumb_style: (fg: "#${c.base0D}"),
        ),
        tab_bar: (
            active_style: (fg: "#${c.base00}", bg: "#${c.base0D}", modifiers: "Bold"),
            inactive_style: (fg: "#${c.base05}"),
        ),
        lyrics: (
            timestamp: false,
        ),
        browser_song_format: [
            (
                kind: Group([
                    (kind: Property(Track)),
                    (kind: Text(" ")),
                ])
            ),
            (
                kind: Group([
                    (kind: Property(Artist)),
                    (kind: Text(" - ")),
                    (kind: Property(Title)),
                ]),
                default: (kind: Property(Filename))
            ),
        ],
        song_table_format: [
            (
                prop: (kind: Property(Artist),
                    default: (kind: Text("Unknown"))
                ),
                label_prop: (kind: Text("Artist")),
                width: "20%",
            ),
            (
                prop: (kind: Property(Title),
                    default: (kind: Text("Unknown"))
                ),
                label_prop: (kind: Text("Title")),
                width: "35%",
            ),
            (
                prop: (kind: Property(Album), style: (fg: "#${c.base07}"),
                    default: (kind: Text("Unknown Album"), style: (fg: "#${c.base07}"))
                ),
                label_prop: (kind: Text("Album")),
                width: "30%",
            ),
            (
                prop: (kind: Property(Duration),
                    default: (kind: Text("-"))
                ),
                label_prop: (kind: Text("Duration")),
                width: "15%",
                alignment: Right,
            ),
        ],
        layout: Split(
            direction: Vertical,
            panes: [
                (
                    size: "4",
                    pane: Split(
                        direction: Horizontal,
                        panes: [
                            (
                                size: "35",
                                borders: "LEFT | TOP | BOTTOM",
                                border_symbols: Inherited(parent: Rounded, bottom_left: "├"),
                                pane: Component("header_left")
                            ),
                            (
                                size: "100%",
                                borders: "ALL",
                                border_symbols: Inherited(parent: Rounded, top_left: "┬", top_right: "┬", bottom_left: "┴", bottom_right: "┴"),
                                pane: Component("header_center")
                            ),
                            (
                                size: "35",
                                borders: "RIGHT | TOP | BOTTOM",
                                border_symbols: Inherited(parent: Rounded, bottom_right: "┤"),
                                pane: Component("header_right")
                            ),
                        ]
                    )
                ),
                (
                    pane: Pane(Tabs),
                    borders: "RIGHT | LEFT | BOTTOM",
                    border_symbols: Rounded,
                    size: "2",
                ),
                (
                    pane: Pane(TabContent),
                    size: "100%",
                ),
                (
                    size: "3",
                    pane: Split(
                        direction: Horizontal,
                        panes: [
                            (
                                size: "12",
                                borders: "ALL",
                                border_symbols: Inherited(parent: Rounded, top_right: "┬", bottom_right: "┴"),
                                pane: Component("input_mode")
                            ),
                            (
                                size: "100%",
                                borders: "TOP | BOTTOM | RIGHT",
                                border_symbols: Rounded,
                                border_title: [(kind: Text(" ")), (kind: Property(Status(QueueLength()))), (kind: Text(" songs / ")), (kind: Property(Status(QueueTimeTotal()))), (kind: Text(" total time "))],
                                border_title_alignment: Right,
                                pane: Component("progress_bar"),
                            ),
                        ]
                    ),
                ),
            ],
        ),
        components: {
            "state": Pane(Property(
                content: [
                    (kind: Text("["), style: (fg: "#${c.base0A}", modifiers: "Bold")),
                    (kind: Property(Status(StateV2( ))), style: (fg: "#${c.base0A}", modifiers: "Bold")),
                    (kind: Text("]"), style: (fg: "#${c.base0A}", modifiers: "Bold")),
                ], align: Left,
            )),
            "title": Pane(Property(
                content: [
                    (kind: Property(Song(Title)), style: (modifiers: "Bold"),
                        default: (kind: Text("No Song"), style: (modifiers: "Bold"))),
                ], align: Center, scroll_speed: 12
            )),
            "volume": Split(
                direction: Horizontal,
                panes: [
                    (size: "1", pane: Pane(Property(content: [(kind: Text(""))]))),
                    (size: "100%", pane: Pane(Volume(kind: Slider(symbols: (filled: "─", thumb: "●", track: "─"))))),
                    (size: "3", pane: Pane(Property(content: [(kind: Property(Status(Volume)), style: (fg: "#${c.base0D}"))], align: Right))),
                    (size: "2", pane: Pane(Property(content: [(kind: Text("%"), style: (fg: "#${c.base0D}"))]))),
                ]
            ),
            "elapsed_and_bitrate": Pane(Property(
                content: [
                    (kind: Property(Status(Elapsed))),
                    (kind: Text(" / ")),
                    (kind: Property(Status(Duration))),
                    (kind: Group([
                        (kind: Text(" (")),
                        (kind: Property(Status(Bitrate))),
                        (kind: Text(" kbps)")),
                    ])),
                ], align: Left,
            )),
            "artist_and_album": Pane(Property(
                content: [
                    (kind: Property(Song(Artist)), style: (fg: "#${c.base0A}", modifiers: "Bold"),
                        default: (kind: Text("Unknown"), style: (fg: "#${c.base0A}", modifiers: "Bold"))),
                    (kind: Text(" - ")),
                    (kind: Property(Song(Album)), default: (kind: Text("Unknown Album"))),
                ], align: Center, scroll_speed: 12
            )),
            "states": Split(
                direction: Horizontal,
                panes: [
                    (
                        size: "1",
                        pane: Pane(Empty())
                    ),
                    (
                        size: "100%",
                        pane: Pane(Property(content: [(kind: Property(Status(InputBuffer())), style: (fg: "#${c.base0D}"), align: Left)]))
                    ),
                    (
                        size: "6",
                        pane: Pane(Property(content: [
                            (kind: Text("["), style: (fg: "#${c.base0D}", modifiers: "Bold")),
                            (kind: Property(Status(RepeatV2(
                                on_label: "z",
                                off_label: "z",
                                on_style: (fg: "#${c.base0A}", modifiers: "Bold"),
                                off_style: (fg: "#${c.base0D}", modifiers: "Dim"),
                            )))),
                            (kind: Property(Status(RandomV2(
                                on_label: "x",
                                off_label: "x",
                                on_style: (fg: "#${c.base0A}", modifiers: "Bold"),
                                off_style: (fg: "#${c.base0D}", modifiers: "Dim"),
                            )))),
                            (kind: Property(Status(ConsumeV2(
                                on_label: "c",
                                off_label: "c",
                                oneshot_label: "c",
                                on_style: (fg: "#${c.base0A}", modifiers: "Bold"),
                                off_style: (fg: "#${c.base0D}", modifiers: "Dim"),
                                oneshot_style: (fg: "#${c.base08}", modifiers: "Dim"),
                            )))),
                            (kind: Property(Status(SingleV2(
                                on_label: "v",
                                off_label: "v",
                                oneshot_label: "v",
                                on_style: (fg: "#${c.base0A}", modifiers: "Bold"),
                                off_style: (fg: "#${c.base0D}", modifiers: "Dim"),
                                oneshot_style: (fg: "#${c.base08}", modifiers: "Bold"),
                            )))),
                            (kind: Text("]"), style: (fg: "#${c.base0D}", modifiers: "Bold")),
                            ], align: Right
                        ))
                    ),
                ]
            ),
            "input_mode": Pane(Property(
                content: [
                    (kind: Transform(Replace(content: (kind: Property(Status(InputMode()))), replacements: [
                        (match: "Normal", replace: (kind: Text(" NORMAL "), style: (fg: "#${c.base00}", bg: "#${c.base0D}"))),
                        (match: "Insert", replace: (kind: Text(" INSERT "), style: (fg: "#${c.base00}", bg: "#${c.base0B}"))),
                    ])))
                ], align: Center
            )),
            "header_left": Split(
                direction: Vertical,
                panes: [
                    (size: "1", pane: Component("state")),
                    (size: "1", pane: Component("elapsed_and_bitrate")),
                ]
            ),
            "header_center": Split(
                direction: Vertical,
                panes: [
                    (size: "1", pane: Component("title")),
                    (size: "1", pane: Component("artist_and_album")),
                ]
            ),
            "header_right": Split(
                direction: Vertical,
                panes: [
                    (size: "1", pane: Component("volume")),
                    (size: "1", pane: Component("states")),
                ]
            ),
            "progress_bar": Split(
                direction: Horizontal,
                panes: [
                    (
                        size: "1",
                        pane: Pane(Empty())
                    ),
                    (
                        size: "100%",
                        pane: Pane(ProgressBar)
                    ),
                    (
                        size: "1",
                        pane: Pane(Empty())
                    ),
                ]
            )
        },
    )
  '';
}
