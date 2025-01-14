{ lib, config, ... }: {
  virtualisation.pnoc.vencloud = {
    cmd = [ (lib.getExe config.rice.obscura.vencloud) ];
    environment = {
      HOST = "0.0.0.0";
      PORT = "8080";
      REDIS_URI = "redis:6379";

      ROOT_REDIRECT = "https://github.com/Vencord/Vencloud";

      DISCORD_REDIRECT_URI = "https://vencloud.${config.rice.domain}/v1/oauth/callback";

      SIZE_LIMIT = "32000000";

      PROXY_HEADER = "X-Forwarded-For";
    };
    environmentFiles = [ config.aquaris.secrets."machine/vencloud" ];
    ssl = true;
  };
}
