{ pkgs, lib, aquaris, ... }:
let inherit (lib) flip pipe; in
{
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
}
