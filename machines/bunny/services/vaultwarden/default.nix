{ pkgs, lib, config, ... }: {
  topology.nodes.bunny-public.services.vaultwarden = {
    name = "Vaultwarden";
    icon = "services.vaultwarden";
    info = "Selfhosted password manager";
    details.url.text = "https://vw.${config.rice.domain}";
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

  virtualisation.pnoc.vaultwarden =
    let vw = pkgs.vaultwarden-postgresql; in {
      cmd = [ (lib.getExe vw) ];

      environment = {
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = "8080";

        DOMAIN = "https://vw.${config.rice.domain}";
        SIGNUPS_ALLOWED = "false";

        SMTP_HOST = "msmtpd";
        SMTP_PORT = "2525";
        SMTP_SECURITY = "off";
        SMTP_FROM = "vaultwarden@${config.rice.domain}";
        SMTP_USERNAME = "user";

        WEB_VAULT_FOLDER = "${vw.webvault}/share/vaultwarden/vault";

        SSO_ENABLED = "true";
        SSO_ONLY = "false";
        SSO_SIGNUPS_MATCH_EMAIL = "true";
        SSO_AUTHORITY = "https://id.${config.rice.domain}";
        SSO_PKCE = "true";
      };

      environmentFiles = [ (config.aquaris.secret "@machine/vaultwarden") ];

      volumes = [ "vaultwarden:/data" ];
    };
}
