{ pkgs, lib, config, ... }: {
  rice.caddy.cfg.searx = ''
    import default
    reverse_proxy searxng:8080 {
      header_up X-Forwarded-Port {http.request.port}
      header_up X-Real-IP {remote_host}
    }
  '';

  virtualisation.pnoc.searxng = {
    cmd = config.rice.redis ++ [
      (lib.getExe pkgs.python3.pkgs.gunicorn)
      "--bind=0.0.0.0:8080"
      "--threads=4"
      "--workers=4"
      "searx.webapp:app"
    ];

    environment = {
      PYTHONPATH = pkgs.searxng.pythonModule.pkgs.makePythonPath [ pkgs.searxng ];
      SEARXNG_BASE_URL = "https://searx.${config.rice.domain}";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/searxng") ];

    volumes = [
      "searxng:/data"

      "${./limiter.toml}:/etc/searxng/limiter.toml:ro"
      "${./settings.yaml}:/etc/searxng/settings.yml:ro"
    ];
  };
}
