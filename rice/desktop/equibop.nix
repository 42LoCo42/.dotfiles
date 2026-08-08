{ config, lib, pkgs, ... }: {
  options.rice.desktop.equibop.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.equibop.enable {
    rice.desktop.wayland.hyprland = {
      binds = f: with f; {
        c = exec "uwsm app equibop";
      };

      settings.window_rule = [{
        match.class = "equibop";
        workspace = "3 silent";
      }];
    };

    home-manager.sharedModules = [{
      aquaris.persist = { ".config/equibop" = { }; };
      home.packages = with pkgs; [ equibop ];
      xdg.configFile."equibop-flags.conf".text = ''
        --wayland
      '';
    }];
  };
}
