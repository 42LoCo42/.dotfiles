{ pkgs, lib, config, ... }: {
  topology.nodes.bunny-public.services.vaultwarden = {
    name = "Vaultwarden";
    icon = "services.vaultwarden";
    info = "Selfhosted password manager";
    details.url.text = "https://vw.eleonora.gay";
  };

  rice.caddy.cfg.vw = ''
    import default

    @notblacklisted {
      not {
        path /admin*
      }
    }

    reverse_proxy @notblacklisted vaultwarden:8080 {
      header_up X-Real-IP {remote_host}
    }
  '';

  virtualisation.pnoc.vaultwarden = {
    cmd = [ (lib.getExe pkgs.vaultwarden) ];

    environment = {
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = "8080";

      DOMAIN = "https://vw.${config.rice.domain}";
      SIGNUPS_ALLOWED = "false";

      SMTP_HOST = "email-oauth2-proxy";
      SMTP_PORT = "2465";
      SMTP_SECURITY = "off";
      SMTP_USERNAME = "11213kbm@gmail.com";
      SMTP_PASSWORD = "empty";
      SMTP_FROM = "vaultwarden@${config.rice.domain}";

      WEB_VAULT_FOLDER = "${pkgs.vaultwarden.webvault}/share/vaultwarden/vault";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/vaultwarden") ];

    volumes = [ "vaultwarden:/data" ];
  };
}
