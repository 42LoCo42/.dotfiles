{ config, lib, ... }: {
  options.rice.tailscale.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.tailscale.enable {
    topology.self.interfaces."tailscale0" = {
      type = "wireguard";
      virtual = true;
      network = "vpn";

      physicalConnections = [{
        node = "bunny-private";
        interface = "*";
      }];
    };

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
