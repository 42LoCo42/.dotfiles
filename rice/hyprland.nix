{ self, pkgs, lib, my-utils, ... }: {
  security.pam.services.swaylock = { };

  programs.hyprland.enable = true;

  home-manager.users.leonsch = hm: {
    home.packages = with pkgs; [
      qt5.qtwayland
      wl-clipboard
    ];

    xdg = {
      configFile."fuzzel/fuzzel.ini".source = ./misc/fuzzel.ini;
      dataFile."dbus-1/services/mako-path-fix.service".text =
        my-utils.subsT ./misc/mako-path-fix.service {
          mako = lib.getExe pkgs.mako;
        };
    };

    # sometimes waybar starts before hyprland and then crashes
    # fix: just restart it until it works
    systemd.user.services.waybar = {
      Service.RestartSec = 1;
      Unit.StartLimitIntervalSec = 0;
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
        package = self.inputs.obscura.packages.${pkgs.system}.foot-transparent;
        settings = {
          main.font = "monospace:size=10.5";
          # key-bindings.spawn-terminal = "none";

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
          image = "${./misc/wallpaper.png}";
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
          };

          temperature = {
            hwmon-path = "/sys/class/hwmon/hwmon4/temp1_input";
            critical-threshold = 60;
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
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
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
      extraConfig = my-utils.subsT ./misc/hyprland.conf {
        fuzzel = lib.getExe pkgs.fuzzel;
        pulsemixer = lib.getExe pkgs.pulsemixer;
        qalc = lib.getExe pkgs.libqalculate;
        sway-audio-idle-inhibit = lib.getExe self.inputs.obscura.packages.${pkgs.system}.SwayAudioIdleInhibit;
        swaybg = lib.getExe pkgs.swaybg;
        wallpaper = ./misc/wallpaper.png;
        vesktop = lib.getExe (pkgs.vesktop.override { withSystemVencord = false; });

        audio-helper = my-utils.subsF {
          file = ./scripts/audio-helper.sh;
          func = pkgs.writeScript;
          subs = {
            pulsemixer = lib.getExe pkgs.pulsemixer;
            mpc = lib.getExe pkgs.mpc-cli;
          };
        };

        brightness-helper = my-utils.subsF {
          file = ./scripts/brightness-helper.sh;
          func = pkgs.writeScript;
          subs = {
            brightnessctl = lib.getExe pkgs.brightnessctl;
          };
        };

        dropdown = my-utils.subsF {
          file = ./scripts/dropdown.sh;
          func = pkgs.writeScript;
        };

        prompt = my-utils.subsF {
          file = ./scripts/prompt.sh;
          func = pkgs.writeScript;
          subs = {
            fuzzel = lib.getExe pkgs.fuzzel;
          };
        };

        screenshot = my-utils.subsF {
          file = ./scripts/screenshot.sh;
          func = pkgs.writeScript;
        };

        terminal = my-utils.subsF {
          file = ./scripts/terminal.sh;
          func = pkgs.writeScript;
        };
      };
    };
  };
}
