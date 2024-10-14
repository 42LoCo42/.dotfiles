{ pkgs, config, ... }: {
  # persistent CPU temperature path
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="hwmon", ${config.rice.temp-select}, \
    RUN+="${pkgs.coreutils}/bin/ln -s /sys$devpath/temp1_input /dev/cpu_temp"
  '';
}
