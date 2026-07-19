{ aquaris, config, lib, pkgs, ... }:
let inherit (lib) flip mkIf mkOption pipe; in {
  options.rice.desktop.alarm.enable = mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = mkIf config.rice.desktop.alarm.enable {

    nixpkgs.overlays = [
      (_: pkgs: {
        alarm = pipe ./main.sh [
          (flip aquaris.lib.subsT { bell = "${./bell.mp3}"; })
          (pkgs.writeShellScriptBin "alarm")
        ];
      })
    ];

    home-manager.sharedModules = [{
      home.packages = with pkgs; [ alarm ];
    }];
  };
}
