{ pkgs, config, lib, ... }:
let
  inherit (lib) getExe;
in
{
  home-manager.sharedModules = [{
    # sometimes waybar starts before hyprland and then crashes
    # fix: just restart it until it works
    systemd.user.services.waybar = {
      Service.RestartSec = 1;
      Unit.StartLimitIntervalSec = 0;
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      systemd.target = "hyprland-session.target";
      style = ./misc/waybar.css;

      settings.mainBar = {
        layer = "top";
        position = "top";
        spacing = 2;
        ipc = true;

        modules-left = [
          "hyprland/workspaces"
        ];

        modules-center = [
          "hyprland/window"
        ];

        modules-right = [
          "custom/weather"
          "mpd"
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "disk"
          "temperature"
          "backlight"
          "battery"
          "clock"
          "idle_inhibitor"
          "tray"
        ];

        "hyprland/workspaces" = {
          all-outputs = true;
          sort-by-number = true;
          format = "{icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "󰙯";
            "4" = "";
            "5" = "4";
            "6" = "5";
            "7" = "6";
            "8" = "7";
            "9" = "8";
            "10" = "󰌆";
          };
        };

        "custom/weather" = {
          format = "{}°";
          tooltip = true;
          interval = 3600;
          exec = "${getExe pkgs.wttrbar}";
          return-type = "json";
        };

        mpd = {
          format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{album}: {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}%  ";
          format-stopped = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped 󰝛 ";
          format-disconnected = "Disconnected 󰀦 ";
          unknown-tag = "";
          interval = 2;
          consume-icons = {
            on = " ";
          };
          random-icons = {
            on = " ";
          };
          repeat-icons = {
            on = "󰑖 ";
          };
          single-icons = {
            on = "󰑘 ";
          };
          state-icons = {
            playing = " ";
            paused = " ";
          };
          tooltip-format = "MPD (connected)";
          tooltip-format-disconnected = "MPD (disconnected)";
        };

        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = "  {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "󰜟";
            headset = "󰋎";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "󰕾" "" ];
          };
        };

        network = {
          format-wifi = "{essid} ({signalStrength}%)  ";
          format-ethernet = "{ipaddr}/{cidr} 󰈀 ";
          tooltip-format = "{ifname} via {gwaddr} 󰈀 ";
          format-linked = "{ifname} (No IP) 󰈀 ";
          format-disconnected = "Disconnected 󰀦 ";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };

        cpu = {
          format = "{usage}%  ";
          tooltip = false;
        };

        memory = {
          format = "{}%  ";
        };

        disk = {
          format = "{percentage_used}% 󰋊 ";
          path = config.rice.disk-path;
        };

        temperature = {
          critical-threshold = config.rice.temp-warn;
          format = "{temperatureC}°C {icon}";
          format-critical = "{temperatureC}°C {icon}";
          format-icons = [ "" "" "" "" "" ];
          hwmon-path = "/dev/cpu_temp";
        };

        backlight = {
          device = "amdgpu";
          format = "{percent}% {icon}";
          format-icons = [ "󰃚 " "󰃛 " "󰃜 " "󰃝 " "󰃞 " "󰃟 " "󰃠 " ];
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };

          format = "{time} {capacity}% {icon}";
          format-charging = "{time} {capacity}% {icon} 󱐋";
          format-plugged = "{capacity}%  ";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        clock = {
          format = "{:%T}";
          interval = 1;
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        idle_inhibitor = {
          format = "{icon} ";
          format-icons = {
            activated = "󰈈";
            deactivated = "󰈉";
          };
        };

        tray.spacing = 10;
      };
    };
  }];
}
