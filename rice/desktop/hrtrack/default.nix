{ pkgs, lib, config, ... }: {
  options.rice.desktop.hrtrack.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.hrtrack.enable {
    nixpkgs.overlays = [
      (_: pkgs: {
        hrtrack = lib.pipe ./main.sh [
          builtins.readFile
          (pkgs.writeShellScriptBin "hrtrack")
          (x: x.overrideAttrs (old: {
            nativeBuildInputs = with pkgs; [
              copyDesktopItems
              shellcheck-minimal
            ];

            doCheck = true;
            checkPhase = ''
              shellcheck "$target"
            '';

            buildCommand = old.buildCommand + ''
              runHook postInstall
            '';

            desktopItems = [
              (pkgs.makeDesktopItem rec {
                inherit (old) name;
                desktopName = name;
                exec = name;
                icon = ./icon.png;
                terminal = false;
              })
            ];
          }))
        ];
      })
    ];

    home-manager.sharedModules = [{
      home.packages = with pkgs; [ hrtrack ];

      systemd.user = {
        services.hrtrack = {
          Service = {
            Type = "oneshot";
            ExecStart = "${lib.getExe pkgs.hrtrack}";
          };
        };

        timers.hrtrack = {
          Timer = {
            OnBootSec = "1min";
            Unit = "hrtrack.service";
          };

          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    }];
  };
}
