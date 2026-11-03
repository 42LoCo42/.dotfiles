{ pkgs, ... }: {
  home-manager.sharedModules = [{
    programs.zsh = {
      initContent = builtins.readFile ./zshrc.sh;

      plugins = [
        rec {
          inherit (src) name;
          src = pkgs.zsh-completions;
        }
      ];
    };
  }];
}
