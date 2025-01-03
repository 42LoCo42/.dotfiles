{ config, lib, ... }: {
  options.rice.syncthing.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.syncthing.enable {
    home-manager.sharedModules = [{
      aquaris.persist = { ".local/state/syncthing" = { }; };
      services.syncthing.enable = true;
    }];
  };
}
