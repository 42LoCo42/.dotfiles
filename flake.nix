{
  inputs = {
    aquaris.url = "github:42loco42/aquaris";
    aquaris.inputs.home-manager.follows = "home-manager";
    aquaris.inputs.nixpkgs.follows = "nixpkgs";
    aquaris.inputs.obscura.follows = "obscura";

    avh.url = "github:42loco42/avh";
    avh.inputs.flake-utils.follows = "aquaris/flake-utils";
    avh.inputs.nixpkgs.follows = "nixpkgs";
    avh.inputs.obscura.follows = "obscura";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    obscura.url = "github:42loco42/obscura";

    pinlist.url = "github:42loco42/pinlist";
    pinlist.inputs.nixpkgs.follows = "nixpkgs";
    pinlist.inputs.flake-utils.follows = "aquaris/flake-utils";

    stylix.url = "github:danth/stylix";
    stylix.inputs.home-manager.follows = "home-manager";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, aquaris, ... }:
    let
      users = {
        # for personal systems
        leonsch = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql";
          git = {
            name = "Eleonora";
            email = "leonsch@protonmail.com";
            key = "C743EE077172986F860FC0FE2F6FE1420970404C";
          };
        };

        # for servers
        admin = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiwOxk510hj/zeputisjNvzkMgSfnKSqqVaIBjasO09";
          extraKeys = [ users.leonsch.publicKey ];
        };

        # for testing stuff
        dev = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGU5yJfnChhNtv176WJ1Zqg+Q8Vph+Mk96HwCk94z+yt";
          extraKeys = [ users.leonsch.publicKey ];
        };

        coder = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPU1Mi6swudVo9JkJl8Og/fzr+gCJTQ2bK4qd652IOgz";
          extraKeys = [
            users.leonsch.publicKey
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILckymOuvsGYKZxW2EuTaBoQUBaamDNCoCygxIWz/3cF"
          ];
        };
      };

      machines = {
        # pc
        astylos = {
          id = "79ac9d33c2bae577ba349fcd664df8a4";
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBAXjwzaVjqP489PKDGHGkFdioYBrD0Fn/LdJ95MPMk+";
          admins = { inherit (users) leonsch; };
        };

        # laptop
        akyuro = {
          id = "86b0e292e1fc27eb4168defa65cb41fd";
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBdZDuw+7O6+pV13ObPR/H4P8UCc1FzPmkufeaiJUc75";
          admins = { inherit (users) leonsch; };
        };

        # server
        bunny = {
          id = "488cb972c1ac70db8307933f65d5defc";
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBbsL7HyOCM56ejtlWqEBG1YzQwX2KmZ3S5KzoGnWh/j";
          admins = { inherit (users) admin; };
          users = { inherit (users) coder; };
        };

        # live ISO
        guanyin = {
          id = "99f7c536ac386aeb32291d4e65f549dc";
          admins.root = { };
        };

        # incubator VM
        kyubey = {
          id = "b6afc8210c5187e9ecd3d6ea664f3746";
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeJBR85DERUH5gKDVot2DgTxNcxzgDFXUOouOCaI36f";
          admins = { inherit (users) dev; };
        };
      };
    in
    aquaris.lib.main self { inherit users machines; };
}
