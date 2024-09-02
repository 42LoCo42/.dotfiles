{ ... }: {
  home-manager.sharedModules = [{
    aquaris.persist = [ ".local/state/syncthing" ];
    services.syncthing.enable = true;
  }];
}
