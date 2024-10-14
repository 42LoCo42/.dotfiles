{ self, ... }: {
  imports = [ self.inputs.nix-index-database.nixosModules.nix-index ];
  programs.command-not-found.enable = false;
}
