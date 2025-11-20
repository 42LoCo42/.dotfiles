{ pkgs, lib, config, ... }: {
  topology.nodes.bunny-public.services.pocket-id = {
    name = "Pocket ID";
    icon = "services.pocket-id";
    info = "OIDC provider for other services";
    details.url.text = "https://id.${config.rice.domain}";
  };

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

      UI_CONFIG_DISABLED = "true";
      EMAILS_VERIFIED = "true";
      EMAIL_LOGIN_NOTIFICATION_ENABLED = "true";
      EMAIL_ONE_TIME_ACCESS_AS_ADMIN_ENABLED = "true";
      EMAIL_API_KEY_EXPIRATION_ENABLED = "true";
      SMTP_HOST = "msmtpd";
      SMTP_PORT = "2525";
      SMTP_FROM = "pocket-id@${config.rice.domain}";
      SMTP_USER = "user";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/pocket-id") ];

    volumes = [ "pocket-id:/data" ];
  };
}
