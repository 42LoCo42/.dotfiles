{
  inputs = {
    aquaris.url = "github:42loco42/aquaris";
    aquaris.inputs.home-manager.follows = "home-manager";
    aquaris.inputs.nixpkgs.follows = "nixpkgs";
    aquaris.inputs.obscura.follows = "obscura";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixos-router.url = "github:42LoCo42/nixos-router";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    obscura.url = "github:42loco42/obscura";
  };

  outputs = { aquaris, self, ... }: aquaris self rec {
    mainSSHKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdkJo7RMoxUkuQ55YT1q5KANHrR+OJZzeYejpJW4rty";

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
