{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib) getExe getExe' mkIf mkOption pipe;
  inherit (lib.types) bool lines;
  inherit (aquaris.lib) subsF subsT;

  script = x: subsF (x // { func = pkgs.writeScript; });

  cfg = config.rice.desktop.wayland.hyprland;
in
{
  options.rice.desktop.wayland.hyprland = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    preConfig = mkOption {
      type = lines;
      default = "";
    };

    postConfig = mkOption {
      type = lines;
      default = "";
    };

    windowRules = mkOption {
      type = lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
      };

      uwsm.package = pkgs.uwsm.override {
        uuctlSupport = false; # would pull in dmenu
      };
    };

    home-manager.sharedModules = [{
      aquaris.persist = { ".config/qalculate" = { }; };

      wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = pipe ./hyprland.conf [
          builtins.readFile
          (x: builtins.concatStringsSep "\n" [
            cfg.preConfig
            x
            cfg.windowRules
            cfg.postConfig
          ])
          (pkgs.writeText "hyprland-all.conf")
          (x: subsT x {
            fuzzel = getExe pkgs.fuzzel;
            ipython = getExe' pkgs.python3Packages.ipython "ipython";
            pulsemixer = getExe pkgs.pulsemixer;
            qalc = getExe pkgs.libqalculate;
            vesktop = getExe pkgs.vesktop;

            audio-helper = script {
              file = ./scripts/audio-helper.sh;
              subs = {
                pulsemixer = getExe pkgs.pulsemixer;
                mpc = getExe pkgs.mpc-cli;
              };
            };

            brightness-helper = script {
              file = ./scripts/brightness-helper.sh;
              subs = {
                brightnessctl = getExe pkgs.brightnessctl;
              };
            };

            dropdown = script {
              file = ./scripts/dropdown.sh;
            };

            idle-toggle = script {
              file = ./scripts/idle-toggle.sh;
            };

            prompt = script {
              file = ./scripts/prompt.sh;
              subs = {
                fuzzel = getExe pkgs.fuzzel;
              };
            };

            safekill = script {
              file = ./scripts/safekill.sh;
            };

            terminal = script {
              file = ./scripts/terminal.sh;
            };
          })
        ];
      };
    }];
  };
}
