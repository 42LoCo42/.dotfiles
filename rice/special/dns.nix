{ config, pkgs, lib, ... }: {
  options.rice.dns.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.dns.enable {
    aquaris.persist.dirs."/var/cache/private/dnscrypt-proxy" = { };

    networking.networkmanager.dns = "none";

    services = {
      resolved.enable = false;

      dnscrypt-proxy2 = {
        enable = true;
        upstreamDefaults = false;
        settings = {
          listen_addresses = [ "127.0.0.1:53" ];

          query_log = {
            file = "/dev/stdout";
            format = "ltsv";
          };

          ipv4_servers = true;
          ipv6_servers = true;

          dnscrypt_servers = true;
          doh_servers = true;
          odoh_servers = true;

          require_dnssec = true;
          require_nolog = true;
          require_nofilter = true;

          http3 = true;

          lb_strategy = "p2";
          lb_estimator = true;

          bootstrap_resolvers = [ "9.9.9.9:53" ];

          block_unqualified = true;
          block_undelegated = true;

          cache = true;
          cache_size = 10000;

          forwarding_rules = pkgs.writeText "forwarding-rules.txt" ''
            bunny.vpn    100.100.100.100
            fritz.box    192.168.178.1
            vm           192.168.122.1
          '';

          cloaking_rules = pkgs.writeText "cloaking-rules.txt" ''
            local.host      127.0.0.1
            readers.lakd    127.0.0.1
          '';

          blocked_ips.blocked_ips_file = pkgs.writeText "blocked-ips.txt" ''
            # Localhost rebinding protection
            0.0.0.0
            127.0.0.*

            # RFC1918 rebinding protection
            10.*
            172.16.*
            172.17.*
            172.18.*
            172.19.*
            172.20.*
            172.21.*
            172.22.*
            172.23.*
            172.24.*
            172.25.*
            172.26.*
            172.27.*
            172.28.*
            172.29.*
            172.30.*
            172.31.*
            192.168.*
          '';

          sources = {
            public-resolvers = {
              cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              refresh_delay = 73;
              urls = [
                "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
                "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
              ];
            };

            relays = {
              cache_file = "/var/cache/dnscrypt-proxy/relays.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              refresh_delay = 73;
              urls = [
                "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
                "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
              ];
            };

            odoh-servers = {
              cache_file = "/var/cache/dnscrypt-proxy/odoh-servers.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              refresh_delay = 73;
              urls = [
                "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-servers.md"
                "https://download.dnscrypt.info/resolvers-list/v3/odoh-servers.md"
              ];
            };

            odoh-relays = {
              cache_file = "/var/cache/dnscrypt-proxy/odoh-relays.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              refresh_delay = 73;
              urls = [
                "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-relays.md"
                "https://download.dnscrypt.info/resolvers-list/v3/odoh-relays.md"
              ];
            };

            quad9-resolvers = {
              cache_file = "/var/cache/dnscrypt-proxy/quad9-resolvers.md";
              minisign_key = "RWQBphd2+f6eiAqBsvDZEBXBGHQBJfeG6G+wJPPKxCZMoEQYpmoysKUN";
              prefix = "quad9-";
              urls = [ "https://www.quad9.net/quad9-resolvers.md" ];
            };

            dnscry-pt-resolvers = {
              cache_file = "/var/cache/dnscrypt-proxy/dnscry.pt-resolvers.md";
              minisign_key = "RWQM31Nwkqh01x88SvrBL8djp1NH56Rb4mKLHz16K7qsXgEomnDv6ziQ";
              prefix = "dnscry.pt-";
              refresh_delay = 73;
              urls = [ "https://www.dnscry.pt/resolvers.md" ];
            };
          };

          broken_implementations.fragments_blocked = [
            "cisco"
            "cisco-ipv6"
            "cisco-familyshield"
            "cisco-familyshield-ipv6"
            "cisco-sandbox"
            "cleanbrowsing-adult"
            "cleanbrowsing-adult-ipv6"
            "cleanbrowsing-family"
            "cleanbrowsing-family-ipv6"
            "cleanbrowsing-security"
            "cleanbrowsing-security-ipv6"
          ];

          # TODO is this a good idea?
          anonymized_dns = {
            routes = [{
              server_name = "*";
              via = [ "*" ];
            }];

            skip_incompatible = true;
          };
        };
      };
    };
  };
}
