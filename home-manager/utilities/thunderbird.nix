# home-manager/utilities/thunderbird.nix
# Thunderbird email client with Stylix theming
#
# Stylix doesn't have a built-in thunderbird target, so we manually
# generate userChrome.css from the base16 color palette.
{ config, ... }: {
  programs.thunderbird.enable = true;

  programs.thunderbird.profiles.default = {
    isDefault = true;
    settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    };
    userChrome = ''
      :root {
        --tb-bg: #${config.lib.stylix.colors.base00};
        --tb-bg-alt: #${config.lib.stylix.colors.base01};
        --tb-bg-selected: #${config.lib.stylix.colors.base02};
        --tb-fg: #${config.lib.stylix.colors.base05};
        --tb-fg-dim: #${config.lib.stylix.colors.base03};
        --tb-fg-bright: #${config.lib.stylix.colors.base06};
        --tb-border: #${config.lib.stylix.colors.base01};
        --tb-accent: #${config.lib.stylix.colors.base0D};
        --tb-link: #${config.lib.stylix.colors.base0C};
        --tb-warning: #${config.lib.stylix.colors.base08};
        --tb-folder: #${config.lib.stylix.colors.base0B};
      }

      #messengerWindow,
      #mail-toolbar,
      #tabmail-tabs,
      #titlebar {
        background-color: var(--tb-bg) !important;
        color: var(--tb-fg) !important;
      }

      #folderTree,
      #threadTree,
      #messagepane,
      .tree-view-container,
      treechildren {
        background-color: var(--tb-bg) !important;
        color: var(--tb-fg) !important;
      }

      treechildren::-moz-tree-row(selected) {
        background-color: var(--tb-bg-selected) !important;
      }

      treechildren::-moz-tree-row(current, focus) {
        background-color: var(--tb-bg-selected) !important;
        outline: none !important;
      }

      treechildren::-moz-tree-cell-text(selected) {
        color: var(--tb-fg-bright) !important;
        font-weight: bold !important;
      }

      treechildren::-moz-tree-twisty(selected) {
        color: var(--tb-accent) !important;
      }

      treechildren::-moz-tree-image(selected) {
        filter: brightness(1.2) !important;
      }

      treechildren::-moz-tree-row(hover) {
        background-color: var(--tb-bg-alt) !important;
      }

      treechildren::-moz-tree-cell-text(unread) {
        color: var(--tb-fg-bright) !important;
        font-weight: bold !important;
      }

      treechildren::-moz-tree-cell-text(hasUnreadMessages) {
        color: var(--tb-fg-bright) !important;
        font-weight: bold !important;
      }

      #folderTree treechildren::-moz-tree-cell-text(hasUnreadMessages) {
        color: var(--tb-fg-bright) !important;
      }

      #threadTree treechildren::-moz-tree-cell-text(unread) {
        color: var(--tb-fg-bright) !important;
      }

      .text-link,
      a {
        color: var(--tb-link) !important;
      }

      #mail-toolbar,
      #toolbar-menubar,
      #button-toolbar {
        background-color: var(--tb-bg-alt) !important;
        border-bottom: 1px solid var(--tb-border) !important;
      }

      #tabmail-tabs .tabmail-tab[selected] {
        background-color: var(--tb-bg-alt) !important;
        color: var(--tb-fg-bright) !important;
        border-bottom: 2px solid var(--tb-accent) !important;
      }

      #tabmail-tabs .tabmail-tab:not([selected]) {
        background-color: var(--tb-bg) !important;
        color: var(--tb-fg-dim) !important;
      }

      #tabmail-tabs .tabmail-tab:hover {
        background-color: var(--tb-bg-selected) !important;
      }

      .mail-toolbarbutton {
        color: var(--tb-fg) !important;
        fill: var(--tb-fg) !important;
      }

      .mail-toolbarbutton:hover {
        background-color: var(--tb-bg-selected) !important;
        color: var(--tb-fg-bright) !important;
      }

      #todayPane,
      #calendar-view-container {
        background-color: var(--tb-bg) !important;
        color: var(--tb-fg) !important;
      }

      .calendar-month-day-box {
        background-color: var(--tb-bg) !important;
        border-color: var(--tb-border) !important;
      }

      .calendar-month-day-box[selected] {
        background-color: var(--tb-bg-selected) !important;
      }

      input,
      select,
      textarea {
        background-color: var(--tb-bg) !important;
        color: var(--tb-fg) !important;
        border: 1px solid var(--tb-border) !important;
      }

      menupopup,
      menulist,
      panel {
        background-color: var(--tb-bg-alt) !important;
        color: var(--tb-fg) !important;
        border: 1px solid var(--tb-border) !important;
      }

      menuitem:hover {
        background-color: var(--tb-bg-selected) !important;
      }

      #status-bar {
        background-color: var(--tb-bg-alt) !important;
        color: var(--tb-fg-dim) !important;
      }

      .new-message-badge {
        background-color: var(--tb-accent) !important;
        color: var(--tb-bg) !important;
      }

      #attachment-view {
        background-color: var(--tb-bg-alt) !important;
      }

      #messageHeader {
        background-color: var(--tb-bg-alt) !important;
        color: var(--tb-fg) !important;
        border-bottom: 1px solid var(--tb-border) !important;
      }
    '';
  };
}
