{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.tailscaled = {
    cmd = [
      (lib.getExe' pkgs.tailscale "tailscaled")
      "-config=${config.rice.subsDomain ./config.json}"
      "-socket=/data/tailscaled.sock"
      "-state=/data/tailscaled.state"
      "-statedir=/data"
    ];

    extraOptions = [
      "--cap-add=net_admin,net_bind_service"
      "--device=/dev/net/tun"
    ];

    secrets = [ "@machine/tailscaled:/key" ];

    volumes = [ "tailscaled:/data" ];
  };
}
