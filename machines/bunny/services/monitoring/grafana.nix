{ config, lib, pkgs, ... }:
let
  inherit (lib) pipe;

  mkIni = (pkgs.formats.ini { }).generate;

  plugins = with pkgs.grafanaPlugins; [
    prometheus
  ];

  url = "https://grafana.bunny";

  cfg = mkIni "grafana.ini" {
    paths = {
      plugins = pipe plugins [
        (map (x: { name = x.pname; path = x; }))
        (pkgs.linkFarm "grafana-plugins")
      ];
    };

    plugins = {
      preinstall_disabled = true;
    };

    server = {
      http_addr = "0.0.0.0";
      http_port = 8080;
      root_url = url;
      static_root_path = "${pkgs.grafana}/share/grafana/public";
    };

    database = {
      type = "postgres";
      host = "postgres";
      user = "grafana";
    };

    auth = {
      disable_login_form = true; # we use OIDC
    };

    news = {
      news_feed_enabled = false;
    };

    analytics = {
      reporting_enabled = false;
      check_for_updates = false;
      check_for_plugin_updates = false;
      feedback_links_enabled = false;
    };
  };
in
{
  topology.nodes.bunny-private.services.grafana = {
    name = "Grafana";
    icon = "services.grafana";
    info = "Central monitoring dashboard";
    details.url.text = url;
  };

  virtualisation.pnoc.grafana = {
    path = with pkgs; [ coreutils grafana ];

    script = ''
      ln -sfT ${pkgs.grafana}/share/grafana/conf /tmp/conf

      exec grafana server \
        --config ${cfg}   \
        --homepath /tmp
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/grafana") ];
  };
}
