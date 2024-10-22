{ pkgs, lib, config, ... }:
let
  effect = pkgs.runCommandCC "effect.so" { } ''
    gcc -fPIC -shared ${./files/lock-effect.c} -o $out
  '';
in
lib.mkIf config.rice.desktop {
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
}
