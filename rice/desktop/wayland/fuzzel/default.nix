{ aquaris, config, lib, ... }: {
  options.rice.desktop.wayland.fuzzel = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    fontSize = lib.mkOption {
      type = lib.types.int;
    };
  };

  config = lib.mkIf config.rice.desktop.wayland.fuzzel.enable {
    home-manager.sharedModules = [{
      xdg.configFile."fuzzel/fuzzel.ini".text = aquaris.lib.subsT ./config.ini {
        inherit (config.rice.desktop.wayland.fuzzel) fontSize;
      };
    }];
  };
}
