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
      scx-loader = {
        enable = true;
        config.default_sched = "scx_pandemonium";
      };

      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };

      auto-cpufreq = {
        enable = true;
      };

      thermald = {
        enable = true;
        debug = true;
      };
    };
  };
}
