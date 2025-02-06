{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.tailscaled = {
    cmd = [
      config.rice.invfork.outPath

      # parent process: tailscaled in declarative mode
      (lib.getExe' pkgs.tailscale "tailscaled")
      "-config=${config.rice.subsDomain ./config.json}"
      "-socket=/data/tailscaled.sock"
      "-state=/data/tailscaled.state"
      "-statedir=/data"

      "--" # child process: SSH forwarder
      "${lib.getExe pkgs.socat}"
      "TCP-LISTEN:22,fork,reuseaddr"
      "TCP-CONNECT:host.containers.internal:18213"
    ];

    extraOptions = [
      "--cap-add=net_admin,net_bind_service"
      "--device=/dev/net/tun"
    ];

    secrets = [ "machine/tailscaled:/key" ];

    volumes = [ "tailscaled:/data" ];
  };
}
