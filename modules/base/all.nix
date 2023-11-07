{ ... }: {
  imports = [
    ./nix-settings.nix
    ./secrets.nix
    ./system.nix
    ./user.nix
  ];
}
