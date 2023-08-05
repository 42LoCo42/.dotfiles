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

    "9mount".url = "github:42loco42/flakes?dir=9mount";
    "9mount".inputs.nixpkgs.follows = "nixpkgs";
    "9mount".inputs.flake-utils.follows = "lanzaboote/flake-utils";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.akyuro = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix

        self.inputs.home-manager.nixosModules.home-manager
        self.inputs.nix-index-database.nixosModules.nix-index
        self.inputs.lanzaboote.nixosModules.lanzaboote
        self.inputs."9mount".nixosModules.default

        ({ self, ... }: {
          environment.systemPackages = with self.inputs.nix-alien.packages.${system}; [
            nix-alien
          ];
          programs.nix-ld.enable = true;
        })
      ];
    };
  };
}
