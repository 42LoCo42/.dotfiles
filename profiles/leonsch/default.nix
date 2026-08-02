{ aquaris, config, lib, pkgs, ... }:
let
  inherit (lib)
    getExe
    mapAttrs
    mkAfter
    mkBefore
    mkMerge
    singleton
    ;

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

  sync-manager = pkgs.writeShellApplication {
    name = "sync-manager";

    text = aquaris.lib.subsT ./sync-manager.sh {
      config = pkgs.writeText "lsyncd.conf" ''
        sync {
          default.rsync,
          source = "/home/leonsch/config/",
          target = "bunny:config/",
          delay = 0.25,
          exclude = "keys",
          rsync = {
            archive = true,
            compress = true,
            verbose = true,
          },
        }
      '';
    };

    runtimeInputs = with pkgs; [
      lsyncd
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
      "odin.planet-ic.de" = "192.168.183.91";
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
              rules = [ "title Discord.*" ];
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

            windowrule = match:class background-wrap, float 1, move 0 0, size monitor_w monitor_h

            bind = $mod, p, exec, ${getExe password-manager}
            bind = $mod, s, exec, ${getExe sync-manager}
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

    ca.enable = true;
    dns.enable = true;
    nixremote.use = true;
    podman.enable = true;
    syncthing.enable = true;
    tailscale.enable = true;
  };

  home-manager.sharedModules = singleton (hm: {
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
            "https://irc.eleonora.gay"
            "https://vw.eleonora.gay"

            # banking
            "https://spk-vorpommern.de"
            "https://vbvorpommern.de"
          ];
        };

        preRun = mkBefore ''
          if ((LAUNCHER)) && [ "''${CAPTIVE_PORTAL+x}" = "" ]; then
            hyprctl keyword decoration:blur:new_optimizations false
            foot -a background-wrap -o colors-dark.alpha=0 \
              rsyncy -az --delete "firefox-sync:" "$FIREFOX_PROFILE_DIR"
            hyprctl keyword decoration:blur:new_optimizations true
          fi
        '';

        postRun = mkAfter ''
          if ((LAUNCHER)) && [ "''${CAPTIVE_PORTAL+x}" = "" ]; then
            hyprctl keyword decoration:blur:new_optimizations false
            foot -a background-wrap -o colors-dark.alpha=0 \
              rsyncy -az --delete "$FIREFOX_PROFILE_DIR" "firefox-sync:"
            hyprctl keyword decoration:blur:new_optimizations true
          fi
        '';
      };

      # default key is fido, but we don't want it for git signing
      git.sshKeyFile = _: config.aquaris.secret "user/leonsch/ssh/main";

      persist = {
        ".config/rustdesk" = { };
        ".config/steamguard-cli" = { };

        ".local/share/Steam/compatibilitytools.d" = { };
        ".local/share/chatterino" = { };
        ".local/share/typst/packages/local" = { };
        ".local/share/umu" = { };

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

    systemd.user.tmpfiles.rules = map
      (x: "L+ %h/.asn/${x} - - - - ${config.aquaris.secret "user/leonsch/asn/${x}"}")
      [ "cloudflare_token" "ipinfo_token" "iqs_token" ];

    home = {
      packages = with pkgs; [
        # work
        cifs-utils
        openvpn

        asn
        catgirl
        chatterino7
        eka
        jameica
        rsyncy
        rustdesk-flutter
        sshfs
        steamguard-cli
        syncplay
        umu-launcher

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
      "catgirl/eleonora.gay".text = ''
        host = irc.eleonora.gay
        cert = ${config.aquaris.secret "user/leonsch/irc"}
        sasl-external
        debug
      '';

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

          playerpath = getExe hm.config.programs.mpv.finalPackage;
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

      # use my stupid baka deadname for work repos X_X
      "jj/conf.d/work.toml".text = ''
        --when.workspaces = ["/persist/home/leonsch/sync/work"]

        [user]
        name = "Leon Schumacher"
      '';
    };

    programs = {
      zsh.initContent = ''
        alias rsync=rsyncy
        compdef rsyncy=rsync
      '';

      ssh.settings = (mapAttrs (n: x: x // {
        ControlMaster = "auto";
        ControlPath = "\${HOME}/.ssh/control-${n}";
      })) {
        ##### private machines #####

        bunny = {
          HostName = "exit.bunny.vpn";
          Port = 18213;
          User = "admin";
        };

        bunny-fallback = {
          HostName = "eleonora.gay";
          AddressFamily = "inet";
          Port = 18213;
          User = "admin";
        };

        firefox-sync = {
          HostName = "exit.bunny.vpn";
          Port = 18213;
          User = "admin";

          AddKeysToAgent = "no";
          IdentitiesOnly = "yes";
          IdentityAgent = "/dev/null";
          IdentityFile = config.aquaris.secret "user/leonsch/firefox-sync";
        };

        forgejo = proxy "git.bunny:22" {
          User = "forgejo";
        };

        laniakea = {
          HostName = "laniakea.bunny.vpn";
          User = "admin";
        };

        ##### people #####

        hannes = {
          HostName = "satinor.bunny.vpn";
          User = "ercanar";
        };

        hapi = {
          HostName = "owo-ercanar-senpai.duckdns.org";
          Port = 12345;
          User = "ercanar";
        };

        xenon = {
          HostName = "xenon.bunny.vpn";
          User = "ercanar";
        };

        ######

        jana = {
          HostName = "primula25.duckdns.org";
          Port = 22000;
          User = "jana";
        };

        #####

        deimos = {
          HostName = "deimos.bunny.vpn";
          User = "melinda";
          ForwardAgent = false;
        };

        phobos = {
          HostName = "phobos.bunny.vpn";
          User = "melinda";
          ForwardAgent = false;
        };

        #####

        logan = {
          HostName = "strontium.bunny.vpn";
          User = "logan";
          ForwardAgent = false;
        };

        strontium = {
          HostName = "strontium.bunny.vpn";
          User = "root";
          ForwardAgent = false;
        };

        ##### work - PIC #####

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
    };
  });

}
