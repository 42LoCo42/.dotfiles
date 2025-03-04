{ pkgs, lib, config, ... }: {
  options.rice.desktop.udev = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    cpuTemperatureSelector = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf config.rice.desktop.udev.enable {
    # persistent CPU temperature path
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="hwmon", ${config.rice.desktop.udev.cpuTemperatureSelector}, \
      RUN+="${pkgs.coreutils}/bin/ln -sf /sys$devpath/temp1_input /dev/cpu_temp"

      ACTION=="add", KERNEL=="card*", SUBSYSTEM=="drm", DRIVERS=="amdgpu", \
      RUN+="${pkgs.coreutils}/bin/ln -sf $devnode /dev/dri/amd"

      ACTION=="add", KERNEL=="card*", SUBSYSTEM=="drm", DRIVERS=="i915", \
      RUN+="${pkgs.coreutils}/bin/ln -sf $devnode /dev/dri/intel"

      ACTION=="add", KERNEL=="card*", SUBSYSTEM=="drm", DRIVERS=="nvidia", \
      RUN+="${pkgs.coreutils}/bin/ln -sf $devnode /dev/dri/nvidia"
    '';
  };
}
