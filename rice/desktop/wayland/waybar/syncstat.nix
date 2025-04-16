{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib)
    getExe
    mkAfter
    mkIf
    mkOption
    ;
  inherit (lib.types)
    bool
    path
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

    keyFile = mkOption {
      type = path;
      description = "File containing the Syncthing API key";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (_: pkgs: {
        syncstat = pkgs.writeShellApplication {
          name = "syncstat";
          runtimeInputs = with pkgs; [ curl jq ];
          text = aquaris.lib.subsT ./syncstat.sh {
            inherit (cfg) folder keyFile;
          };
        };
      })
    ];

    home-manager.sharedModules = [{
      programs.waybar.settings.mainBar = {
        modules-left = mkAfter [ "custom/syncstat" ];

        "custom/syncstat" = {
          format = "󰓦  {text}% in sync";
          exec = "${getExe pkgs.syncstat}";
          interval = 1;
          hide-empty-text = true;
        };
      };
    }];
  };
}
