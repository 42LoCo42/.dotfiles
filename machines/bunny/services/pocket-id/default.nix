{ pkgs, lib, config, ... }: {
  rice.caddy.cfg.id = ''
    import default
    reverse_proxy pocket-id:8080
  '';

  virtualisation.pnoc.pocket-id = {
    cmd = [ (lib.getExe pkgs.pocket-id) ];

    environment = {
      ANALYTICS_DISABLED = "true";
      APP_URL = "https://id.${config.rice.domain}";
      KEYS_STORAGE = "database";
      PORT = "8080";
      TRUST_PROXY = "true";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/pocket-id") ];

    volumes = [ "pocket-id:/data" ];
  };
}
