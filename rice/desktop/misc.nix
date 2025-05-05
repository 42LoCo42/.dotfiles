{ pkgs, lib, config, ... }: {
  options.rice.desktop.misc.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.misc.enable {
    nix.package = pkgs.lix-fix-help;

    programs.gamemode.enable = true;

    rice.unfreeNames = [ "p7zip" ];

    home-manager.sharedModules = [{
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
          zathura
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
          };
      };

      services.ssh-agent.enable = true;

      # haskek my beloved <3
      xdg.configFile."ghc/ghci.conf".text = ''
        :set -Wall
        :set -Wno-type-defaults
        :set prompt "[1;35mλ>[m "
      '';
    }];
  };
}
