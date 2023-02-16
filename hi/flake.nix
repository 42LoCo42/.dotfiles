{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager.url = github:nix-community/home-manager;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = github:nix-community/lanzaboote;
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-index-database, lanzaboote, ... }@attrs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        nix-index-database.nixosModules.nix-index
        lanzaboote.nixosModules.lanzaboote
      ];
    };
  };
}
