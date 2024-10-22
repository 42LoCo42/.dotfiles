{ lib, config, ... }: lib.mkIf config.rice.desktop {
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  home-manager.sharedModules = [{
    aquaris.persist = [ ".local/state/wireplumber" ];
  }];
}
