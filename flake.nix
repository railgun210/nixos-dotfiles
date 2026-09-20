{
  inputs = {
    # CORE =====================================================================
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SECRETS ==================================================================
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # THEMING ==================================================================
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cozette.url = "github:railgun210/cozette";
    hm-ricing-mode.url = "github:Markus328/hm-ricing-mode/fix-hm-module";
    buuf-icon-theme.url = "github:railgun210/buuf-gnome";

    # EDITOR ===================================================================
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    doomdir = {
      url = "github:railgun210/doom-emacs";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      stylix,
      cozette,
      buuf-icon-theme,
      hm-ricing-mode,
      nix-doom-emacs-unstraightened,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nix-doom-emacs-unstraightened.overlays.default
          (final: prev: { cozette = inputs.cozette.packages.${system}.default; })
          (final: prev: {
            buuf-icon-theme = inputs.buuf-icon-theme.packages.${system}.default;
          })
        ];
        config.allowUnfree = true;
      };
    in
    {
      formatter.${system} = pkgs.alejandra;

      homeConfigurations."railgun" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          nix-doom-emacs-unstraightened.homeModule
          hm-ricing-mode.homeManagerModules.hm-ricing-mode
          sops-nix.homeManagerModules.sops
          stylix.homeManagerModules.stylix
          ./home-manager/home.nix
        ];
      };
    };
}
