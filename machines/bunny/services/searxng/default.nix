{ pkgs, config, ... }: {
  topology.nodes.bunny-public.services.searxng = {
    name = "SearXNG";
    icon = "services.searxng";
    info = "Privacy-respecting metasearch engine";
    details.url.text = "https://searx.${config.rice.domain}";
  };

  rice.caddy.cfg.searx = ''
    import default
    reverse_proxy searxng:8080 {
      header_up X-Forwarded-Port {http.request.port}
      header_up X-Real-IP {remote_host}
    }
  '';

  virtualisation.pnoc.searxng = {
    path = with pkgs; [
      python3.pkgs.gunicorn
    ];

    script = ''
      ${config.rice.anubis}

      exec gunicorn         \
        --bind 0.0.0.0:8081 \
        --threads 4         \
        --workers 4         \
        searx.webapp:app
    '';

    environment = {
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
