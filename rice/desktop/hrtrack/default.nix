{ pkgs, lib, config, ... }: lib.mkIf config.rice.desktop {
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
  }];
}
