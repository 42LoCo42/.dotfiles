{ config, lib, ... }: {
  options.rice.tailscale.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.tailscale.enable {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "client";
    };

    systemd = {
      network.wait-online.ignoredInterfaces = [ "tailscale0" ];
      services.NetworkManager-wait-online.enable = false;
    };
  };
}
