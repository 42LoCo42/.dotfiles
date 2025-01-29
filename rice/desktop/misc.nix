{ pkgs, lib, config, ... }: {
  options.rice.desktop.misc.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.misc.enable {
    home-manager.sharedModules = [{
      home = {
        packages = with pkgs; [
          feh
          mpv
          yt-dlp
          zathura
        ];

        shellAliases = {
          webcam = builtins.concatStringsSep " " [
            "mpv"
            "av://v4l2:/dev/video0"
            "--profile=low-latency"
            "--untimed=yes"
            "--video-latency-hacks=yes"
            "--wayland-disable-vsync=yes"
            "--video-sync=display-desync"
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
