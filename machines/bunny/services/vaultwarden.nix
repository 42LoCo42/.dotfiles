{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.vaultwarden = {
    cmd = [ (lib.getExe pkgs.vaultwarden) ];
    environment = {
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = "8080";

      DOMAIN = "https://vw.${config.rice.domain}";
      SIGNUPS_ALLOWED = "false";

      SMTP_FROM = "vault@${config.rice.domain}";
      SMTP_HOST = "smtp.gmail.com";

      WEB_VAULT_FOLDER = "${pkgs.vaultwarden.webvault}/share/vaultwarden/vault";
    };
    environmentFiles = [ config.aquaris.secrets."machine/vaultwarden" ];
    ssl = true;
    volumes = [ "vaultwarden:/data" ];
  };
}
