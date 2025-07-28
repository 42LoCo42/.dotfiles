{ self, ... }: {
  imports = [ self.inputs.nix-index-database.nixosModules.nix-index ];
  programs.command-not-found.enable = false;

  home-manager.sharedModules = [{
    home.shellAliases = {
      nl = "nix-locate";
      nlr = "nl --regex";
    };

    programs.zsh.initContent = ''
      nlb() {
        nix-locate --regex "bin/$1$"
      }
    '';
  }];
}
