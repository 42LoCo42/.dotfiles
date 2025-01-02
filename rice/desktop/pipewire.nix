{ lib, config, ... }: {
  options.rice.desktop.pipewire.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.pipewire.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;

      extraConfig.pipewire = {
        "10-clock-rate" = {
          "context.properties" = {
            "default.clock.max-quantum" = 1024;
            "default.clock.min-quantum" = 1024;
            "default.clock.quantum" = 1024;
          };
        };
      };
    };

    home-manager.sharedModules = [{
      aquaris.persist = [ ".local/state/wireplumber" ];
    }];
  };
}
