{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;

  cfg = config.rice.dns;
in
{
  options.rice.dns = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    topology.self.services.dnscrypt-proxy = {
      name = "dnscrypt-proxy";
      icon = "services.dnscrypt-proxy";
      info = "Split DNS proxy";
    };

    aquaris.dnscrypt = {
      enable = true;

      protos = {
        dnscrypt = true;
        doh = false;
        odoh = true;
      };

      anonDNS = {
        enable = true;

        via = [
          "anon-cs-berlin"
          "anon-cs-berlin6"
          "anon-cs-de"
          "anon-cs-de6"
          "anon-cs-dus"
          "anon-cs-dus6"
          "anon-digitalprivacy.diy-ipv4"
          "odohrelay-crypto-sx"
        ];

        ign = [
          "cs-berlin"
          "cs-berlin6"
          "cs-de"
          "cs-de6"
          "cs-dus"
          "cs-dus6"
          "digitalprivacy.diy-dnscrypt-ipv4"
          "odoh-crypto-sx"
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
