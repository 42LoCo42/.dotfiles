{ config, lib, pkgs, ... }: {
  options.rice.desktop.performance.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.performance.enable {
    aquaris.persist.dirs = {
      "/root/.cache/pandemonium" = { };
    };

    services = {
      scx = {
        enable = true;
        package = pkgs.scx.rustscheds;
        scheduler = "scx_pandemonium";
      };

      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
    };
  };
}
