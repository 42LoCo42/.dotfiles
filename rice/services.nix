{ pkgs, config, lib, aquaris, ... }:
let
  inherit (lib) getExe;
  inherit (aquaris.lib) subsT;
in
{
  security.pam.services.swaylock = { };

  home-manager.sharedModules = [{
    xdg = {
      configFile."fuzzel/fuzzel.ini".text = subsT ./misc/fuzzel.ini {
        font-size = config.rice.fuzzel-font-size;
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

      swayidle = {
        enable = true;
        systemdTarget = "hyprland-session.target";
        events = [
          { event = "lock"; command = getExe pkgs.swaylock; }
          { event = "before-sleep"; command = "${pkgs.systemd}/bin/loginctl lock-session"; }
        ];
        timeouts = [
          { timeout = 300; command = "${pkgs.systemd}/bin/loginctl lock-session"; }
          {
            timeout = 290;
            command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          }
        ];
      };
    };

    programs.swaylock = {
      enable = true;
      settings = {
        daemonize = true;
        image = "${config.rice.wallpaper}";
      };
    };
  }];
}
