{ aquaris, config, lib, pkgs, utils, ... }:
let
  inherit (lib) concatMapAttrsStringSep join pipe zipAttrs;

  workDir = "/persist/home/nori/sync/work/PIC";

  smbDir = "${workDir}/files";
  smbShares = [ "G" "K" "L" "M" "U" "V" "Z" "print$" ];

  mkMount = share:
    let
      dst = "${smbDir}/${share}";
      pfx = utils.escapeSystemdPath dst;
    in
    {
      mounts = {
        name = "${pfx}.mount";
        what = "//filer1.planet-ic.local/${share}";
        where = dst;
        type = "cifs";
        options = join "," [
          "_netdev"
          "nosuid"
          "rw"

          "uid=nori"
          "forceuid"
          "gid=users"
          "forcegid"

          "cred=${config.aquaris.secret "user/nori/pic"}"
        ];

        after = [ "pic-vpn.service" ];
        bindsTo = [ "pic-vpn.service" ];
      };

      automounts = {
        name = "${pfx}.automount";
        where = dst;
        wantedBy = [ "multi-user.target" ];
      };
    };

  mounts = pipe smbShares [
    (map mkMount)
    zipAttrs
  ];

  vpn-ssh-mark = "0x50494321"; # "PIC!" in hex

  vpn-ssh-ips = {
    meeting2 = "194.59.16.142";
  };
in
{
  aquaris.dnscrypt.rules.cloaking = {
    "filer1.planet-ic.local" = "172.16.96.167";
    "odin.planet-ic.de" = "192.168.183.91";
    "subversion.planet-ic.de" = "172.16.96.79";

    "lbswis.gbv.de" = "127.0.0.1";
    "readers.lakd" = "127.0.0.1";
  };

  environment.systemPackages = with pkgs; [
    cifs-utils
    openvpn
  ];

  systemd = {
    services = {
      pic-vpn = {
        serviceConfig.Type = "notify";

        path = with pkgs; [ openvpn ];
        script = ''
          SOCK="$NOTIFY_SOCKET"
          unset NOTIFY_SOCKET

          args=()
          if [ "${aquaris.name}" = "akyuro" ]; then
            args+=(--mssfix 1300)
          fi

          exec openvpn                          \
            "''${args[@]}"                      \
            --config "${workDir}/planetic.ovpn" \
            --script-security 2                 \
            --route-up "/usr/bin/env NOTIFY_SOCKET=$SOCK systemd-notify --ready"
        '';
      };

      pic-ssh-route = {
        after = [ "pic-vpn.service" ];
        partOf = [ "pic-vpn.service" ];
        wantedBy = [ "pic-vpn.service" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        path = with pkgs; [ iproute2 ];
        script = ''
          # grab marked connections and route them via SSH table
          rule="fwmark ${vpn-ssh-mark} table pic-ssh priority 1000"
          if [ -z "$(ip rule show $rule)" ]; then ip rule add $rule; fi

          # route all to tun0
          ip route replace default dev tun0 table pic-ssh
        '';
      };
    };
  } // mounts;

  networking = {
    nftables.ruleset = ''
      # mark all vpn-ssh-ips
      table inet vpn-ssh-mark {
        chain output {
          type route hook output priority mangle; policy accept;
          ${concatMapAttrsStringSep "\n"
            (_: x: "ip daddr ${x} tcp dport 22 meta mark set ${vpn-ssh-mark}")
            vpn-ssh-ips}
        }
      }

      # use SNAT for marked packets
      table inet vpn-ssh-snat {
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          oifname "tun0" meta mark ${vpn-ssh-mark} masquerade
        }
      }
    '';

    # define pic-ssh table
    iproute2 = {
      enable = true;
      rttablesExtraConfig = ''
        100 pic-ssh
      '';
    };
  };

  home-manager.sharedModules = [{
    aquaris.persist = {
      "work" = { };
    };

    # use my stupid baka deadname for work repos X_X
    xdg.configFile."jj/conf.d/work.toml".text = ''
      --when.workspaces = ["/persist/home/nori/sync/work"]

      [user]
      name = "Leon Schumacher"
    '';

    programs.ssh.settings = {
      # ns1
      "213.254.36.134" = {
        IdentityFile = config.aquaris.secret "user/nori/ssh/old/ed25519";
      };

      "nutzer.lbmv.de" = {
        User = "www-data";
        IdentityFile = config.aquaris.secret "user/nori/ssh/old/rsa";
      };

      meeting2 = {
        HostName = vpn-ssh-ips.meeting2;
        User = "root";
        SetEnv.TERM = "xterm-256color";
      };

      freepbx = {
        HostName = "195.98.195.10";
        User = "root";
        SetEnv.TERM = "xterm-256color";

        HostKeyAlgorithms = "+ssh-rsa";
        PubkeyAcceptedKeyTypes = "+ssh-rsa";
      };

      bonetty = {
        HostName = "ares-bonetty.p4.net";
        User = "root";
        SetEnv.TERM = "xterm-256color";

        IdentityFile = config.aquaris.secret "user/nori/ssh/old/rsa";
        HostKeyAlgorithms = "+ssh-rsa";
        PubkeyAcceptedKeyTypes = "+ssh-rsa";
      };
    };
  }];
}
