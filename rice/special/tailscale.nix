{ config, lib, ... }: lib.mkIf config.rice.tailscale {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
  };
}
