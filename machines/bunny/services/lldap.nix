{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.lldap = {
    cmd = [ (lib.getExe pkgs.lldap) "run" ];
    environment = {
      LLDAP_LDAP_BASE_DN = config.rice.dn;

      LLDAP_HTTP_PORT = "8080";
      LLDAP_HTTP_URL = "https://ldap.${config.rice.domain}";

      LLDAP_SMTP_OPTIONS__ENABLE_PASSWORD_RESET = "true";
      LLDAP_SMTP_OPTIONS__SERVER = "email-oauth2-proxy";
      LLDAP_SMTP_OPTIONS__PORT = "2465";
      LLDAP_SMTP_OPTIONS__USER = "11213kbm@gmail.com";
      LLDAP_SMTP_OPTIONS__PASSWORD = "ignored";
    };
    environmentFiles = [ (config.aquaris.secret "@machine/lldap") ];
  };
}
