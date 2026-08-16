{ config, lib, pkgs, ... }: {
  options.rice.desktop.nix-search-tv.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.nix-search-tv.enable {
    home-manager.sharedModules = [{
      aquaris = {
        persist = { ".cache/nix-search-tv" = { }; };

        hyprland.binds = f: with f; {
          C-n = execR "foot ntv" { fullscreen_state = "2 0"; };
        };
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
  };
}
