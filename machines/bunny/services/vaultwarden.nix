{ pkgs, lib, config, ... }: {
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
      SMTP_PASSWORD = "ignored";
      SMTP_FROM = "vaultwarden@${config.rice.domain}";

      WEB_VAULT_FOLDER = "${pkgs.vaultwarden.webvault}/share/vaultwarden/vault";
    };
    environmentFiles = [ (config.aquaris.secret "@machine/vaultwarden") ];
    volumes = [ "vaultwarden:/data" ];
  };
}
