{ pkgs, ... }: {
  home-manager.sharedModules = [{
    programs.zsh = {
      initContent = builtins.readFile ./zshrc.sh;

      plugins = [
        rec {
          name = "zsh-ssh";

          src = pkgs.fetchFromGitHub {
            owner = "sunlei";
            repo = name;
            rev = "cee8c2a119dd53f01dc6aef1ce79faa783aa2e3f";
            hash = "sha256-1yJasYai4+T8j76lCvIhSFh4fm7VUoF4F4E+v8WSr2I=";
          };
        }
      ];
    };
  }];
}
