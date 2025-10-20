{ pkgs, config, ... }: {
  # protect these from garbage collection
  system.extraDependencies = with pkgs; [
    elk-to-svg
    html-to-svg
  ];

  rice.caddy = {
    cfg = {
      "" = ''
        import default

        ##### homepage #####
        root * /srv/homepage
        file_server

        ##### funny cat :3 #####
        handle_errors {
          rewrite * /{err.status_code}
          reverse_proxy https://http.cat {
            header_up Host {upstream_hostport}
            replace_status {err.status_code}
          }
        }
      '';

      www = ''
        redir https://{$DOMAIN}
      '';
    };

    volumes = [
      "${config.rice.homepage}:/srv/homepage" # can't be ro due to hidden/foo subdir
      "${config.system.build.topology}/main.svg:/srv/homepage/topology.svg:ro"
      "/persist/home/admin/hidden:/srv/homepage/foo:ro"
    ];
  };
}
