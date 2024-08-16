{
  inputs = {
    aquaris.url = "github:42loco42/aquaris/rewrite";
    aquaris.inputs.home-manager.follows = "home-manager";
    aquaris.inputs.nixpkgs.follows = "nixpkgs";
    aquaris.inputs.obscura.follows = "obscura";

    avh.url = "github:42loco42/avh";
    avh.inputs.flake-utils.follows = "aquaris/flake-utils";
    avh.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    obscura.url = "github:42loco42/obscura";

    pinlist.url = "github:42loco42/pinlist";
    pinlist.inputs.flake-utils.follows = "aquaris/flake-utils";
    pinlist.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { aquaris, self, ... }: aquaris self rec {
    mainSSHKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql";

    users = {
      leonsch = {
        description = "Leon Schumacher";
        sshKeys = [ mainSSHKey ];

        git = {
          email = "leonsch@protonmail.com";
          key = "C743EE077172986F860FC0FE2F6FE1420970404C";
        };
      };
    };
  };
}
