{ config, lib, pkgs, ... }: {
  options.rice.desktop.nix-search-tv.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.nix-search-tv.enable {
    home-manager.sharedModules = [{
      aquaris.persist = {
        ".cache/nix-search-tv" = { };
      };

      home.packages = [
        (pkgs.writeShellApplication {
          name = "ntv";

          runtimeInputs = with pkgs; [
            fzf
            nix-search-tv
          ];

          text = builtins.readFile ./main.sh;
        })
      ];
    }];

    rice.desktop.wayland.hyprland.postConfig = ''
      windowrule = match:class nix-search-tv, fullscreen_state 1 0
      bind = $mod ctrl, n, exec, foot -a nix-search-tv ntv
    '';
  };
}
