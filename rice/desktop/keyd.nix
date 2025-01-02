{ lib, config, ... }: {
  options.rice.desktop.keyd.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.keyd.enable {
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings.main = {
          capslock = "overload(control, esc)";
          compose = "leftmeta";
        };
      };
    };
  };
}
