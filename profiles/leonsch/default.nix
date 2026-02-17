{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib) getExe mkAfter mkBefore mkMerge;
  inherit (lib.generators) toINI;
  inherit (config.rice.ssh) proxy;

  my-age = pkgs.age.withPlugins (p: with p; [
    age-plugin-fido2-hmac
  ]);

  password-manager = pkgs.writeShellApplication {
    name = "password-manager";
    text = builtins.readFile ./password-manager.sh;
    runtimeInputs = with pkgs; [
      fuzzel
      my-age
      pstree
      wtype
    ];
  };
in
{
  imports = [ ../common ];

  aquaris = {
    users = mkMerge [
      { inherit (aquaris.cfg.users) leonsch; }
      { leonsch.admin = true; }
    ];

    secrets.rules."@machine/syncstat".user = "leonsch";

    # work stuff
    dnscrypt.rules.cloaking = {
      "filer1.planet-ic.local" = "172.16.96.167";
      "subversion.planet-ic.de" = "172.16.96.79";
      "lbswis.gbv.de" = "127.0.0.1";
      "readers.lakd" = "127.0.0.1";
    };
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  users.users.leonsch.extraGroups = [ "wireshark" ];

  rice = {
    desktop = {
      enable = true;
      wego.location = "Stralsund";

      wayland = {
        hyprland = {
          workspaces = {
            "1" = {
              icon = "";
            };

            "2" = {
              icon = "";
              rules = [ "class vesktop" ];
            };

            "3" = {
              icon = "";
            };

            "9" = {
              icon = "";
              autostart = [ "uwsm app thunderbird" ];
              rules = [ "initial_class thunderbird" ];
            };
          };

          postConfig = ''
            plugin {
              hyprwinwrap {
                class = background-wrap
              }
            }

            bind = $mod, p, exec, ${getExe password-manager}
          '';
        };

        waybar.syncstat = {
          enable = true;
          folder = "cw6hv-bpaei"; # main
        };

        wlsunset = {
          lat = "54.31";
          lon = "13.09";
        };
      };
    };

    dns.enable = true;
    ca.enable = true;
    nixremote.use = true;
    podman.enable = true;
    syncthing.enable = true;
    tailscale.enable = true;
  };

  home-manager.sharedModules = [{
    aquaris = {
      firefox = {
        sanitize = {
          enable = true;
          exceptions = [
            "https://auride.xyz"
            "https://github.com"
            "https://iu.org"
            "https://mynixos.com"
            "https://proton.me"
            "https://reddit.com"
            "https://youtube.com"

            # personal
            "https://chat.eleonora.gay"
            "https://id.eleonora.gay"
            "https://vw.eleonora.gay"

            # banking
            "https://spk-vorpommern.de"
            "https://vbvorpommern.de"
          ];
        };

        preRun = mkBefore ''
          if ((LAUNCHER)) && [ "''${CAPTIVE_PORTAL+x}" = "" ]; then
            hyprctl keyword decoration:blur:new_optimizations false
            foot -a background-wrap -o colors.alpha=0 \
              rsync -azvP --delete                    \
                "firefox-sync:" "$FIREFOX_PROFILE_DIR"
            hyprctl keyword decoration:blur:new_optimizations true
          fi
        '';

        postRun = mkAfter ''
          if ((LAUNCHER)) && [ "''${CAPTIVE_PORTAL+x}" = "" ]; then
            hyprctl keyword decoration:blur:new_optimizations false
            foot -a background-wrap -o colors.alpha=0 \
              rsync -azvP --delete                    \
                "$FIREFOX_PROFILE_DIR" "firefox-sync:"
            hyprctl keyword decoration:blur:new_optimizations true
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

    wayland.windowManager.hyprland.plugins = with pkgs.hyprlandPlugins; [
      hyprwinwrap
    ];

    home = {
      packages = with pkgs; [
        eka
        jameica
        openvpn # for corporate VPN
        rustdesk-flutter
        sshfs
        syncplay

        my-age
        (pkgs.writeShellApplication {
          name = "aged"; # age decrypt

          text = ''
            exec age                                          \
              -i ${config.aquaris.secret "user/leonsch/age"}  \
              -d "$@"
          '';
        })
      ];
    };

    xdg.configFile = {
      "jameica.properties".text = ''
        ask=false
        dir=/persist/home/leonsch/sync/jameica
      '';

      "syncplay.ini".text = toINI { } {
        server_data = {
          host = "exit.bunny.vpn";
          port = 8999;
        };

        client_settings = {
          name = "nori";
          room = "Absolutes Kinori";

          playerpath = pkgs.writeShellScript "mpv-gpu" ''
            exec ${getExe pkgs.mpv} --ao=pulse --vo=gpu-next "$@"
          '';

          mediasearchdirectories = "['/home/leonsch/tmp']";
        };

        general = {
          checkforupdatesautomatically = false;
        };
      };

      "Syncplay/MoreSettings.conf".text = toINI { } {
        MoreSettings = {
          ShowMoreSettings = true;
        };
      };
    };

    programs.ssh.matchBlocks = {
      ##### private machines #####

      bunny = {
        hostname = "exit.bunny.vpn";
        port = 18213;
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
        port = 18213;
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

      bonetty = {
        hostname = "ares-bonetty.p4.net";
        user = "root";
        setEnv.TERM = "xterm-256color";

        extraOptions = {
          HostKeyAlgorithms = "+ssh-rsa";
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
        };
      };
    };
  }];
}
