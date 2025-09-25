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

    ui = mkOption {
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

    services.dnscrypt-proxy.settings = mkIf cfg.ui {
      monitoring_ui = {
        enabled = true;
        listen_address = "127.0.0.1:53080";
        username = "";
        password = "";
        privacy_level = 0;
      };
    };
  };
}
