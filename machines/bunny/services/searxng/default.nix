{ pkgs, lib, config, ... }: {
  rice.caddy.cfg.searx = ''
    import default
    reverse_proxy searxng:8080 {
      header_up X-Forwarded-Port {http.request.port}
      header_up X-Real-IP {remote_host}
    }
  '';

  virtualisation.pnoc.searxng = {
    cmd = [
      (lib.getExe' pkgs.runit "runsvdir")
      (config.rice.mkRunit {
        anubis = ''
          exec anubis                      \
            --bind :8080                   \
            --og-passthrough               \
            --serve-robots-txt             \
            --target http://localhost:8081 \
            --redirect-domains searx.${config.rice.domain}
        '';

        searxng = ''
          exec gunicorn         \
            --bind 0.0.0.0:8081 \
            --threads 4         \
            --workers 4         \
            searx.webapp:app
        '';
      }).outPath
    ];

    environment = {
      PATH = lib.makeBinPath (with pkgs; with python3.pkgs; [
        anubis
        gunicorn
        runit
      ]);

      PYTHONPATH = pkgs.searxng.pythonModule.pkgs.makePythonPath
        (with pkgs; [ searxng ]);

      SEARXNG_BASE_URL = "https://searx.${config.rice.domain}";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/searxng") ];

    volumes = [
      "${./settings.yaml}:/etc/searxng/settings.yml:ro"
    ];
  };
}
