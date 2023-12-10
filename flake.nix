{
  inputs = {
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # nix-alien.url = "github:thiagokokada/nix-alien";
    # nix-alien.inputs.nixpkgs.follows = "nixpkgs";
    # nix-alien.inputs.flake-compat.follows = "lanzaboote/flake-compat";
    # nix-alien.inputs.flake-utils.follows = "lanzaboote/flake-utils";
    # nix-alien.inputs.nix-index-database.follows = "nix-index-database";

    obscura.url = "github:42loco42/obscura";

    disko.inputs.nixpkgs.follows = "nixpkgs";

    und.url = "github:42loco42/und";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";
    agenix.inputs.darwin.follows = "";

    nyxpkgs.url = "github:notashelf/nyxpkgs";
  };

  outputs = { self, nixpkgs, ... }: {
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
