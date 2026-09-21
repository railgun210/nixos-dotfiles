# home-manager/utilities/default.nix
# Utilities shared across desktop configurations.
{...}: {
  imports = [
    ./anki.nix
    ./default-apps.nix
    ./borg-backup.nix
    ./common-packages.nix
    ./devshells
    ./development-tools.nix
    ./doom.nix
    ./retroarch.nix
    ./ghostty.nix
    ./kitty.nix
    ./thunderbird.nix
    ./ssh.nix
    ./vscode.nix
    ./zsh.nix
  ];
}
