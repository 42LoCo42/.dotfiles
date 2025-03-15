{ lib, config, ... }: {
  options.rice.dns.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.dns.enable {
    aquaris.dnscrypt = {
      enable = true;

      anonDNS = {
        enable = true;

        via = [
          "anon-cs-berlin"
          "anon-cs-de"
          "anon-cs-dus3"
          "anon-digitalprivacy.diy-ipv4"
        ];

        ign = [
          "cs-berlin"
          "cs-de"
          "cs-dus3"
          "digitalprivacy.diy-dnscrypt-ipv4"
        ];
      };

      rules = {
        cloaking = {
          "readers.lakd" = "127.0.0.1";

          # support multiple subdomains on laniakea
          "laniakea" = "laniakea.bunny.vpn";
        };

        forwarding = {
          "bunny.vpn" = "100.100.100.100";
          "vm" = "192.168.122.1";
        };
      };
    };
  };
}
