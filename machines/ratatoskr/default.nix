{ lib, config, aquaris, ... }:
let
  inherit (aquaris.lib) merge subsT;
  inherit (lib) mkForce;

  wanIF = "TODO wan";
  lanIF = "TODO lan";
  lanIP = "10.0.0.1";
in
{
  imports = [ ../../rice ];

  aquaris = {
    machine = {
      id = "5965b9540d6ce5bb06e850ad671c840a";
      key = "age1592y83f2sd2n4y5cxq7zd68mwtx70kyrfq435ue6re3mnpwve30qn7e5xr";
    };

    users = merge [
      { inherit (aquaris.cfg.users) admin; }
      { admin.admin = true; }
    ];

    filesystems = { fs, ... }: {
      disks."/dev/disk/by-id/TODO".partitions = [
        fs.defaultBoot
        { content = fs.zpool (p: p.rpool); }
      ];

      zpools.rpool = fs.defaultPool;
    };

    persist = {
      enable = true;
      dirs = [
        "/var/lib/dnsmasq"
        # TODO hostapd?
      ];
    };
  };

  rice = {
    dns = true;
    dnsmasq-interface = lanIF;
  };

  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

  networking = {
    firewall.enable = false; # we use nftables
    networkmanager.enable = mkForce false;

    interfaces = {
      ${wanIF}.useDHCP = true;
      ${lanIF} = {
        useDHCP = false;
        ipv4.addresses = [{
          address = lanIP;
          prefixLength = 24;
        }];
      };
    };

    nftables = {
      enable = true;
      ruleset = subsT ./firewall.nft {
        wan = wanIF;
        lan = lanIF;
      };
    };
  };

  systemd.network.wait-online.enable = mkForce true;
  systemd.services.dnsmasq.after = [ "network-online.target" ];

  services = {
    ##### WLAN #####

    hostapd = {
      enable = true;
      radios.${lanIF} = {
        networks.${lanIF} = {
          ssid = "Ratatoskr";
          authentication.saePasswordsFile =
            config.aquaris.secrets."machine/sae-password".outPath;
        };
      };
    };

    ##### DNS/DHCP #####

    dnsmasq.settings = {
      listen-address = [ lanIP ];

      # misc
      no-resolv = true; # TODO maybe conflicts with tailscale?

      # local domain
      local = mkForce "/lan/";
      domain = "lan";

      # DHCP
      dhcp-range = "10.0.0.2,10.0.0.254,12h";
      dhcp-option = [
        "option:router,${lanIP}"
        "option:dns-server,${lanIP}"
      ];
    };


    ##### Tailscale #####

    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
  };
}
