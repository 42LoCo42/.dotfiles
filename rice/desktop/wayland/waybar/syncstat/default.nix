{ aquaris, config, lib, pkgs, ... }:
let
  inherit (lib)
    getExe
    mkAfter
    mkIf
    mkOption
    ;
  inherit (lib.types)
    bool
    str
    ;

  cfg = config.rice.desktop.wayland.waybar.syncstat;
in
{
  options.rice.desktop.wayland.waybar.syncstat = {
    enable = mkOption {
      type = bool;
      description = "Show the Syncthing completion of a folder";
      default = false;
    };

    folder = mkOption {
      type = str;
      description = "Folder ID";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (_: pkgs: {
        syncstat = aquaris.lib.subsF {
          file = ./syncstat.py;
          func = pkgs.writeScriptBin;
          subs = {
            python = getExe (pkgs.python3.withPackages
              (p: with p; [ requests ]));

            inherit (cfg) folder;
          };
        };
      })
    ];

    home-manager.sharedModules = [{
      programs.waybar.settings.default = {
        modules-left = mkAfter [ "custom/syncstat" ];

        "custom/syncstat" = {
          format = "󰓦  {text}";
          exec = "${getExe pkgs.syncstat}";
          hide-empty-text = true;
        };
      };
    }];
  };
}
