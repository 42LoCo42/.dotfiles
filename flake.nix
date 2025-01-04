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

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    obscura.url = "github:42loco42/obscura";
  };

  outputs = { aquaris, self, ... }: aquaris self rec {
    mainSSHKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBH2eZZkiQ53veJRiLi/JbVU/CD2oKC/TN7Ope3LiCChAAAABHNzaDo=";

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
