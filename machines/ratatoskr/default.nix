{ pkgs, lib, config, aquaris, ... }:
let
  inherit (aquaris.lib) merge;
  inherit (lib) mkForce;

  wanIF = "TODO wan";
  lanIF = "TODO lan";
  lanIP = "10.0.0.1";
  ssid = "Ratatoskr";
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

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "qr";
      runtimeInputs = with pkgs; [ openssl qrtool ];
      text =
        let
          src = config.aquaris.secrets."machine/sae-password";
          fmt = ''WIFI:T:WPA;R:3;S:${ssid};P:'"$passwd"';K:\1;;'';
        in
        ''
          src="''${1-${src}}"

          passwd="$(grep -oP '^[^|#]+' "$src")"
          seckey="$(grep -oP 'pk=[^:]+:\K[^|]+' "$src")"

          <<< "$seckey"             \
          base64 -d                 \
          | openssl ec              \
            -inform der             \
            -pubout                 \
            -conv_form compressed   \
            -outform der            \
          | base64 -w0              \
          | sed -E 's|(.*)|${fmt}|' \
          | qrtool encode -t unicode
        '';
    })
  ];


  networking = {
    useDHCP = false;
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

    nftables.enable = true;

    firewall = {
      allowPing = false;
      filterForward = true;
      trustedInterfaces = [ lanIF ];

      extraInputRules = ''
        iifname "${wanIF}" ip saddr \
        { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } \
        drop comment "Block fake locals"
      '';
    };

    nat = {
      enable = true;

      externalInterface = wanIF;
      internalInterfaces = [ lanIF ];

      forwardPorts = [
        { sourcePort = 37812; destination = "10.0.0.2:12345"; proto = "tcp"; }
      ];
    };
  };

  systemd.network.wait-online.enable = mkForce false;

  services = {
    ##### WLAN #####

    hostapd = {
      enable = true;
      radios.${lanIF} = {
        channel = 6;
        networks.${lanIF} = {
          inherit ssid;
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
