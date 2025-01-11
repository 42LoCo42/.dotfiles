{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib) getExe getExe' mkIf mkOption;
  inherit (lib.types) bool str;
  inherit (aquaris.lib) subsF subsT;
in
{
  options.rice.desktop.wayland.hyprland = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    preConfig = mkOption {
      type = str;
      default = "";
    };
  };

  config = mkIf config.rice.desktop.wayland.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    home-manager.sharedModules = [{
      aquaris.persist = { ".config/qalculate" = { }; };

      wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = subsT ./hyprland.conf {
          inherit (config.rice.desktop.wayland.hyprland) preConfig;

          fuzzel = getExe pkgs.fuzzel;
          ipython = getExe' pkgs.python3Packages.ipython "ipython";
          pulsemixer = getExe pkgs.pulsemixer;
          qalc = getExe pkgs.libqalculate;
          vesktop = getExe pkgs.vesktop;

          audio-helper = subsF {
            file = ./scripts/audio-helper.sh;
            func = pkgs.writeScript;
            subs = {
              pulsemixer = getExe pkgs.pulsemixer;
              mpc = getExe pkgs.mpc-cli;
            };
          };

          brightness-helper = subsF {
            file = ./scripts/brightness-helper.sh;
            func = pkgs.writeScript;
            subs = {
              brightnessctl = getExe pkgs.brightnessctl;
            };
          };

          dropdown = subsF {
            file = ./scripts/dropdown.sh;
            func = pkgs.writeScript;
          };

          prompt = subsF {
            file = ./scripts/prompt.sh;
            func = pkgs.writeScript;
            subs = {
              fuzzel = getExe pkgs.fuzzel;
            };
          };

          terminal = subsF {
            file = ./scripts/terminal.sh;
            func = pkgs.writeScript;
          };
        };
      };
    }];
  };
}
