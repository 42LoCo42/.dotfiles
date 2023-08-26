{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";
    nix-alien.inputs.flake-compat.follows = "lanzaboote/flake-compat";
    nix-alien.inputs.flake-utils.follows = "lanzaboote/flake-utils";
    nix-alien.inputs.nix-index-database.follows = "nix-index-database";

    obscura.url = "github:42loco42/obscura";
    obscura.inputs.nixpkgs.follows = "nixpkgs";
    obscura.inputs.flake-utils.follows = "lanzaboote/flake-utils";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.akyuro = let system = "x86_64-linux"; in
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix

          self.inputs.home-manager.nixosModules.home-manager
          self.inputs.nix-index-database.nixosModules.nix-index
          self.inputs.lanzaboote.nixosModules.lanzaboote
          self.inputs.obscura.nixosModules."9mount"

          ({
            environment.systemPackages =
              let
                pkgs = import nixpkgs { inherit system; };
              in
              [
                pkgs.grim
                self.inputs.nix-alien.packages.${system}.nix-alien
                self.inputs.obscura.packages.${system}.flameshot-fixed
                self.inputs.obscura.packages.${system}.SwayAudioIdleInhibit
              ];

            programs.nix-ld.enable = true;
          })
        ];
      };
  };
}
