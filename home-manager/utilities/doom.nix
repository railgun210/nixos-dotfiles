# home-manager/utilities/doom.nix
# Doom Emacs via nix-doom-emacs-unstraightened
{ inputs, pkgs, ... }:
let
  aspellDicts = pkgs.buildEnv {
    name = "aspell-dicts-merged";
    paths = [
      pkgs.aspellDicts.en
      pkgs.aspellDicts.es
    ];
  };
in
{
  programs.doom-emacs = {
    enable = true;
    doomDir = inputs.doomdir;
    emacs = pkgs.emacs-pgtk;
    extraBinPackages = with pkgs; [
      ripgrep
      fd
      git
      ispell
      aspell
    ];
  };

  home.sessionVariables.ASPELL_CONF = "dict-dir ${aspellDicts}/lib/aspell";

  # Run emacs daemon on boot
  services.emacs.enable = true;
}
