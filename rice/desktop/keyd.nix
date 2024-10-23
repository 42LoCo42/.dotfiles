{ lib, config, ... }: lib.mkIf config.rice.desktop {
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
}
