{
  home-manager.sharedModules = [{
    programs.zsh.initExtra = builtins.readFile ./zshrc.sh;
  }];
}
