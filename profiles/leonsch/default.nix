{ pkgs, config, aquaris, ... }:
let inherit (config.rice.ssh) proxy; in
{
  imports = [ ../../rice ];

  aquaris = {
    users = pkgs.lib.mkMerge [
      { inherit (aquaris.cfg.users) leonsch; }
      { leonsch.admin = true; }
    ];

    filesystems = { fs, ... }: {
      zpools.rpool = fs.defaultPool;
    };

    persist = {
      enable = true;
      dirs = {
        "/root/.android" = { };
      };
    };

    secrets.rules."@machine/syncstat".user = "leonsch";

    # work stuff
    dnscrypt.rules.cloaking = {
      "lbswis.gbv.de" = "127.0.0.1";
      "readers.lakd" = "127.0.0.1";
    };
  };

  rice = {
    desktop = {
      enable = true;

      wayland = {
        hyprland = {
          workspaces = {
            "1" = {
              icon = "";
            };

            "2" = {
              icon = "";
              rules = [ "class:(vesktop)" ];
            };

            "3" = {
              icon = "";
            };

            "9" = {
              icon = "";
              autostart = [ "uwsm app thunderbird" ];
              rules = [ "initialClass:(thunderbird)" ];
            };
          };
        };

        waybar.syncstat = {
          enable = true;
          folder = "cw6hv-bpaei"; # main
          keyFile = config.aquaris.secret "@machine/syncstat";
        };

        wlsunset = {
          lat = "54.31";
          lon = "13.09";
        };
      };
    };

    dns = {
      enable = true;
      ui = true;
    };

    ca.enable = true;
    nixremote.enable = true;
    syncthing.enable = true;
    tailscale.enable = true;
    use-ncps.enable = true;
  };

  home-manager.sharedModules = [{
    aquaris = {
      firefox = {
        preRun = ''
          LAUNCHER=0
          RUNNING="$FIREFOX_PROFILE_DIR/running"

          if [ ! -e "$RUNNING" ]; then
            if curl --connect-timeout 1 https://icanhazip.com; then
              foot rsync -azvP --delete \
                "firefox-sync:"         \
                "$FIREFOX_PROFILE_DIR"
            fi

            touch "$RUNNING"
            LAUNCHER=1
          fi
        '';

        postRun = ''
          if ((LAUNCHER)); then
            rm -f "$RUNNING"

            if curl --connect-timeout 1 https://icanhazip.com; then
              foot rsync -azvP --delete \
                "$FIREFOX_PROFILE_DIR"  \
                "firefox-sync:"
            fi
          fi
        '';
      };

      # default key is fido, but we don't want it for git signing
      git.sshKeyFile = _: config.aquaris.secret "user/leonsch/ssh/main";

      persist = {
        ".config/rustdesk" = { };

        ".local/share/typst/packages/local" = { };

        "IU" = { };
        "dev" = { };
        "doc" = { };
        "img" = { };
        "work" = { };
      };
    };

    home.packages = with pkgs; [
      openvpn # for corporate VPN
      rustdesk-flutter
    ];

    programs.ssh.matchBlocks = {
      ##### private machines #####

      bunny = proxy "ssh.bunny" {
        user = "admin";
      };

      bunny-fallback = {
        hostname = "eleonora.gay";
        addressFamily = "inet";
        port = 18213;
        user = "admin";
      };

      firefox-sync = {
        hostname = "exit.bunny.vpn";
        user = "admin";

        extraOptions = {
          AddKeysToAgent = "no";
          IdentitiesOnly = "yes";
          IdentityAgent = "/dev/null";
          IdentityFile = config.aquaris.secret "user/leonsch/firefox-sync";
        };
      };

      forgejo = proxy "git.bunny:22" {
        user = "forgejo";
      };

      laniakea = {
        hostname = "laniakea.bunny.vpn";
        user = "admin";
      };

      ##### people #####

      hannes = {
        hostname = "satinor.bunny.vpn";
        user = "ercanar";
      };

      hapi = {
        hostname = "owo-ercanar-senpai.duckdns.org";
        port = 12345;
        user = "ercanar";
      };

      jana = {
        hostname = "primula25.duckdns.org";
        port = 22000;
        user = "jana";
      };

      ##### work - PIC #####

      lbmvweb = {
        hostname = "www1.d11121.lbmv.de";
        user = "www-data";
      };

      meeting2 = {
        hostname = "meeting2.planet-ic.de";
        user = "root";
        setEnv.TERM = "xterm-256color";
      };

      freepbx = {
        hostname = "195.98.195.10";
        user = "root";
        setEnv.TERM = "xterm-256color";

        extraOptions = {
          HostKeyAlgorithms = "+ssh-rsa";
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
        };
      };

      greifswald = {
        hostname = "web03270.pvm.imv.de";
        user = "root";
        setEnv.TERM = "xterm-256color";
      };
    };
  }];
}
