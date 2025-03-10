{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.lldap = {
    cmd = [ (lib.getExe pkgs.lldap) "run" ];
    environment = {
      LLDAP_LDAP_BASE_DN = config.rice.dn;

      LLDAP_HTTP_PORT = "8080";
      LLDAP_HTTP_URL = "https://ldap.${config.rice.domain}";

      LLDAP_SMTP_OPTIONS__ENABLE_PASSWORD_RESET = "true";
      LLDAP_SMTP_OPTIONS__FROM = "ldap@${config.rice.domain}";
      LLDAP_SMTP_OPTIONS__SERVER = "smtp.gmail.com";
      LLDAP_SMTP_OPTIONS__PORT = "587";
      LLDAP_SMTP_OPTIONS__SMTP_ENCRYPTION = "STARTTLS";
    };
    environmentFiles = [ (config.aquaris.secret "@machine/lldap") ];
  };
}
