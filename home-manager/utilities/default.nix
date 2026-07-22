# home-manager/utilities/default.nix
# Utilities shared across desktop configurations.
{ ... }:
{
  imports = [
    ./dunst.nix
    ./borg-backup.nix
    ./common-packages.nix
    ./devshells
    ./development-tools.nix
    ./doom.nix
    ./floorp.nix
    ./gaming.nix
    ./ghostty.nix
    ./kitty.nix
    ./mpd.nix
    ./mpd-mpris.nix
    ./rmpc.nix
    ./beets.nix
    ./p10k.nix
    ./thunderbird.nix
    ./ssh.nix
    ./vscode.nix
    ./zsh.nix
  ];
}
