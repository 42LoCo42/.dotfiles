{
  inputs = {
    aquaris.url = "github:42loco42/aquaris";
    aquaris.inputs.home-manager.follows = "home-manager";
    aquaris.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    obscura.url = "github:42loco42/obscura";
  };

  outputs = { self, aquaris, nixpkgs, ... }:
    let
      users = {
        leonsch = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql";
          git = {
            name = "Eleonora";
            email = "leonsch@protonmail.com";
            key = "C743EE077172986F860FC0FE2F6FE1420970404C";
          };
        };

        admin = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiwOxk510hj/zeputisjNvzkMgSfnKSqqVaIBjasO09";
        };
      };

      machines = {
        akyuro = {
          id = "86b0e292e1fc27eb4168defa65cb41fd";
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBdZDuw+7O6+pV13ObPR/H4P8UCc1FzPmkufeaiJUc75";
          admins = { inherit (users) leonsch; };
        };

        bunny = {
          id = "488cb972c1ac70db8307933f65d5defc";
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBbsL7HyOCM56ejtlWqEBG1YzQwX2KmZ3S5KzoGnWh/j";
          admins = { inherit (users) admin; };
        };
      };
    in
    aquaris.lib.main self { inherit users machines; } //
    aquaris.inputs.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; }; in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            gopls
            nodePackages.prettier
          ];
        };
      });

}
