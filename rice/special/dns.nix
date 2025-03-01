# TODO upstream this to Aquaris

{ config, pkgs, lib, ... }:
let
  inherit (lib) mkForce mkIf mkMerge mkOption;
  inherit (lib.types) bool path;

  cfg = config.rice.dns;
in
{
  options.rice.dns = {
    enable = mkOption {
      type = bool;
      description = "Enable the local dnscrypt-proxy";
      default = false;
    };

    local-doh = {
      enable = mkOption {
        type = bool;
        description = "Enable the local DoH server of dnscrypt-proxy";
        default = false;
      };

      crt = mkOption {
        type = path;
        description = "Path to the certificate used for the local DoH server";
      };

      key = mkOption {
        type = path;
        description = "Path to the private key used for the local DoH server";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      aquaris.persist.dirs."/var/cache/private/dnscrypt-proxy" = { };

      networking.networkmanager.dns = "none";

      services = {
        resolved.enable = false;

        dnscrypt-proxy2 = {
          enable = true;
          upstreamDefaults = true;
          settings = {
            listen_addresses = [ "127.0.0.1:53" "[::1]:53" ];

            query_log.file = "/dev/stdout";

            ipv4_servers = true;
            ipv6_servers = true;

            http3 = true;

            dnscrypt_servers = true;
            doh_servers = false;
            odoh_servers = false;

            require_dnssec = true;
            require_nolog = true;
            require_nofilter = true;

            cache = true;
            cache_size = 100000;

            bootstrap_resolvers = [ "9.9.9.9:53" ];

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

              ####################

              relays = {
                cache_file = "/var/cache/dnscrypt-proxy/relays.md";
                minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
                refresh_delay = 73;
                urls = [
                  "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
                  "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
                ];
              };
            };

            # these are used for AnonDNS relaying
            disabled_server_names = [
              "cs-berlin"
              "cs-de"
              "cs-dus3"
              "digitalprivacy.diy-dnscrypt-ipv4"
            ];

            anonymized_dns = {
              routes = [{
                server_name = "*";
                via = [
                  "anon-cs-berlin"
                  "anon-cs-de"
                  "anon-cs-dus3"
                  "anon-digitalprivacy.diy-ipv4"
                ];
              }];

              skip_incompatible = true;
            };

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
          };
        };
      };
    }

    (mkIf cfg.local-doh.enable {
      services.dnscrypt-proxy2.settings = {
        local_doh = {
          listen_addresses = [ "127.0.0.1:5353" "[::1]:5353" ];
          path = "/dns-query";

          cert_file = cfg.local-doh.crt;
          cert_key_file = "/run/credentials/dnscrypt-proxy2.service/key";
        };
      };

      systemd.services.dnscrypt-proxy2 = {
        serviceConfig.LoadCredential = "key:${cfg.local-doh.key}";
      };

      # make this part of aquaris:module/home/firefox
      home-manager.sharedModules = [{
        aquaris.firefox.policies = {
          Certificates.Install = [ cfg.local-doh.crt ];

          DNSOverHTTPS = mkForce {
            Enabled = true;
            Locked = true;

            ProviderURL = "https://localhost:5353/dns-query";
            Fallback = false;
          };
        };
      }];
    })
  ]);
}
