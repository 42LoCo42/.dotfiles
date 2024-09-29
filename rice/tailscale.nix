{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
mkIf config.rice.tailscale {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
  };
}
