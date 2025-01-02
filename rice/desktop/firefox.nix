{ lib, config, ... }: {
  options.rice.desktop.firefox.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.firefox.enable {
    home-manager.sharedModules = [{
      aquaris.firefox = {
        enable = true;
        cleanHome = false;
      };
    }];
  };
}
