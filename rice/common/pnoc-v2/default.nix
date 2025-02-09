{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib)
    concatLines
    defaultTo
    elemAt
    flip
    getExe
    getExe'
    hasPrefix
    mapAttrs'
    mapAttrsToList
    mapNullable
    mkBefore
    mkForce
    mkIf
    mkMerge
    mkOption
    pipe
    splitString
    toInt
    ;

  inherit (lib.types)
    attrsOf
    bool
    coercedTo
    either
    enum
    lines
    listOf
    nullOr
    package
    path
    port
    str
    submodule
    ;

  inherit (config.aquaris) secret;

  cfg = config.virtualisation.pnoc-v2;

  resolvconf = pkgs.writeText "resolv.conf" ''
    nameserver 10.42.0.1
    nameserver fd42::1
  '';

  pnoc-dns = pkgs.writeText "pnoc-dns.conf" ''
    keep-in-foreground
    user=dnsmasq

    interface=pnoc0
    except-interface=lo
    bind-dynamic

    log-queries

    hostsdir=/run/pnoc/hosts
  '';

  ipadd = aquaris.lib.subsF {
    file = ./ipadd.py;
    func = _: pkgs.writeScriptBin "ipadd";
    subs.python = getExe pkgs.python3;
  };

  pnoc-pre-launch = pkgs.writeShellApplication {
    name = "pnoc-pre-launch";
    text = builtins.readFile ./pre-launch.sh;
    runtimeInputs = with pkgs; [
      ipadd
      iproute2
      nftables
    ];
  };

  pnoc-post-launch = pkgs.writeShellApplication {
    name = "pnoc-post-launch";
    text = builtins.readFile ./post-launch.sh;
  };

  pnoc-clean = pkgs.writeShellApplication {
    name = "pnoc-clean";
    text = builtins.readFile ./clean.sh;
    bashOptions = [ ]; # clean is best-effort; allow failing commands
    runtimeInputs = with pkgs; [
      iproute2
      nftables
    ];
  };

  mkService = name: cfg: mkMerge [
    (mkIf cfg.autostart {
      wantedBy = [ "multi-user.target" ];
    })

    (mkIf (cfg.datadir != null) {
      # created by pre-launch & chowned by post-launch
      serviceConfig.BindPaths = "/var/lib/pnoc/${name}:${cfg.datadir}";
    })

    (mkIf (cfg.secrets != [ ]) {
      serviceConfig = {
        # %d is credential directory
        LoadCredential = map (x: "${x.name}:${x.host}") cfg.secrets;
        BindReadOnlyPaths = map (x: "%d/${x.name}:${x.cont}") cfg.secrets;
      };
    })

    {
      after = [ "pnoc_dns.service" "pnoc_pre_launch@${name}.service" ];
      requires = [ "pnoc_dns.service" "pnoc_pre_launch@${name}.service" ];

      # always trigger cleanup
      onSuccess = [ "pnoc_clean@${name}.service" ];
      onFailure = [ "pnoc_clean@${name}.service" ];

      # post-launch requires us to be up in order to read our UID/GID
      # but we also need it to succeed in order to have a working /etc
      before = [ "pnoc_post_launch@${name}.service" ];
      bindsTo = [ "pnoc_post_launch@${name}.service" ];

      confinement = {
        enable = true;
        binSh = null;

        # add everything from environment in order to support things like
        # FOO_CONFIG="${./config.json}"
        packages = [
          (builtins.toJSON
            config.systemd.services."pnoc-${name}".environment)
        ];
      };

      inherit (cfg) environment script;
      path = mkForce cfg.path;

      serviceConfig = {
        Type = "simple";

        EnvironmentFile = cfg.environmentFiles;

        BindReadOnlyPaths = [
          "/etc/localtime"
          "/etc/os-release"
          "${resolvconf}:/etc/resolv.conf"
        ];

        DynamicUser = true;

        # (re)created & chmodded by pre-launch
        # removed by clean
        RootDirectory = mkForce "/run/pnoc/rootd/${name}";
        RuntimeDirectory = mkForce [ "pnoc/runtd/${name}" ];

        # created by pre-launch
        PrivateNetwork = true;
        NetworkNamespacePath = "/run/pnoc/netns/${name}";

        ProtectProc = "invisible";
        ProcSubset = "pid";

        # TODO figure out things like /dev/net/tun
        # and CAP_NET_ADMIN, CAP_NET_BIND_SERVICE
        # (e.g. for tailscale)

        CapabilityBoundingSet = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivatePIDs = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        UMask = "0077";

        SystemCallFilter = [
          "~@clock"
          "~@cpu-emulation"
          "~@debug"
          "~@module"
          "~@mount"
          "~@obsolete"
          "~@raw-io"
          "~@reboot"
          "~@resources"
          "~@swap"
        ];
      };
    }
  ];
in
{
  options.virtualisation.pnoc-v2 = {
    enable = mkOption {
      description = "Enables Pure NixOS Containers™ v2 technology";
      type = bool;
      default = false;
    };

    containers = mkOption {
      type = attrsOf (submodule ({ config, ... }: {
        options = {
          script = mkOption {
            description = "The script that will be executed inside this container";
            type = lines;
          };

          ##########

          autostart = mkOption {
            description = "Makes this container wanted by multi-user.target";
            type = bool;
            default = true;
          };

          datadir = mkOption {
            description = ''
              Where to mount the persistent data directory.
              null or false to disable.
            '';
            type = coercedTo bool (x: if x then "/data" else null) (nullOr path);
            default = null;
          };

          environment = mkOption {
            description = "The set of environment variables";
            type = attrsOf str;
            default = { };
          };

          environmentFiles = mkOption {
            description = ''
              Read extra environment variables from these files
              (useful for secrets)
            '';
            type = listOf path;
            default = [ ];
          };

          path = mkOption {
            description = "The list of packages to make available via $PATH";
            type = listOf package;
            default = [ ];
          };

          ports =
            let regex = "((tcp|udp)(4|6)?/)?([0-9]+)(:([0-9]+))?"; in
            mkOption {
              description = ''
                Port forwardings of this container.
                All entries must match the regex ${regex}

                So all of these would be valid:
                  | input        | protocol | IP type | container port | parsed as                   |
                  |--------------+----------+---------+----------------+-----------------------------|
                  | 123          | no       | no      | no             | tcp4/123:123 & tcp6/123:123 |
                  | 123:456      | no       | no      | yes            | tcp4/123:456 & tcp6/123:456 |
                  | udp/123      | yes      | no      | no             | udp4/123:123 & udp6/123:123 |
                  | udp/123:456  | yes      | no      | yes            | udp4/123:456 & udp6/123:456 |
                  | udp6/123     | yes      | yes     | no             | udp6/123:123                |
                  | udp6/123:456 | yes      | yes     | yes            | udp6/123:456                |

                Note that you cannot specify *just* an IP type without a protocol.
              '';

              type = coercedTo (listOf (either port str))
                (builtins.concatMap (x:
                  let
                    parts =
                      if builtins.typeOf x == builtins.typeOf 0
                      then [ null null null (toString x) null null ]
                      else builtins.match regex x;

                    typ = defaultTo "tcp" (elemAt parts 1);
                    ipv = mapNullable toInt (elemAt parts 2);
                    src = toInt (elemAt parts 3);
                    dst = pipe (elemAt parts 5) [ (mapNullable toInt) (defaultTo src) ];

                    mk = ipv: { inherit ipv typ src dst; };
                  in
                  if ipv == null then [ (mk 4) (mk 6) ] else [ (mk ipv) ]))
                (listOf (submodule ({
                  options = {
                    ipv = mkOption { type = enum [ 4 6 ]; };
                    typ = mkOption { type = enum [ "tcp" "udp" ]; };
                    src = mkOption { type = port; };
                    dst = mkOption { type = port; };
                  };
                })));
              default = [ ];
            };

          secrets = mkOption {
            description = ''
              List of <host path>:<container path> of secrets to mount

              Instead of the host path (which must be absolute),
              the name of an Aquaris-managed secret can also be given.
            '';
            type = listOf (coercedTo str
              (x:
                let parts = splitString ":" x; in
                assert builtins.length parts == 2; rec {
                  host = pipe parts [
                    (flip builtins.elemAt 0)
                    (x: if hasPrefix "/" x then x else secret x)
                  ];

                  cont = builtins.elemAt parts 1;

                  name = builtins.hashString "sha256" host;
                })
              (submodule ({
                options = {
                  host = mkOption { type = path; };
                  cont = mkOption { type = path; };
                  name = mkOption { type = str; };
                };
              })));
            default = [ ];
          };
        };

        config = {
          # wait for post-launch to do its thing
          script = mkBefore ''
            while true; do
              if [ -e /etc/passwd ] && [ -e /etc/group ]; then break; fi
              ${getExe' pkgs.coreutils "sleep"} 1
            done
          '';

          environment = {
            SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
          };
        };
      }));
      default = { };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # container instantiations
    {
      environment.etc = pipe cfg.containers [
        (mapAttrsToList (name: cfg: [
          (mkIf (cfg.datadir != null) {
            "pnoc/datadir/${name}".text = "";
          })

          (mkIf (cfg.ports != [ ]) {
            "pnoc/ports/${name}".text = pipe cfg.ports [
              (map (flip pipe [
                (x: with x; [ ipv typ src dst ])
                (map toString)
                (builtins.concatStringsSep " ")
              ]))
              concatLines
            ];
          })
        ]))
        builtins.concatLists
        aquaris.lib.merge
      ];

      systemd.services = flip mapAttrs' cfg.containers (name: cfg: {
        name = "pnoc-${name}";
        value = mkService name cfg;
      });
    }

    # global resources
    {
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

      users = {
        groups.dnsmasq = { };

        users.dnsmasq = {
          group = "dnsmasq";
          isSystemUser = true;
        };
      };

      networking.firewall.trustedInterfaces = [ "pnoc0" ];

      systemd = {
        network = {
          # otherwise it hangs until containers have received their IPs
          wait-online.ignoredInterfaces = [ "pnoc0" ];

          netdevs."pnoc0" = {
            netdevConfig = {
              Name = "pnoc0";
              Kind = "bridge";
            };
          };

          networks."pnoc0" = {
            matchConfig = {
              Name = "pnoc0";
              Kind = "bridge";
            };

            networkConfig = {
              Address = [
                "10.42.0.1/16"
                "fd42::1/80"
              ];

              IPMasquerade = "both";
            };
          };
        };

        services = {
          "pnoc_dns" = {
            serviceConfig = {
              Type = "simple";
              ExecStartPre = [ "${getExe' pkgs.coreutils "mkdir"} -p /run/pnoc/hosts" ];
              ExecStart = "${getExe pkgs.dnsmasq} -C ${pnoc-dns}";
            };

            wantedBy = [ "multi-user.target" ];
          };

          "pnoc_pre_launch@" = {
            # trigger pnoc-clean early to (at least) remove container registration
            # and any resource that we might have created already
            onFailure = [ "pnoc_clean@%i.service" ];

            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${getExe pnoc-pre-launch} %i";
            };
          };

          "pnoc_post_launch@" = {
            # post-launch always has to be started alongside the main service
            # so make it stop alongside it too
            bindsTo = [ "pnoc-%i.service" ];

            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${getExe pnoc-post-launch} %i";

              # we need to stay up after exit
              # so that the main service can bind to us
              RemainAfterExit = true;
            };
          };

          "pnoc_clean@" = {
            # wait for post-launch to write its stuff before removing it
            after = [ "pnoc_post_launch@%i.service" ];

            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${getExe pnoc-clean} %i";
            };
          };
        };
      };
    }
  ]);
}
