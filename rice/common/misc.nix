{ lib, ... }: {
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [ ];

  services.speechd.enable = false;

  systemd.services.systemd-machined.enable = false;

  home-manager.sharedModules = [{
    xdg.configFile."go/telemetry/mode".text = "off 1970-01-01";
  }];
}
