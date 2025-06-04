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
          # support multiple subdomains for VPN services
          "bunny" = "bunny.bunny.vpn";
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
