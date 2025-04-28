{
  home-manager.sharedModules = [{
    programs.zsh.initContent = builtins.readFile ./zshrc.sh;
  }];
}
