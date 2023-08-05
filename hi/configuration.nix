{ config, pkgs, ... }: {
  system.stateVersion = "22.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      nerdfonts = prev.nerdfonts.override {
        fonts = [ "Iosevka" ];
      };

      tor-browser-bundle-bin = prev.tor-browser-bundle-bin.override {
        useHardenedMalloc = false;
      };

      # xdg-desktop-portal = prev.xdg-desktop-portal.overrideAttrs (old: rec {
      #   version = "1.14.6";

      #   src = pkgs.fetchFromGitHub {
      #     owner = "flatpak";
      #     repo = "xdg-desktop-portal";
      #     rev = version;
      #     hash = "sha256-MD1zjKDWwvVTui0nYPgvVjX48DaHWcP7Q10vDrNKYz0=";
      #   };
      # });

      waybar = prev.waybar.overrideAttrs (old: {
        mesonFlags = old.mesonFlags ++ [ "-Dexperimental=true " ];
      });
    })
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;
  boot.kernelParams = [
    "vt.default_red=0x28,0xcc,0x98,0xd7,0x45,0xb1,0x68,0xa8,0x92,0xfb,0xb8,0xfa,0x83,0xd3,0x8e,0xeb"
    "vt.default_grn=0x28,0x24,0x97,0x99,0x85,0x62,0x9d,0x99,0x83,0x49,0xbb,0xbd,0xa5,0x86,0xc0,0xdb"
    "vt.default_blu=0x28,0x1d,0x1a,0x21,0x88,0x86,0x6a,0x84,0x74,0x34,0x26,0x2f,0x98,0x9b,0x7c,0xb2"
  ];

  zramSwap.enable = true;

  security.pam.u2f.cue = true;
  security.pam.services = {
    sudo.u2fAuth = true;
    swaylock.text = "auth include login";
  };

  networking = {
    hostName = "akyuro";
    useNetworkd = true;
    localCommands = "${pkgs.util-linux}/bin/rfkill unblock wifi";
    networkmanager.enable = true;
    firewall.checkReversePath = "loose"; # for tailscale exit node
  };

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1";
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      nerdfonts
    ];

    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "IosevkaNerdFont" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };

  environment.variables = {
    GTK_THEME = "Adwaita:dark";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs = {
    hyprland.enable = true;
    command-not-found.enable = false;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    greetd = {
      enable = true;
      restart = true;
      vt = 7;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet -trc Hyprland --remember-user-session";
        };
      };
    };

    tailscale.enable = true;

    tlp.enable = true;

    journald.extraConfig = "SystemMaxUse=1G";
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
  };

  systemd.extraConfig = "DefaultTimeoutStopSec=10s";
  systemd.network.wait-online.enable = false;
  systemd.services."NetworkManager-wait-online".enable = false;
  systemd.mounts = [{
    what = "dotfiles";
    where = "/etc/nixos";

    after = [ "home.mount" ];
    wantedBy = [ "local-fs.target" ];

    type = "overlay";
    options =
      let
        dots = "${config.users.users.leonsch.home}/dotfiles";
      in
      "lowerdir=${dots}/lo,upperdir=${dots}/hi,workdir=${dots}/work";
  }];
  systemd.tmpfiles.rules = [
    "d /var/cache/tuigreet 0755 greeter greeter"
  ];

  users.mutableUsers = false;
  users.users.leonsch = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    hashedPassword = "$y$j9T$zjEgVmMSgM4dbXcVwITTT.$hLUP9jj1sE.hCf0DIAb8Nzlu40HiIwhYVkKmSWUgKv5";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql" ];
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.leonsch = { config, lib, pkgs, ... }: {
    qt = {
      enable = true;
      platformTheme = "gtk";
      style.name = "Adwaita-Dark";
    };

    home = let mybin = "${config.home.homeDirectory}/bin"; in {
      stateVersion = "22.11";

      shellAliases = {
        cd = "mycd";
        fuck = "sudo $(history -p !!)";
        g = "git";
        ip = "ip -c";
        mkdir = "mkdir -pv";
        neofetch = "hyfetch";
        rl = "exec \\$SHELL -l";
        switch = "sudo mount -o remount /etc/nixos && sudo nixos-rebuild switch";
        yay = "cd ${config.home.homeDirectory}/dotfiles/hi && nix flake update && switch";
        vi = "vi -p";
        vim = "vim -p";
      };

      packages = with pkgs; [
        clang-tools
        docker-client
        emacs
        feh
        file
        gocryptfs
        jq
        keepassxc
        libnotify
        lsof
        man-pages
        man-pages-posix
        mpv
        nil
        nixpkgs-fmt
        nodePackages.bash-language-server
        pciutils
        ripgrep
        shellcheck
        tor-browser-bundle-bin
        wl-clipboard
        xdg_utils
      ];

      sessionPath = [ mybin ];

      file = {
        "Desktop".text = "";

        "${mybin}/audio-helper" = {
          executable = true;
          source = ./scripts/audio-helper.sh;
        };

        "${mybin}/brightness-helper" = {
          executable = true;
          source = ./scripts/brightness-helper.sh;
        };

        "${mybin}/dropdown" = {
          executable = true;
          source = ./scripts/dropdown.sh;
        };

        "${mybin}/new-pane-here" = {
          executable = true;
          source = ./scripts/new-pane-here.sh;
        };

        "${mybin}/prompt" = {
          executable = true;
          source = pkgs.substituteAll {
            src = ./scripts/prompt.sh;
            fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
          };
        };

        "${mybin}/terminal" = {
          executable = true;
          source = ./scripts/terminal.sh;
        };
      };
    };

    xdg = {
      enable = true;
      userDirs.enable = true;

      configFile."fuzzel/fuzzel.ini".source = ./misc/fuzzel.ini;
      dataFile."dbus-1/services/mako-path-fix.service".text = ''
        [D-BUS Service]
        Name=org.freedesktop.Notifications
        Exec=/usr/bin/env PATH=/run/current-system/sw/bin ${pkgs.mako}/bin/mako
      '';
    };

    systemd.user.services =
      let
        Install.WantedBy = [ "default.target" ];
        Environment = let user = config.home.username; in
          "PATH=/run/wrappers/bin:/home/${user}/.nix-profile/bin:/etc/profiles/per-user/${user}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
      in
      {
        emacs = {
          inherit Install;
          # Unit.Requires = [ "async-git-clone.service" ];
          Service = {
            inherit Environment;
            ExecStart = "${pkgs.emacs}/bin/emacs --fg-daemon";
          };
        };

        # async-git-clone = {
        #   inherit Install;
        #   Unit = {
        #     StartLimitIntervalSec = "1d";
        #     StartLimitBurst = 5;
        #   };
        #   Service = {
        #     inherit Environment;
        #     ExecStart = "${pkgs.bash}/bin/bash " + ./async-git-clone.sh;
        #     Restart = "on-failure";
        #     RestartSec = 10;
        #   };
        # };
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
      };

      mpd = {
        enable = true;
        extraConfig = ''
          audio_output {
              type "pipewire"
              name "pipewire"
          }
        '';
      };

      gpg-agent = {
        enable = true;
        pinentryFlavor = "qt";
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
      bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [ "ignoredups" "ignorespace" ];
        shellOptions = [ "autocd" ];
        initExtra = builtins.replaceStrings
          [ "@{pkgs.complete-alias}" ]
          [ "${pkgs.complete-alias}" ]
          (builtins.readFile ./misc/bashrc);
      };

      starship = {
        enable = true;
        settings = {
          character = {
            success_symbol = "[λ](bold green)";
            error_symbol = "[λ](bold red)";
          };
        };
      };

      zoxide.enable = true;

      man.generateCaches = true;

      zathura.enable = true;

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      tmux = {
        enable = true;

        clock24 = true;
        escapeTime = 300;
        historyLimit = 10000;
        keyMode = "vi";
        mouse = true;
        shortcut = "w";
        terminal = "tmux-256color";

        extraConfig = builtins.readFile ./misc/tmux.conf;
      };

      firefox.enable = true;

      yt-dlp.enable = true;

      gpg.enable = true;

      git = {
        enable = true;
        lfs.enable = true;
        delta = {
          enable = true;
          options = {
            side-by-side = true;
          };
        };

        userName = "Leon Schumacher";
        userEmail = "leonsch@protonmail.com";

        aliases = {
          a = "add";
          c = "commit";
          d = "diff";
          l = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %aN%C(reset)%C(bold yellow)%d%C(reset)' --all";
          pl = "pull";
          ps = "push";
          r = "restore";
          s = "status";
          sf = "submodule foreach";
        };

        signing = {
          key = "C743EE077172986F860FC0FE2F6FE1420970404C";
          signByDefault = true;
        };

        extraConfig.pull.rebase = false;
      };

      htop = {
        enable = true;
        settings = {
          account_guest_in_cpu_meter = 1;
          color_scheme = 5;
          hide_userland_threads = 1;
          highlight_base_name = 1;
          highlight_changes = 1;
          highlight_changes_delay_secs = 1;
          show_cpu_frequency = 1;
          show_cpu_temperature = 1;
          show_merged_command = 1;
          show_program_path = 0;
          show_thread_names = 1;
          tree_view = 1;

          tree_sort_key = config.lib.htop.fields.COMM;
          tree_sort_direction = 1;

          fields = with config.lib.htop.fields; [
            PID
            USER
            STATE
            NICE
            PERCENT_CPU
            PERCENT_MEM
            M_RESIDENT
            OOM
            TIME
            COMM
          ];
        } // (with config.lib.htop; leftMeters [
          (bar "AllCPUs")
          (bar "Memory")
          (bar "Zram")
          (bar "DiskIO")
          (bar "NetworkIO")
          (bar "Load")
          (text "Clock")
        ]) // (with config.lib.htop; rightMeters [
          (text "AllCPUs")
          (text "Memory")
          (text "Zram")
          (text "DiskIO")
          (text "NetworkIO")
          (text "LoadAverage")
          (text "Uptime")
        ]);
      };

      lsd = {
        enable = true;
        enableAliases = true;
        settings = {
          sorting.dir-grouping = "first";
        };
      };

      neovim =
        let
          customPlugins = {
            autoclose = pkgs.vimUtils.buildVimPlugin {
              name = "autoclose";
              src = pkgs.fetchgit {
                url = "https://github.com/m4xshen/autoclose.nvim";
                rev = "c4db42ffc0edbd244502be951c142df0c8a7e582";
                sha256 = "hxizkj9pIEvdps4f1hl0eGt0pNVHd2ejMlTQNeis404=";
              };
            };
          };
          allPlugins = pkgs.vimPlugins // customPlugins;
        in
        {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;

          coc = {
            enable = true;
            pluginConfig = builtins.readFile ./vim/coc.vim;
          };

          plugins = with allPlugins; [
            airline
            autoclose
            gitgutter
            vim-nix
            { plugin = suda-vim; config = "let g:suda_smart_edit = 1"; }
          ];

          extraConfig = builtins.readFile ./vim/init.vim;
        };

      hyfetch = {
        enable = true;
        settings = {
          preset = "rainbow";
          mode = "rgb";
          color_align = {
            mode = "horizontal";
          };
        };
      };

      foot = {
        enable = true;
        settings = {
          main = {
            font = "monospace:size=10.5";
          };

          colors = {
            alpha = "0.9";
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

      swaylock.settings = {
        daemonize = true;
        image = builtins.toString ./misc/wallpaper.jpg;
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
            "wlr/workspaces"
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

          "wlr/workspaces" = {
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
            format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}%  ";
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

          tray = {
            spacing = 10;
          };
        };
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = builtins.readFile
        (pkgs.substituteAll {
          src = ./misc/hyprland.conf;

          brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
          firefox = "${pkgs.firefox}/bin/firefox";
          fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
          grim = "${pkgs.grim}/bin/grim";
          mpc = "${pkgs.mpc-cli}/bin/mpc";
          ncmpcpp = "${pkgs.ncmpcpp}/bin/ncmpcpp";
          pulsemixer = "${pkgs.pulsemixer}/bin/pulsemixer";
          qalc = "${pkgs.libqalculate}/bin/qalc";
          slurp = "${pkgs.slurp}/bin/slurp";
          swappy = "${pkgs.swappy}/bin/swappy";
          webcord = "${pkgs.webcord}/bin/webcord";
        });
    };
  };
}
