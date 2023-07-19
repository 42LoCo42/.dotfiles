{ self, config, pkgs, ... }: {
  system.stateVersion = "22.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
  nixpkgs.config.allowUnfree = true;

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
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      (nerdfonts.override {
        fonts = [ "Iosevka" ];
      })
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
    QT_STYLE_OVERRIDE = "Adwaita-Dark";
    PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig/";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
  };

  programs = {
    sway.enable = true;
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
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet -trc sway --remember-user-session";
        };
      };
    };

    tailscale.enable = true;

    tlp.enable = true;

    journald.extraConfig = "SystemMaxUse=1G";
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

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
    qt.style.name = "Adwaita-Dark";
    qt.style.package = pkgs.adwaita-qt;
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
        ccls
        clang-tools
        docker-client
        emacs
        feh
        file
        fuzzel
        gcc
        gocryptfs
        grim
        jq
        libnotify
        lsof
        man-pages
        man-pages-posix
        mpv
        nil
        nixpkgs-fmt
        nodePackages.bash-language-server
        pciutils
        pkg-config
        ripgrep
        shellcheck
        wl-clipboard
        xdg_utils

        (tor-browser-bundle-bin.override {
          useHardenedMalloc = false;
        })
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
          source = ./scripts/prompt.sh;
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

      flameshot.enable = true;

      swayidle = {
        enable = true;
        events = [
          { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock"; }
          { event = "before-sleep"; command = "${pkgs.systemd}/bin/loginctl lock-session"; }
        ];
        timeouts = [
          { timeout = 300; command = "${pkgs.systemd}/bin/loginctl lock-session"; }
          {
            timeout = 290;
            command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
            resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
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
            font = "monospace:size=7";
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
        style = ./misc/waybar.css;

        settings.mainBar = {
          position = "top";
          spacing = 2;
          ipc = true;

          modules-left = [
            "sway/workspaces"
          ];

          modules-center = [
            "sway/window"
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

          "sway/workspaces" = {
            all-outputs = true;
            format = "{icon}";
            format-icons = {
              "0" = "";
              "1" = "";
              "2" = "󰙯";
              "3" = "";
              "9" = "󰌆";
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

      firefox = {
        enable = true;
        # profiles."default" = {
        # };
      };
    };

    wayland.windowManager.sway =
      let
        term = "${pkgs.foot}/bin/foot";
        menu = "${pkgs.fuzzel}/bin/fuzzel";
        mod = "Mod4";
      in
      {
        enable = true;
        systemd.enable = true;
        config = {
          modifier = mod;

          focus.followMouse = true;

          window = {
            border = 1;
            titlebar = false;
            hideEdgeBorders = "both";
          };

          floating = {
            border = 1;
            titlebar = false;
            modifier = mod;
          };

          gaps = {
            inner = 2;
            smartGaps = true;
            smartBorders = "on";
          };

          input."type:keyboard" = {
            repeat_delay = "300";
            repeat_rate = "50";
            xkb_layout = "de";
            xkb_options = "ctrl:nocaps,compose:sclk";
          };

          input."type:touchpad" = {
            dwt = "enabled";
            tap = "enabled";
          };

          output."*" = {
            bg = "${self}/misc/wallpaper.jpg fill";
            mode = "1920x1080";
          };

          seat."*".hide_cursor = "when-typing enable";

          startup = [
            { command = "terminal"; }
            { command = "${pkgs.keepassxc}/bin/keepassxc"; }
          ];

          keybindings = {
            # programs
            "${mod}+Return" = "exec terminal";
            "${mod}+Shift+Return" = "exec ${term}";

            "${mod}+a" = "exec dropdown ${pkgs.libqalculate}/bin/qalc";
            "${mod}+Shift+a" = "exec dropdown ${pkgs.pulsemixer}/bin/pulsemixer";
            "${mod}+c" = "exec ${pkgs.webcord}/bin/webcord --enable-features=UseOzonePlatform --ozone-platform=wayland";
            "${mod}+d" = "exec ${menu}";
            "${mod}+e" = "exec ${pkgs.emacs}/bin/emacsclient -cne '(my/dashboard)'";
            "${mod}+i" = "exec ${term} -e ${pkgs.htop}/bin/htop";
            "${mod}+m" = "exec ${term} -e ${pkgs.ncmpcpp}/bin/ncmpcpp";
            "${mod}+n" = "exec ${term} -e ${pkgs.bash}/bin/bash -c 'sleep 0.1 && ${pkgs.networkmanager}/bin/nmtui'";
            "${mod}+w" = "exec ${pkgs.firefox}/bin/firefox";
            "${mod}+x" = "exec loginctl lock-session";

            # special
            "${mod}+Backspace" = "exec prompt Shutdown? poweroff";
            "${mod}+Shift+Backspace" = "exec prompt Reboot? reboot";
            "${mod}+Control+Backspace" = "exec prompt Suspend? systemctl suspend";
            "${mod}+Escape" = "exec prompt Logout? pkill sway";

            "Print" = ''
              exec \
              rm -f "$XDG_RUNTIME_DIR/screenshot.png" && \
              ${pkgs.flameshot}/bin/flameshot gui -p "$XDG_RUNTIME_DIR/screenshot.png" && \
              ${pkgs.wl-clipboard}/bin/wl-copy < "$XDG_RUNTIME_DIR/screenshot.png"
            '';

            # media keys
            "XF86AudioLowerVolume" = "exec audio-helper ${pkgs.pulsemixer} change -10";
            "XF86AudioRaiseVolume" = "exec audio-helper ${pkgs.pulsemixer} change +10";
            "XF86AudioMute" = "exec audio-helper ${pkgs.pulsemixer} mute";
            "XF86AudioMicMute" = "exec audio-helper ${pkgs.pulsemixer} micmute";
            "XF86AudioPlay" = "exec audio-helper ${pkgs.mpc-cli} play";
            "XF86AudioPrev" = "exec audio-helper ${pkgs.mpc-cli} prev";
            "XF86AudioNext" = "exec audio-helper ${pkgs.mpc-cli} next";
            "XF86MonBrightnessUp" = "exec brightness-helper ${pkgs.brightnessctl} +10";
            "XF86MonBrightnessDown" = "exec brightness-helper ${pkgs.brightnessctl} -10";

            # WM
            "${mod}+f" = "fullscreen";
            "${mod}+Shift+f" = "floating toggle";
            "${mod}+h" = "move scratchpad";
            "${mod}+Shift+h" = "scratchpad show";
            "${mod}+q" = "kill";

            "${mod}+Tab" = "workspace back_and_forth";
            "${mod}+space" = "focus mode_toggle";

            "${mod}+Left" = "focus left";
            "${mod}+Right" = "focus right";
            "${mod}+Up" = "focus up";
            "${mod}+Down" = "focus down";

            "${mod}+Shift+Left" = "move left";
            "${mod}+Shift+Right" = "move right";
            "${mod}+Shift+Up" = "move up";
            "${mod}+Shift+Down" = "move down";

            "${mod}+0" = "workspace number 0";
            "${mod}+1" = "workspace number 1";
            "${mod}+2" = "workspace number 2";
            "${mod}+3" = "workspace number 3";
            "${mod}+4" = "workspace number 4";
            "${mod}+5" = "workspace number 5";
            "${mod}+6" = "workspace number 6";
            "${mod}+7" = "workspace number 7";
            "${mod}+8" = "workspace number 8";
            "${mod}+9" = "workspace number 9";

            "${mod}+Shift+0" = "move container to workspace number 0";
            "${mod}+Shift+1" = "move container to workspace number 1";
            "${mod}+Shift+2" = "move container to workspace number 2";
            "${mod}+Shift+3" = "move container to workspace number 3";
            "${mod}+Shift+4" = "move container to workspace number 4";
            "${mod}+Shift+5" = "move container to workspace number 5";
            "${mod}+Shift+6" = "move container to workspace number 6";
            "${mod}+Shift+7" = "move container to workspace number 7";
            "${mod}+Shift+8" = "move container to workspace number 8";
            "${mod}+Shift+9" = "move container to workspace number 9";
          };

          workspaceAutoBackAndForth = true;

          bars = [ ];

          assigns = {
            "2" = [{ app_id = "WebCord"; }];
            "9" = [{ app_id = "org.keepassxc.KeePassXC"; }];
          };
        };
        extraConfig = ''
          set $term ${term}
          for_window [app_id="dropdown.*"] floating enable
          for_window [app_id="dropdown.*"] resize set 800 400
        '';
      };
  };
}
