{ lib, config, ... }: lib.mkIf config.rice.desktop {
  home-manager.sharedModules = [{
    aquaris.firefox = {
      enable = true;
      cleanHome = false;
    };
  }];
}
