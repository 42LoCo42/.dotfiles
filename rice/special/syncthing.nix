{ config, lib, ... }: lib.mkIf config.rice.syncthing {
  home-manager.sharedModules = [{
    aquaris.persist = [ ".local/state/syncthing" ];
    services.syncthing.enable = true;
  }];
}
