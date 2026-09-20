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
      # Pinned to last commit compatible with Go 1.25 (nixpkgs 25.11).
      # Newer sops-nix requires Go 1.26 which 25.11 does not ship.
      url = "github:Mic92/sops-nix/13616fff713a9f94055c66f15687ebdc17a335df";
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
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
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
          hm-ricing-mode.homeManagerModules.hm-ricing-mode
          sops-nix.homeManagerModules.sops
          stylix.homeManagerModules.stylix
          ./home-manager/home.nix
        ];
      };
    };
}
