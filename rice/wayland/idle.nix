{ pkgs, lib, ... }: {
  home-manager.sharedModules = [{
    # TODO maybe switch back to swayidle?
    # hypridle doesn't really seem to work all that well...
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof swaylock || ${lib.getExe pkgs.swaylock-effects}";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 305;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 600;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  }];
}
