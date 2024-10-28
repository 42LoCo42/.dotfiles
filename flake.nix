{
  inputs = {
    aquaris.url = "github:42loco42/aquaris";
    aquaris.inputs.home-manager.follows = "home-manager";
    aquaris.inputs.nixpkgs.follows = "nixpkgs";
    aquaris.inputs.obscura.follows = "obscura";

    avh.url = "github:42loco42/avh";
    avh.inputs.flake-utils.follows = "aquaris/flake-utils";
    avh.inputs.nixpkgs.follows = "nixpkgs";

    chronometer.url = "github:42loco42/chronometer";
    chronometer.inputs.flake-utils.follows = "aquaris/flake-utils";
    chronometer.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixos-router.url = "github:42LoCo42/nixos-router";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    obscura.url = "github:42loco42/obscura";

    pinlist.url = "github:42loco42/pinlist";
    pinlist.inputs.flake-utils.follows = "aquaris/flake-utils";
    pinlist.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { aquaris, self, ... }: aquaris self rec {
    mainSSHKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdkJo7RMoxUkuQ55YT1q5KANHrR+OJZzeYejpJW4rty";

    masterKeys = [ mainSSHKey ];

    users = {
      leonsch = {
        description = "Leon Schumacher";
        sshKeys = [ mainSSHKey ];
        git = {
          email = "leonsch@protonmail.com";
          key = mainSSHKey;
        };
      };

      admin = {
        description = "Server Admin Account";
        sshKeys = [ mainSSHKey ];
      };
    };
  };
}
