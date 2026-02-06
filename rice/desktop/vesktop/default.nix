{ pkgs, lib, config, ... }: {
  options.rice.desktop.vesktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.vesktop.enable {
    rice.desktop.wayland.hyprland.postConfig = ''
      bind = $mod CTRL, m, sendshortcut, CTRL SHIFT, m, class:(vesktop)
    '';

    home-manager.sharedModules = [{
      aquaris.persist = { ".config/vesktop" = { }; };
      programs.vesktop = {
        enable = true;
        vencord.useSystem = false;

        package = pkgs.vesktop.override {
          withTTS = false;
        };
      };
    }];
  };
}
