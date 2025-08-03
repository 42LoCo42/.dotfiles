{ pkgs, lib, config, ... }: {
  # TODO openid-configuration should include 'code_challenge_methods_supported'
  # waiting for fix to reach a release...
  # https://github.com/pocket-id/pocket-id/commit/d479817b6a7ca4807b5de500b3ba713d436b0770
  rice.caddy.cfg.id = ''
    import default

    respond /.well-known/openid-configuration <<JSON
    ${builtins.readFile ./info.json}
    JSON 200

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
