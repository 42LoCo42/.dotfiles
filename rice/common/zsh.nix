# TODO upstream this to Aquaris

{
  home-manager.sharedModules = [{
    programs.zsh = {
      history = {
        append = true;
        extended = true;
        ignoreAllDups = true;
        ignorePatterns = [ "l" "n" ];
      };
    };
  }];
}
