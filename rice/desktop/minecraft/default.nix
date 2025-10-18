{ self, pkgs, lib, config, ... }:
let
  inherit (lib) getExe mkIf mkOption;
  inherit (lib.types) bool;

  cfg = config.rice.desktop.minecraft;

  fjord-flake = self.inputs.fjordlauncher;
  pkgs' = fjord-flake.inputs.nixpkgs.legacyPackages.${pkgs.system};

  preload = pkgs.writeShellApplication {
    name = "fjordlauncher-preload";
    text = builtins.readFile ./preload.sh;
  };
in
{
  options.rice.desktop.minecraft.enable = mkOption {
    type = bool;
    default = false;
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (_: pkgs: {
        inherit (fjord-flake.packages.${pkgs.system}) fjordlauncher;
      })
    ];

    aquaris.caches = [{
      url = "https://unmojang.cachix.org";
      key = "unmojang.cachix.org-1:OfHnbBNduZ6Smx9oNbLFbYyvOWSoxb2uPcnXPj4EDQY=";
    }];

    home-manager.sharedModules = [{
      home.packages = with pkgs; [
        ((fjordlauncher.override {
          jdks = with pkgs; [
            temurin-bin-21
            temurin-bin-17
            temurin-bin-8
          ];

          # use shell wrapper instead of binary since the latter doesn't support --run
          kdePackages = pkgs'.kdePackages // {
            wrapQtAppsHook = pkgs'.kdePackages.wrapQtAppsHook.override {
              makeBinaryWrapper = pkgs'.makeWrapper;
            };
          };
        }).overrideAttrs (old: {
          qtWrapperArgs = (old.qtWrapperArgs or [ ]) ++ [
            "--run ${getExe preload}"
          ];
        }))
      ];

      aquaris.persist = { ".local/share/FjordLauncher" = { }; };
    }];
  };
}
