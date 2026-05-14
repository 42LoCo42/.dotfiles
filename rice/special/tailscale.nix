{ pkgs, config, lib, ... }:
let
  inherit (lib)
    getExe'
    ifEnable
    join
    makeBinPath
    mkIf
    mkOption
    mkOverride
    pipe
    toJSON
    ;

  inherit (lib.types)
    bool
    str
    port
    ;

  cfg = config.rice.tailscale;

  tscfg = (pipe {
    version = "alpha0";

    serverURL = "https://headscale.eleonora.gay";
    authKey = "file:${config.aquaris.secret "@machine/tailscale"}";

    inherit (cfg) hostname locked;
    acceptDNS = true;

    advertiseRoutes = ifEnable cfg.isExit [
      "0.0.0.0/0"
      "::/0"
    ];
  }) [
    toJSON
    (pkgs.writeText "tailscaled.json")
  ];
in
{
  options.rice.tailscale = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    hostname = mkOption {
      type = str;
      default = config.networking.hostName;
    };

    port = mkOption {
      type = port;
      default = 41641;
    };

    isExit = mkOption {
      type = bool;
      default = false;
    };

    locked = mkOption {
      type = bool;
      default = false;
    };

    interface = mkOption {
      type = str;
      default = "tailscale";
    };

    ephemeral = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    topology.self.interfaces.${cfg.interface} = {
      type = "wireguard";
      virtual = true;
      network = "vpn";

      physicalConnections = [{
        node = "bunny-private";
        interface = "*";
      }];
    };

    aquaris.persist.dirs = mkIf (!cfg.ephemeral) {
      "/var/lib/tailscale" = { m = "0700"; };
    };

    environment.systemPackages = [ pkgs.tailscale ];

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = mkOverride 97 true;
      "net.ipv6.conf.all.forwarding" = mkOverride 97 true;
    };

    networking.firewall = {
      checkReversePath = "loose";
      allowedUDPPorts = [ cfg.port ];
    };

    services.networkd-dispatcher = mkIf cfg.isExit {
      enable = true;
      rules."tailscale" = {
        onState = [ "routable" ];
        script = (pipe (with pkgs; [
          ethtool
          iproute2
          jq
        ])) [
          makeBinPath
          (x: ''
            #!${pkgs.runtimeShell}
            set -euo pipefail
            PATH=${x}

            dev=$(ip --json route get 1.1.1.1 | jq -r '.[0].dev')
            ethtool -K "$dev"          \
              rx-udp-gro-forwarding on \
              rx-gro-list off
          '')
        ];
      };
    };

    systemd = {
      network = {
        networks."50-tailscale" = {
          matchConfig.Name = cfg.interface;
          linkConfig = {
            Unmanaged = true;
            ActivationPolicy = "manual";
          };
        };

        wait-online.ignoredInterfaces = [ cfg.interface ];
      };

      services = {
        NetworkManager-wait-online.enable = false;

        tailscaled = {
          wantedBy = [ "default.target" ];

          path = mkIf config.networking.resolvconf.enable (with pkgs; [
            openresolv
          ]);

          serviceConfig = {
            ExecStart = join " " [
              (getExe' pkgs.tailscale "tailscaled")
              "-config ${tscfg}"
              "-port   ${toString cfg.port}"
              "-socket /run/tailscale/tailscaled.sock"
              "-state  ${if cfg.ephemeral then "mem:" else "/var/lib/tailscale/tailscaled.state"}"
              "-tun    ${cfg.interface}"
            ];

            Restart = "on-failure";
            Type = "notify";

            RuntimeDirectory = "tailscale";
            StateDirectory = mkIf (!cfg.ephemeral) "tailscale";
            StateDirectoryMode = mkIf (!cfg.ephemeral) "0700";
          };
        };
      };
    };
  };
}
