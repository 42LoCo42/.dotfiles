{
  inputs = {
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.flake-utils.follows = "flake-utils";

    # nix-alien.url = "github:thiagokokada/nix-alien";
    # nix-alien.inputs.nixpkgs.follows = "nixpkgs";
    # nix-alien.inputs.flake-compat.follows = "lanzaboote/flake-compat";
    # nix-alien.inputs.flake-utils.follows = "lanzaboote/flake-utils";
    # nix-alien.inputs.nix-index-database.follows = "nix-index-database";

    obscura.url = "github:42loco42/obscura";
    obscura.inputs.nixpkgs.follows = "nixpkgs";
    obscura.inputs.flake-utils.follows = "flake-utils";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.inputs.utils.follows = "flake-utils";
    deploy-rs.inputs.flake-compat.follows = "lanzaboote/flake-compat";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
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

      deploy = config:
        let
          system = config.pkgs.system;
          pkgs = import nixpkgs { inherit system; };
          deployPkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.inputs.deploy-rs.overlay
              (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
            ];
          };
        in
        {
          profiles.system = {
            user = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos config;
          };
        };
    in
    (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; }; in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            deploy-rs
            just
          ];
        };
      })) // {
      inherit nixosConfigurations;

      deploy.nodes = {
        "test" = {
          hostname = "192.168.122.98";
        } // (deploy nixosConfigurations.test);
      };
    };
}
