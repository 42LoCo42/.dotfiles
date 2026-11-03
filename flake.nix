{
  inputs = {
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
    };

    aquaris = {
      url = "github:42loco42/aquaris";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        obscura.follows = "obscura";
      };
    };

    fjordlauncher = {
      url = "github:unmojang/FjordLauncher/11.0.3.0";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs = {
        nixpkgs.follows = "";
        flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
      };
    };

    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

    obscura.url = "github:42loco42/obscura";
  };

  outputs = { aquaris, self, ... }: aquaris self rec {
    ssh = {
      ercanar = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvIf8izKUWon2BIHuzmGxqzt4duidgP2yEpSUcRu3rA";
      mel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxPD8M1DV0k5QY283lo0QIpmUYCjUlYvHwKYkk8j9Gn";
      nori = {
        fido = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBH2eZZkiQ53veJRiLi/JbVU/CD2oKC/TN7Ope3LiCChAAAABHNzaDo=";
        main = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdkJo7RMoxUkuQ55YT1q5KANHrR+OJZzeYejpJW4rty";
      };
    };

    users = {
      admin = {
        description = "Server Admin Account";
        sshKeys = with ssh; [ nori.fido ];
      };

      ercanar = {
        description = "Hannes Wendt";
        sshKeys = with ssh; [ ercanar nori.fido ];
        git = {
          email = "hanneswendt22@gmail.com";
          key = ssh.ercanar;
        };
      };

      mel = {
        description = "Melinda";
        sshKeys = with ssh; [ mel nori.fido ];
      };

      nori = {
        description = "Eleonora";
        sshKeys = with ssh; [ nori.fido ];
        git = {
          email = "leonsch@protonmail.com";
          key = ssh.nori.main;
        };
      };
    };
  };
}
