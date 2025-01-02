{ lib, config, ... }: {
  options.rice.desktop.wayland.wlsunset = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    lat = lib.mkOption {
      type = lib.types.str;
    };

    lon = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf config.rice.desktop.wayland.wlsunset.enable {
    home-manager.sharedModules = [{
      services.wlsunset = {
        enable = true;
        latitude = config.rice.desktop.wayland.wlsunset.lat;
        longitude = config.rice.desktop.wayland.wlsunset.lon;
      };
    }];
  };
}
