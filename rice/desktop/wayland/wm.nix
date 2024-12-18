{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib) getExe getExe';
  inherit (aquaris.lib) subsF subsT;
in
lib.mkIf config.rice.desktop {
  programs.hyprland.enable = true;

  home-manager.sharedModules = [{
    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = subsT ./files/hyprland.conf {
        early-config = config.rice.hypr-early-config;

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
}
