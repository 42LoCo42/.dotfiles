{ pkgs, lib, config, ... }: {
  rice.caddy.cfg.vencloud = ''
    header ?Access-Control-Allow-Origin *
    redir https://vencloud.bunny{uri}
  '';

  virtualisation.pnoc.vencloud = {
    cmd = config.rice.redis ++ [ (lib.getExe pkgs.vencloud) ];

    environment = {
      HOST = "0.0.0.0";
      PORT = "8080";
      REDIS_URI = "localhost:6379";

      ROOT_REDIRECT = "https://github.com/Vencord/Vencloud";

      DISCORD_REDIRECT_URI = "https://vencloud.${config.rice.domain}/v1/oauth/callback";

      SIZE_LIMIT = "32000000";

      PROXY_HEADER = "X-Forwarded-For";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/vencloud") ];

    volumes = [ "vencloud:/data" ];
  };
}
