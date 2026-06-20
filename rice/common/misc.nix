{ config, lib, ... }: {
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [ ];

  services.speechd.enable = false;

  systemd.services.systemd-machined.enable = config.virtualisation.libvirtd.enable;

  home-manager.sharedModules = [{
    xdg.configFile."go/telemetry/mode".text = "off 1970-01-01";
  }];
}
