{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool int;
  cfg = config.rice.desktop.wayland.hypridle;
in
{
  options.rice.desktop.wayland.hypridle = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    timeouts = {
      lock = mkOption {
        type = int;
        default = 300;
      };

      dpms = mkOption {
        type = int;
        default = cfg.timeouts.lock + 5;
      };

      suspend = mkOption {
        type = int;
        default = 600;
      };
    };
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [{
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };

          listener = [
            {
              timeout = cfg.timeouts.lock;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = cfg.timeouts.dpms;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = cfg.timeouts.suspend;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
    }];
  };
}
