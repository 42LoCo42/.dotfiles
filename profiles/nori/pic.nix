{ aquaris, config, lib, pkgs, utils, ... }:
let
  inherit (lib) join pipe zipAttrs;

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
    services.pic-vpn = {
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
  } // mounts;

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
      lbmvweb = {
        HostName = "www1.d11121.lbmv.de";
        User = "www-data";
      };

      meeting2 = {
        HostName = "meeting2.planet-ic.de";
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

      greifswald = {
        HostName = "web03270.pvm.imv.de";
        User = "root";
        SetEnv.TERM = "xterm-256color";
      };

      bonetty = {
        HostName = "ares-bonetty.p4.net";
        User = "root";
        SetEnv.TERM = "xterm-256color";

        HostKeyAlgorithms = "+ssh-rsa";
        PubkeyAcceptedKeyTypes = "+ssh-rsa";
      };
    };
  }];
}
