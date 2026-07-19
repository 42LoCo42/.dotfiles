{ config, lib, pkgs, ... }: {
  options.rice.desktop.equibop.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.equibop.enable {
    rice.desktop.wayland.hyprland.postConfig = ''
      bind = $mod CTRL, m, exec, equibop --toggle-mic
    '';

    home-manager.sharedModules = [{
      aquaris.persist = { ".config/equibop" = { }; };
      home.packages = with pkgs; [ equibop ];
      xdg.configFile."equibop-flags.conf".text = ''
        --wayland
      '';
    }];
  };
}
