{ pkgs, lib, config, ... }:
let
  inherit (lib) getExe mkIf mkOption;
  inherit (lib.types) bool;

  effect = pkgs.runCommandCC "effect.so" { } ''
    gcc -fPIC -shared ${./lock-effect.c} -o $out
  '';
in
{
  options.rice.desktop.wayland.swaylock.enable = mkOption {
    type = bool;
    default = false;
  };

  config = mkIf config.rice.desktop.wayland.swaylock.enable {
    security.pam.services.swaylock = { };

    services.systemd-lock-handler.enable = true;

    home-manager.sharedModules = [{
      xdg.configFile."swaylock/config".text = ''
        screenshots
        effect-scale=0.5
        effect-pixelate=3
        effect-custom=${effect}
        effect-scale=2

        clock
        fade-in=0.5
      '';

      systemd.user.services.swaylock = {
        Unit = {
          Before = [ "lock.target" "sleep.target" ];
          PartOf = [ "lock.target" "sleep.target" ];
          OnSuccess = [ "unlock.target" ];
        };

        Service = {
          Type = "forking";
          ExecStart = getExe (pkgs.writeShellApplication {
            name = "swaylock";
            runtimeInputs = with pkgs; [ coreutils swaylock-effects ];
            text = ''
              swaylock -f
              sleep 0.5
            '';
          });
          Restart = "on-failure";
          RestartSec = 0;
        };

        Install.WantedBy = [ "lock.target" "sleep.target" ];
      };
    }];
  };
}
