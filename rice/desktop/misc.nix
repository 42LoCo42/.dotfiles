{ config, lib, pkgs, ... }: {
  options.rice.desktop.misc.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.misc.enable {
    programs.gamemode.enable = true;

    users.users = builtins.mapAttrs
      (_: _: { extraGroups = [ "adbusers" "gamemode" ]; })
      config.aquaris.users;

    security.wrappers = {
      newuidmap.enable = lib.mkForce true;
      newgidmap.enable = lib.mkForce true;
    };

    rice.unfreeNames = [ "p7zip" ];

    home-manager.sharedModules = [{
      aquaris.persist.".android" = { }; # for ADB

      home = {
        packages = with pkgs; [
          android-tools
          btrfs-progs
          cryptsetup
          feh
          gucharmap
          p7zip-rar
          pwgen
          python3
          scrcpy
          wf-recorder
        ];

        shellAliases =
          let join = builtins.concatStringsSep " "; in {
            ytm = join [
              "yt-dlp"
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

      programs = {
        mpv = {
          enable = true;

          config = {
            ao = "pulse";
            vo = if config.rice.desktop.gpu.nvidia.enable then "gpu-next" else "gpu";
            hwdec = "auto";
          };

          scripts = with pkgs.mpvScripts; [
            sponsorblock
          ];
        };

        yt-dlp = {
          enable = true;

          settings = {
            cookies-from-browser = "firefox:~/.librewolf/default";
            format-sort = "vcodec:h264,quality";
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
