{ config, ... }: {
  services.duckdns = {
    enable = true;
    tokenFile = config.aquaris.secret "@machine/duckdns";
    domains = [ "16bytes" ];
  };
}
