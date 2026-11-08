{ pkgs, ... }: {
  rice.metrics."speedtest" = {
    url = "prometheus-speedtest-exporter:9090";
    extra = {
      scrape_interval = "60m";
      scrape_timeout = "60s";
    };
  };

  virtualisation.pnoc.prometheus-speedtest-exporter = {
    path = with pkgs; [ prometheus-speedtest-exporter ];

    script = ''
      exec speedtest_exporter
    '';
  };
}
