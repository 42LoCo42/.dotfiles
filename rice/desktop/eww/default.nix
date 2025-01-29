{ pkgs, lib, config, ... }: {
  options.rice.desktop.eww.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.eww.enable {
    home-manager.sharedModules = [{
      home.packages = [
        (pkgs.writeShellApplication {
          name = "mpd-info";
          text = builtins.readFile ./mpd-info.sh;

          runtimeInputs = with pkgs; [
            coreutils
            ffmpeg-headless
            findutils
            gnugrep
            jq
            mpc
          ];
        })
      ];

      programs.eww = {
        enable = true;
        configDir = ./.;
      };

      systemd.user.services =
        let eww = "${lib.getExe pkgs.eww} --no-daemonize"; in
        {
          eww = {
            Install.WantedBy = [ "graphical-session.target" ];

            Service = {
              Type = "exec";
              ExecStart = "${eww} daemon";
            };
          };

          mpd-info = {
            Unit = {
              After = [ "eww.service" ];
              Wants = [ "eww.service" ];
            };

            Install.WantedBy = [ "graphical-session.target" ];

            Service = {
              Type = "oneshot";
              ExecStart = "${eww} open mpd-info";
            };
          };
        };
    }];
  };
}
