{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib) getExe getExe' mkIf mkOption;
  inherit (lib.types) bool str;
  inherit (aquaris.lib) subsF subsT;

  script = x: subsF (x // { func = pkgs.writeScript; });
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
        extraConfig = subsT ./hyprland.conf {
          inherit (config.rice.desktop.wayland.hyprland) preConfig;

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
        };
      };
    }];
  };
}
