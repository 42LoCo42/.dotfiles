{ config, lib, pkgs, ... }: {
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

      KERNEL=="card*", SUBSYSTEM=="drm", \
      DRIVERS=="amdgpu", SYMLINK+="dri/by-type/amd"

      KERNEL=="card*", SUBSYSTEM=="drm", \
      DRIVERS=="i915", SYMLINK+="dri/by-type/intel"

      KERNEL=="card*", SUBSYSTEM=="drm", \
      DRIVERS=="nvidia", SYMLINK+="dri/by-type/nvidia"
    '';
  };
}
