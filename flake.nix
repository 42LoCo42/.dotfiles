{
  inputs = {
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    # lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    # lanzaboote.inputs.flake-utils.follows = "flake-utils";

    # nix-alien.url = "github:thiagokokada/nix-alien";
    # nix-alien.inputs.nixpkgs.follows = "nixpkgs";
    # nix-alien.inputs.flake-compat.follows = "lanzaboote/flake-compat";
    # nix-alien.inputs.flake-utils.follows = "lanzaboote/flake-utils";
    # nix-alien.inputs.nix-index-database.follows = "nix-index-database";

    obscura.url = "github:42loco42/obscura";
    obscura.inputs.nixpkgs.follows = "nixpkgs";
    obscura.inputs.flake-utils.follows = "flake-utils";

    disko.inputs.nixpkgs.follows = "nixpkgs";

    und.url = "github:42loco42/und";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";
    agenix.inputs.darwin.follows = "";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: {
    apps = self.inputs.und.und self;
    nixosConfigurations =
      let dir = ./machines; in nixpkgs.lib.pipe dir [
        builtins.readDir
        builtins.attrNames
        (map (name: {
          inherit name;
          value = import "${dir}/${name}" {
            inherit self nixpkgs;
            my-utils = import ./modules/utils.nix {
              inherit (self.inputs) nixpkgs home-manager;
            };
          };
        }))
        builtins.listToAttrs
      ];
  };
}
