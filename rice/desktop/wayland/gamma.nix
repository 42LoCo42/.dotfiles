{ lib, config, ... }: lib.mkIf config.rice.desktop {
  home-manager.sharedModules = [{
    services.wlsunset = {
      enable = true;
      latitude = "54.3075";
      longitude = "13.0830";
    };
  }];
}
