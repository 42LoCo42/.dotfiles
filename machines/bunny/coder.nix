{ ... }:
let
  nixos-vscode-server = builtins.getFlake "github:nix-community/nixos-vscode-server/fc900c16efc6a5ed972fb6be87df018bcf3035bc?narHash=sha256-8PDNi/dgoI2kyM7uSiU4eoLBqUKoA%2B3TXuz%2BVWmuCOc%3D";
in
{
  home-manager.users.coder = {
    imports = [ nixos-vscode-server.homeModules.default ];
    services.vscode-server.enable = true;
  };
}
