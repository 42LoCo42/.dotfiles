{
  topology.self.services.syncthing.info = "Central file synchronization hub";

  rice.syncthing = {
    enable = true;
    url = "https://sync.laniakea";
  };

  home-manager.sharedModules = [{
    services.syncthing.guiAddress = "0.0.0.0:8384";
  }];
}
