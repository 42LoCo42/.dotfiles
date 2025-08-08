{ pkgs, lib, config, ... }: {
  options.rice.desktop.misc.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.misc.enable {
    programs = {
      adb.enable = true;
      gamemode.enable = true;
    };

    users.users = builtins.mapAttrs
      (_: _: { extraGroups = [ "adbusers" "gamemode" ]; })
      config.aquaris.users;

    rice.unfreeNames = [ "p7zip" ];

    home-manager.sharedModules = [{
      aquaris.persist.".android" = { }; # for ADB

      home = {
        packages = with pkgs; [
          btrfs-progs
          cryptsetup
          feh
          mpv
          p7zip-rar
          pwgen
          python3
          wf-recorder
          yt-dlp
        ];

        shellAliases =
          let join = builtins.concatStringsSep " "; in {
            ytb = join [
              "yt-dlp"
              "--force-ipv4"
              "--cookies-from-browser=firefox:~/.librewolf/default"
            ];

            ytm = join [
              "ytb"
              "--extract-audio"
              "--embed-metadata"
            ];

            ytc = join [
              "ytm"
              "--write-thumbnail"
              "--split-chapters"
              "--output='chapter:%(section_number)02d - %(section_title)s.%(ext)s'"
            ];

            ytl = join [
              "ytm"
              "--embed-thumbnail"
              "--output='%(autonumber)02d - %(title)s.%(ext)s'"
            ];

            webcam = join [
              "mpv"
              "av://v4l2:/dev/video0"
              "--profile=low-latency"
              "--untimed=yes"
              "--video-latency-hacks=yes"
              "--video-sync=display-desync"
              "--wayland-internal-vsync=no"
            ];

            t = "tmux new-session -A -E -s 0";
          };
      };

      services.ssh-agent.enable = true;

      programs = {
        zathura = {
          enable = true;
          options = {
            selection-clipboard = "clipboard";
          };
        };
      };

      # haskek my beloved <3
      xdg.configFile."ghc/ghci.conf".text = ''
        :set -Wall
        :set -Wno-type-defaults
        :set prompt "[1;35mλ>[m "
      '';
    }];
  };
}
