{
  rice.syncthing = {
    enable = true;
    url = "https://sync.laniakea";
  };

  home-manager.sharedModules = [{
    services.syncthing.guiAddress = "0.0.0.0:8384";
  }];
}
