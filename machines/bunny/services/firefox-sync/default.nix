{ config, pkgs, ... }:
let url = "https://firefox-sync.bunny"; in {
  topology.nodes.bunny-private.services.firefox-sync = {
    name = "Firefox Sync";
    icon = "services.firefox-syncserver";
    info = "Firefox profile synchronisation";
    details.url.text = url;
  };

  virtualisation.pnoc.firefox-sync = {
    path = with pkgs; [ syncstorage-rs ];

    script = ''
      declare DB
      export SYNC_TOKENSERVER__DATABASE_URL="$DB"
      export SYNC_SYNCSTORAGE__DATABASE_URL="$DB"

      exec syncserver
    '';

    environment = {
      RUST_LOG = "debug";

      SYNC_HOST = "0.0.0.0";
      SYNC_PORT = "8080";

      SYNC_TOKENSERVER__ENABLED = "true";
      SYNC_TOKENSERVER__RUN_MIGRATIONS = "true";
      SYNC_TOKENSERVER__FXA_EMAIL_DOMAIN = "api.accounts.firefox.com";
      SYNC_TOKENSERVER__FXA_OAUTH_SERVER_URL = "https://oauth.accounts.firefox.com";
      SYNC_TOKENSERVER__INIT_NODE_URL = url;
    };

    environmentFiles = [ (config.aquaris.secret "@machine/firefox-sync") ];
  };
}
