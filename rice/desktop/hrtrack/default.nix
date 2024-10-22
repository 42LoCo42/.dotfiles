{ pkgs, lib, config, aquaris, ... }: lib.mkIf config.rice.desktop {
  nixpkgs.overlays = [
    (_: pkgs: {
      hrtrack = lib.pipe ./main.sh [
        (x: aquaris.lib.subsT x { inherit (config.rice) hrtrack-file; })
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
