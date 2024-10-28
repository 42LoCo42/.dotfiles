{ config, lib, ... }: lib.mkIf config.rice.tailscale {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
  };

  systemd = {
    network.wait-online.ignoredInterfaces = [ "tailscale0" ];
    services.NetworkManager-wait-online.enable = false;
  };
}
