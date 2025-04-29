{ pkgs, lib, config, aquaris, ... }:
let inherit (config.rice.ssh) proxy; in
{
  imports = [ ../../rice ./aliases.nix ];

  # TODO move into rice like unfreeNames
  nixpkgs.config.allowInsecurePredicate = p: builtins.elem (lib.getName p) [
    "googleearth-pro"
  ];

  aquaris = {
    users = pkgs.lib.mkMerge [
      { inherit (aquaris.cfg.users) ercanar; }
      { ercanar.admin = true; }
    ];

    filesystems = { fs, ... }: {
      zpools.rpool = fs.defaultPool;
    };

    persist = {
      enable = true;
    };
  };

  hardware.printers = {
    ensurePrinters = [{
      deviceUri = "dnssd://Brother%20DCP-L2530DW%20series._ipp._tcp.local/?uuid=e3248000-80ce-11db-8000-5c619941d47e";
      name = "Brother";
      model = "everywhere";
    }];
  };

  rice = {
    desktop = {
      enable = true;

      emacs.enable = lib.mkForce false;

      wayland = {
        hyprland = {
          postConfig = ''
            bind = $mod      , l, exec, libreoffice
            bind = $mod SHIFT, g, exec, gimp
            bind = $mod SHIFT, w, exec, uwsm app librewolf
          '';

          # TODO check these after programs are installed
          # to get correct matchers
          windowRules = ''
            windowrulev2 = workspace 2, class:(vesktop)
            windowrulev2 = workspace 4, class:(librewolf)
            windowrulev2 = workspace 5, class:(genshin)
            windowrulev2 = workspace 6, class:(Gimp)
            windowrulev2 = workspace 6, class:(org.musescore.MuseScore)
            windowrulev2 = workspace 6, class:(googleearth)

            # Steam
            windowrulev2 = workspace 3, class:(steam)
            windowrulev2 = workspace 3, title:(Steam)

            # libreoffice
            windowrulev2 = workspace 5, class:(soffice)
            windowrulev2 = workspace 5, initialClass:(libreoffice-startcenter)
          '';
        };

        hypridle.timeouts = {
          lock = 900; # 15 min
          suspend = 2700; # 45 min
        };

        waybar.icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "󰈹";
          "5" = "⛩️";
          "6" = "";
        };

        wlsunset = {
          lat = "48.11";
          lon = "11.60";
        };
      };
    };

    ca.enable = true;
    dns.enable = true;
    nixremote.enable = true;
    printer.enable = true;
    tailscale.enable = true;

    unfreeNames = [
      "googleearth-pro"
      "steam"
      "steam-unwrapped"
    ];
  };

  programs.steam = {
    enable = true;
  };

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
        ".config/MuseScore" = { };
        ".config/rustdesk" = { };

        ".local/share/Steam" = { };

        # google earth
        ".config/Google" = { };
        ".googleearth" = { };

        # steam games
        ".config/Vampire_Survivors" = { };
        ".config/Vampire_Survivors_461785915" = { };
        ".config/Vampire_Survivors_Data" = { };
        ".factorio" = { };
      };
    };

    home.packages = with pkgs; [
      gimp
      googleearth-pro
      imagemagick
      libreoffice
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
