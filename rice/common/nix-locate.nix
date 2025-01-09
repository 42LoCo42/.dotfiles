{ self, ... }: {
  imports = [ self.inputs.nix-index-database.nixosModules.nix-index ];
  programs.command-not-found.enable = false;

  home-manager.sharedModules = [{
    home.shellAliases = {
      nl = "nix-locate --top-level";
      nlr = "nl --regex";
    };
  }];
}
