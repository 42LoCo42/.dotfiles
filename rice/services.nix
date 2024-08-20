{ pkgs, config, lib, aquaris, ... }:
let
  inherit (lib) getExe;
  inherit (aquaris.lib) subsT;

  effect = pkgs.runCommandCC "effect.so" { } ''
    gcc -fPIC -shared ${./misc/effect.c} -o $out
  '';
in
{
  security.pam.services.swaylock = { };

  home-manager.sharedModules = [{
    xdg = {
      configFile = {
        "fuzzel/fuzzel.ini".text = subsT ./misc/fuzzel.ini {
          font-size = config.rice.fuzzel-font-size;
        };

        "swaylock/config".text = ''
          screenshots
          effect-scale=0.5
          effect-custom=${effect}
          effect-scale=2

          clock
          fade-in=0.5
        '';
      };

      dataFile."dbus-1/services/mako-path-fix.service".text =
        subsT ./misc/mako-path-fix.service {
          mako = getExe pkgs.mako;
        };
    };

    systemd.user.services = {
      sway-audio-idle-inhbit = {
        Install.WantedBy = [ "graphical-session.target" ];
        Service.ExecStart = getExe pkgs.sway-audio-idle-inhibit;
      };

      swaybg = {
        Install.WantedBy = [ "graphical-session.target" ];
        Service.ExecStart = "${getExe pkgs.swaybg} -i ${config.rice.wallpaper}";
      };
    };

    services = {
      wlsunset = {
        enable = true;
        latitude = "54.3075";
        longitude = "13.0830";
      };

      mako = {
        enable = true;
        defaultTimeout = 5000;
        layer = "overlay";
        extraConfig = ''
          [urgency=critical]
          default-timeout=0
          border-color=#d30706
          background-color=#f09b00
          text-color=#000000

          [app-name=flameshot]
          invisible=true
        '';
      };

      hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof swaylock || ${getExe pkgs.swaylock-effects}";
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
    };
  }];
}
