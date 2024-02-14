{
  inputs = {
    aquaris.url = "github:42loco42/aquaris";
    aquaris.inputs.nixpkgs.follows = "nixpkgs";

    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    obscura.url = "github:42loco42/obscura";
  };

  outputs = { self, aquaris, nixpkgs, ... }: aquaris.lib.aquarisSystems self;
}
