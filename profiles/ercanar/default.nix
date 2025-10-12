{ pkgs, config, aquaris, ... }:
let inherit (config.rice.ssh) proxy; in
{
  imports = [ ../common ./aliases.nix ];

  aquaris = {
    users = pkgs.lib.mkMerge [
      { inherit (aquaris.cfg.users) ercanar; }
      { ercanar.admin = true; }
    ];
  };

  rice = {
    desktop = {
      enable = true;

      emacs.allLanguages = false;

      wayland = {
        hyprland.workspaces = {
          "0" = {
            autostart = [ "@terminal@" ];
          };

          "1" = {
            icon = "";
            autostart = [ "uwsm app vesktop" ];
            rules = [ "class:(vesktop)" ];
          };

          "2" = {
            icon = "";
            autostart = [ "uwsm app steam" ];
            rules = [ "class:(steam)" "title:(Steam)" ];
          };

          "3" = {
            icon = "󰈹";
            autostart = [ "uwsm app librewolf" ];
            rules = [ "class:(librewolf)" ];
          };

          "4" = {
            rules = [
              "class:(soffice)"
              "initialClass:(libreoffice-startcenter)"
            ];
          };

          "5" = {
            icon = "";
            rules = [
              "class:(Gimp)"
              "class:(org.musescore.MuseScore)"
              "class:(googleearth)"
            ];
          };
        };

        hyprland.postConfig = ''
          bind = $mod      , l, exec, libreoffice
          bind = $mod SHIFT, g, exec, gimp
          bind = $mod SHIFT, w, exec, uwsm app librewolf
        '';


        hypridle.timeouts = {
          lock = 900; # 15 min
          suspend = 2700; # 45 min
        };

        wlsunset = {
          lat = "48.11";
          lon = "11.60";
        };
      };
    };

    dns = {
      enable = true;
      ui = true;
    };

    ca.enable = true;
    nixremote.use = true;
    printer.enable = true;
    syncthing.enable = true;
    tailscale.enable = true;

    insecureNames = [
      "googleearth-pro"
    ];

    unfreeNames = [
      "googleearth-pro"
      "steam"
      "steam-unwrapped"
    ];
  };

  programs.steam.enable = true;

  home-manager.sharedModules = [{
    aquaris = {
      firefox.settings.ui = {
        pageNext = true;
        pagePrev = true;
        tabNext = true;
        tabPrev = true;
      };

      git.sshKeyFile = _: config.aquaris.secret "user/ercanar/ssh/main";

      persist = {
        "dev" = { };
        "doc" = { };
        "img" = { };

        ".config/GIMP" = { };
        ".config/libreoffice" = { };
        ".config/rustdesk" = { };

        # musescore
        ".config/MuseScore" = { };
        ".local/share/MuseScore" = { };

        ".local/share/Steam" = { };

        # google earth
        ".config/Google" = { };
        ".googleearth" = { };

        # steam games
        ".config/Vampire_Survivors" = { };
        ".config/Vampire_Survivors_461785915" = { };
        ".config/Vampire_Survivors_Data" = { };
        ".config/unity3d/Asteroid Lab/Terraformers" = { };
        ".config/unity3d/Dry Cactus/Poly Bridge 2" = { };
        ".config/unity3d/Free Lives/Terra Nil" = { };
        ".config/unity3d/Klei/Oxygen Not Included" = { };
        ".factorio" = { };
        ".local/share/Celeste" = { };
        ".local/share/Rocket League" = { };
        ".local/share/Surviving Mars" = { };
      };
    };

    home.packages = with pkgs; [
      gimp
      googleearth-pro
      imagemagick
      libreoffice-fresh
      musescore
      rustdesk-flutter
    ];

    programs.ssh.matchBlocks = {
      forgejo = proxy "git.bunny:22" {
        user = "forgejo";
      };

      pi = {
        hostname = "owo-ercanar-senpai.duckdns.org";
        port = 12345;
      };
    };
  }];
}
