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
      (lib.getExe pkgs.granian)
      "--interface=wsgi"
      "--workers=4"
      "--host=0.0.0.0"
      "--port=8080"
      "searx.webapp:app"
    ];

    environment = {
      PYTHONPATH = pkgs.searxng.pythonModule.pkgs.makePythonPath [ pkgs.searxng ];
      SEARXNG_URL = "https://searx.${config.rice.domain}";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/searxng") ];

    volumes = [
      "searxng:/data"

      "${./limiter.toml}:/etc/searxng/limiter.toml:ro"
      "${./settings.yaml}:/etc/searxng/settings.yml:ro"
    ];
  };
}
