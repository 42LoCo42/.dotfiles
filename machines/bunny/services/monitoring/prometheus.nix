{ config, lib, pkgs, ... }:
let
  inherit (lib) mapAttrsToList mkOption pipe;
  inherit (lib.types) attrsOf str;

  cfg = pipe config.rice.metrics [
    (mapAttrsToList (name: url: {
      job_name = name;
      static_configs = [{ targets = [ url ]; }];
    }))
    (x: {
      global.scrape_interval = "15s";
      scrape_configs = x;
    })
    (pkgs.writers.writeYAML "prometheus.yaml")
  ];
in
{
  options.rice.metrics = mkOption {
    type = attrsOf str;
    default = { };
  };

  config = {
    topology.nodes.bunny-private.services.prometheus = {
      name = "Prometheus";
      icon = "services.prometheus";
      info = "Metrics aggregator for Grafana";
      details.url.text = "https://prometheus.bunny";
    };

    rice.metrics."prometheus" = "prometheus:9090";

    virtualisation.pnoc.prometheus = {
      path = with pkgs; [ prometheus ];

      script = ''
        exec prometheus             \
          --config.file ${cfg}      \
          --no-config.auto-reload   \
          --storage.tsdb.path /data \
      '';

      volumes = [ "prometheus:/data" ];
    };
  };
}
