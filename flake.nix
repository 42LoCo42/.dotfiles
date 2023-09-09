{
  inputs = {
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    # nix-alien.url = "github:thiagokokada/nix-alien";
    # nix-alien.inputs.nixpkgs.follows = "nixpkgs";
    # nix-alien.inputs.flake-compat.follows = "lanzaboote/flake-compat";
    # nix-alien.inputs.flake-utils.follows = "lanzaboote/flake-utils";
    # nix-alien.inputs.nix-index-database.follows = "nix-index-database";

    obscura.url = "github:42loco42/obscura";
    obscura.inputs.nixpkgs.follows = "nixpkgs";
    obscura.inputs.flake-utils.follows = "lanzaboote/flake-utils";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations =
      let
        dir = ./machines;
        # include pipe from pkgs.lib.trivial since we can't import nixpkgs here
        pipe = val: functions:
          let reverseApply = x: f: f x;
          in builtins.foldl' reverseApply val functions;
      in
      pipe dir [
        builtins.readDir
        builtins.attrNames
        (map (name: {
          inherit name;
          value = import "${dir}/${name}" { inherit self nixpkgs; };
        }))
        builtins.listToAttrs
      ];
  };
}
