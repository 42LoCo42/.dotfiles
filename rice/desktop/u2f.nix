{ lib, config, ... }: lib.mkIf config.rice.desktop {
  security.pam = {
    services.sudo.u2fAuth = true;
    u2f.settings.cue = true;
  };

  home-manager.sharedModules = [{
    aquaris.persist = [ ".config/Yubico" ];
  }];
}
