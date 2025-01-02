{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkOption;
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
    }];
  };
}
