{ pkgs, lib, config, aquaris, ... }:
let
  inherit (lib) getExe;
  inherit (aquaris.lib) subsF subsT;
in
{
  security.pam.services.swaylock = { };

  programs.hyprland.enable = true;

  home-manager.users.leonsch = hm: {
    home.packages = with pkgs; [
      qt5.qtwayland
      wl-clipboard
    ];

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
      # sometimes waybar starts before hyprland and then crashes
      # fix: just restart it until it works
      waybar = {
        Service.RestartSec = 1;
        Unit.StartLimitIntervalSec = 0;
      };

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
          { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock"; }
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

    programs = {
      foot = {
        enable = true;
        settings = {
          main.font = "monospace:size=10.5";
          colors = {
            alpha = "0.5";
            foreground = "ebdbb2";
            background = "282828";
            regular0 = "282828";
            regular1 = "cc241d";
            regular2 = "98971a";
            regular3 = "d79921";
            regular4 = "458588";
            regular5 = "b16286";
            regular6 = "689d6a";
            regular7 = "a89984";
            bright0 = "928374";
            bright1 = "fb4934";
            bright2 = "b8bb26";
            bright3 = "fabd2f";
            bright4 = "83a598";
            bright5 = "d3869b";
            bright6 = "8ec07c";
            bright7 = "ebdbb2";
          };
        };
      };

      swaylock = {
        enable = true;
        settings = {
          daemonize = true;
          image = "${config.rice.wallpaper}";
        };
      };

      waybar = {
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
            inherit (config.rice.temperature) critical-threshold hwmon-path;
            format-critical = "{temperatureC}°C {icon}";
            format = "{temperatureC}°C {icon}";
            format-icons = [ "" "" "" "" "" ];
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
    };

    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = subsT ./misc/hyprland.conf {
        early-config = config.rice.hypr-early-config;

        fuzzel = getExe pkgs.fuzzel;
        pulsemixer = getExe pkgs.pulsemixer;
        qalc = getExe pkgs.libqalculate;
        vesktop = getExe pkgs.vesktop;

        audio-helper = subsF {
          file = ./scripts/audio-helper.sh;
          func = pkgs.writeScript;
          subs = {
            pulsemixer = getExe pkgs.pulsemixer;
            mpc = getExe pkgs.mpc-cli;
          };
        };

        brightness-helper = subsF {
          file = ./scripts/brightness-helper.sh;
          func = pkgs.writeScript;
          subs = {
            brightnessctl = getExe pkgs.brightnessctl;
          };
        };

        dropdown = subsF {
          file = ./scripts/dropdown.sh;
          func = pkgs.writeScript;
        };

        prompt = subsF {
          file = ./scripts/prompt.sh;
          func = pkgs.writeScript;
          subs = {
            fuzzel = getExe pkgs.fuzzel;
          };
        };

        screenshot = subsF {
          file = ./scripts/screenshot.sh;
          func = pkgs.writeScript;
        };

        terminal = subsF {
          file = ./scripts/terminal.sh;
          func = pkgs.writeScript;
        };
      };
    };
  };
}
