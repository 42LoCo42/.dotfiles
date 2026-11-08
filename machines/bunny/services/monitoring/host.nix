{ config, lib, pkgs, ... }:
let
  inherit (lib) mapAttrs;

  helpers = "${config.virtualisation.podman.package}/libexec/podman";

  ports = {
    node = 9001;
    podman = 9002;
    systemd = 9003;
    zfs = 9004;
  };
in
{
  rice.metrics = mapAttrs
    (_: x: "host.containers.internal:${toString x}")
    ports;

  virtualisation.containers.containersConf.settings = {
    engine.helper_binaries_dir = [ helpers ];
  };

  systemd.services = {
    prometheus-podman-exporter = {
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ prometheus-podman-exporter ];

      script = ''
        exec env PATH=$PATH:${helpers}  \
          prometheus-podman-exporter    \
            --collector.enable-all      \
            --web.listen-address :${toString ports.podman}
      '';
    };
  };

  services.prometheus.exporters = {
    node = {
      enable = true;
      port = ports.node;
      enabledCollectors = [ "systemd" "processes" ];
    };

    systemd = {
      enable = true;
      port = ports.systemd;
    };

    zfs = {
      enable = true;
      port = ports.zfs;
    };
  };
}
