{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.searxng = {
    cmd = config.rice.redis ++ [ (lib.getExe' pkgs.searxng "searxng-run") ];

    environment = {
      SEARXNG_BIND_ADDRESS = "0.0.0.0";
      SEARXNG_URL = "https://searx.${config.rice.domain}";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/searxng") ];

    extraOptions = [ "--tmpfs=/tmp" ];

    volumes = [
      "searxng:/data"

      "${./limiter.toml}:/etc/searxng/limiter.toml:ro"
      "${./settings.yaml}:/etc/searxng/settings.yml:ro"
    ];
  };
}
