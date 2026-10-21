{ config, ... }: {
  services.duckdns = {
    enable = true;
    tokenFile = config.aquaris.secret "@machine/duckdns";
    domains = [ "16bytes" ];
  };

  systemd.services.duckdns = {
    after = [ "secrets-access-extra.service" ];
    wants = [ "secrets-access-extra.service" ];
  };
}
