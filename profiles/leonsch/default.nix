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
  };

  rice = {
    desktop = {
      enable = true;

      wayland = {
        hyprland.windowRules = ''
          windowrulev2 = workspace 3, class:(vesktop)
        '';

        waybar = {
          icons = {
            "1" = "";
            "2" = "";
            "3" = "󰙯";
            "4" = "";
          };

          syncstat = {
            enable = true;
            folder = "cw6hv-bpaei"; # main
            keyFile = config.aquaris.secret "user/leonsch/syncstat";
          };
        };

        wlsunset = {
          lat = "54.31";
          lon = "13.09";
        };
      };
    };

    ca.enable = true;
    dns.enable = true;
    nixremote.enable = true;
    syncthing.enable = true;
    tailscale.enable = true;
    use-ncps.enable = true;
  };

  home-manager.sharedModules = [{
    aquaris = {
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
