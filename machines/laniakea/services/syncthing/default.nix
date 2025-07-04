{
  rice.syncthing.enable = true;

  home-manager.sharedModules = [{
    services.syncthing.guiAddress = "0.0.0.0:8384";
  }];
}
