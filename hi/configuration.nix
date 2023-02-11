{ self, config, pkgs, home-manager, ... }: {
  imports = [
    ./hardware-configuration.nix
    home-manager.nixosModule
  ];

  system.stateVersion = "22.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;
  boot.kernelParams = [
    "vt.default_red=0x28,0xcc,0x98,0xd7,0x45,0xb1,0x68,0xa8,0x92,0xfb,0xb8,0xfa,0x83,0xd3,0x8e,0xeb"
    "vt.default_grn=0x28,0x24,0x97,0x99,0x85,0x62,0x9d,0x99,0x83,0x49,0xbb,0xbd,0xa5,0x86,0xc0,0xdb"
    "vt.default_blu=0x28,0x1d,0x1a,0x21,0x88,0x86,0x6a,0x84,0x74,0x34,0x26,0x2f,0x98,0x9b,0x7c,0xb2"
  ];

  networking.hostName = "nixos";
  networking.useNetworkd = true;
  systemd.network.wait-online.anyInterface = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1";
  };

  fonts = {
    fonts = with pkgs; [
      font-awesome
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

  programs = {
    sway.enable = true;
  };

  services = {
    openssh.enable = true;

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
  };

  systemd.mounts = [{
    what = "dotfiles";
    where = "/etc/nixos";

    after = [ "home.mount" ];
    wantedBy = [ "local-fs.target" ];

    type = "overlay";
    options = let
      dots = "${config.users.users.leonsch.home}/dotfiles";
    in "lowerdir=${dots}/lo,upperdir=${dots}/hi,workdir=${dots}/work";
  }];

  users.mutableUsers = false;
  users.users.leonsch = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$y$j9T$zjEgVmMSgM4dbXcVwITTT.$hLUP9jj1sE.hCf0DIAb8Nzlu40HiIwhYVkKmSWUgKv5";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql" ];
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.leonsch = { config, lib, pkgs, ... }: {
    home.stateVersion = "22.11";
    home.shellAliases = {
      cd = "mycd";
      fuck = "sudo $(history -p !!)";
      g = "git";
      ip = "ip -c";
      mkdir = "mkdir -pv";
      neofetch = "hyfetch";
      rl = "exec \\$SHELL -l";
      switch = "sudo mount -o remount /etc/nixos && sudo nixos-rebuild switch";
      upgrade = "cd ${config.home.homeDirectory}/dotfiles/hi && nix flake update";
      vi = "vi -p";
      vim = "vim -p";
    };

    xdg = {
      enable = true;
      userDirs.enable = true;

      configFile."fuzzel/fuzzel.ini".text = ''
        [main]
        terminal = foot -e
        font = monospace:size=20

        [colors]
        text           = ebdbb2ff
        background     = 282828e6
        selection-text = ebdbb2ff
        selection      = 000000ff
      '';
    };

    home.packages = with pkgs; [
      file
      fuzzel
      lsof
      mpv
      pulsemixer
    ];

    services = {
      mpd.enable = true;

      gpg-agent = {
        enable = true;
        pinentryFlavor = "qt";
      };
    };

    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [ "ignoredups" "ignorespace" ];
        shellOptions = [ "autocd" ];

        initExtra = ''
          source "${pkgs.complete-alias}/bin/complete_alias"
          while read -r name; do
              complete -F _complete_alias "$name"
          done < <(alias -p | sed 's|=.*||; s|.* ||')

          bind 'set enable-bracketed-paste on'
          bind 'set completion-ignore-case on'
          bind '"\t":menu-complete'

          mycd() {
              z "$@" && ls -A
          }
        '';
      };

      zoxide.enable = true;
      starship.enable = true;

      gpg.enable = true;

      git = {
        enable = true;
        delta.enable = true;

        userName = "Leon Schumacher";
        userEmail = "leonsch@protonmail.com";

        aliases = {
          a  = "add";
          c  = "commit";
          d  = "diff";
          l  = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %aN%C(reset)%C(bold yellow)%d%C(reset)' --all";
          pl = "pull";
          ps = "push";
          r  = "restore";
          s  = "status";
          sf = "submodule foreach";
        };

        signing = {
          key = "C743EE077172986F860FC0FE2F6FE1420970404C";
          signByDefault = true;
        };
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
        }  // (with config.lib.htop; leftMeters [
          (bar  "AllCPUs")
          (bar  "Memory")
          (bar  "DiskIO")
          (bar  "NetworkIO")
          (bar  "Load")
          (text "Clock")
        ]) // (with config.lib.htop; rightMeters [
          (text "AllCPUs")
          (text "Memory")
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

      neovim = let
        customPlugins = {
          autoclose = pkgs.vimUtils.buildVimPlugin {
            name = "autoclose";
            src = pkgs.fetchgit {
              url = "https://github.com/m4xshen/autoclose.nvim";
              rev = "389f7731f1fc508f5d5a6bdfef166901d8d1fc10";
              sha256 = "8IrJdoDXrNvIKuk9uIUragmBqKggf4b97c7XgZ0tYcM=";
            };
          };
        };
        allPlugins = pkgs.vimPlugins // customPlugins;
      in {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        coc = {
          enable = true;
          pluginConfig = ''
            inoremap <silent><expr> <TAB>
                  \ coc#pum#visible() ? coc#pum#next(1) :
                  \ CheckBackspace() ? "\<Tab>" :
                  \ coc#refresh()
            inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

            inoremap <silent><expr> <tab> coc#pum#visible() ? coc#pum#confirm()
                                          \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
          '';
        };

        plugins = with allPlugins; [
          airline
          autoclose
          gitgutter
          vim-nix
          { plugin = suda-vim; config = "let g:suda_smart_edit = 1"; }
        ];

        extraConfig = ''
          filetype plugin on
          syntax on
          set bg=light
          set go=a
          set mouse=a
          set hlsearch
          set ignorecase
          set smartcase
          set clipboard+=unnamedplus
          set nocompatible
          set encoding=utf-8
          set relativenumber
          set tabstop=4
          set shiftwidth=4
          set wildmode=longest,list,full
          set updatetime=100
          set colorcolumn=80
          highlight ColorColumn ctermbg=black
          highlight clear SignColumn
          set list
          set listchars=tab:→\ ,extends:»,precedes:«,trail:▒

          " Emacs moves
          inoremap <C-a> <Esc>I
          inoremap <C-b> <Left>
          inoremap <C-e> <Esc>A
          inoremap <C-f> <Right>
          inoremap <C-n> <Down>
          inoremap <C-p> <Up>
          nnoremap <C-b> <Left>
          nnoremap <C-f> <Right>
          vnoremap <C-b> <Left>
          vnoremap <C-f> <Right>

          " Exit with C-d
          cnoremap <C-d> <Esc>
          inoremap <C-d> <Esc>
          nnoremap <C-d> <Esc>
          vnoremap <C-d> <Esc>

          " Some nice things
          inoremap <C-s> <Esc>:w<CR>a
          inoremap <C-y> <Esc><C-r>a
          inoremap <C-z> <Esc>ua
          nnoremap <C-d> :q<CR>
          nnoremap <C-e> :Explore<CR>
          nnoremap <C-s> :w<CR>
          vnoremap <C-s> :sort<CR>

          " Tools for tabs
          inoremap <C-PageDown> <Esc>:tabnext<CR>
          inoremap <C-PageUp> <Esc>:tabprevious<CR>
          nnoremap <C-End> :tabnew<CR>:edit<Space>

          " Shortcutting split navigation, saving a keypress:
          map <C-h> <C-w>h
          map <C-j> <C-w>j
          map <C-k> <C-w>k
          map <C-l> <C-w>l

          " Replace all is aliased to S.
          nnoremap S :%s//g<Left><Left>

          " Remove trailing whitespace
          noremap <M-Space> :%s/\s\+$//e<CR>

          " Auto-completion
          inoremap /* /*<space><space>*/<Esc>2hi
          inoremap /** /**<space><space>*/<Esc>2hi
          inoremap // //<space>
          lua require("autoclose").setup({})

          " Exit terminal with Escape
          tnoremap <Esc> <C-\><C-n>

          " dark coc menu
          highlight Pmenu ctermfg=white ctermbg=black
        '';
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
            font = "monospace:size=11,Font Awesome, Font Awesome 6 Brands";
          };

          colors = {
            alpha      = "0.9";
            foreground = "ebdbb2";
            background = "282828";
            regular0   = "282828";
            regular1   = "cc241d";
            regular2   = "98971a";
            regular3   = "d79921";
            regular4   = "458588";
            regular5   = "b16286";
            regular6   = "689d6a";
            regular7   = "a89984";
            bright0    = "928374";
            bright1    = "fb4934";
            bright2    = "b8bb26";
            bright3    = "fabd2f";
            bright4    = "83a598";
            bright5    = "d3869b";
            bright6    = "8ec07c";
            bright7    = "ebdbb2";
          };
        };
      };

      waybar = {
        enable = true;
        settings.mainBar = {
          position = "top";
          spacing = 10;

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
              "2" = "";
              "3" = "";
              "9" = "";
            };
          };
        };
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod4";

        focus.followMouse = true;

        window = {
          border = 1;
          titlebar = false;
          hideEdgeBorders = "both";
        };

        floating = {
          border = 1;
          titlebar = false;
          modifier = config.wayland.windowManager.sway.config.modifier;
        };

        gaps = {
          inner = 2;
          smartGaps = true;
          smartBorders = "on";
        };

        input."type:keyboard" = {
          repeat_delay = "300";
          repeat_rate  = "50";
          xkb_layout   = "de";
          xkb_options  = "ctrl:nocaps,compose:sclk";
        };

        output."*" = {
          bg = "${self}/wallpaper.jpg fill";
          mode = "1920x1080";
        };

        seat."*".hide_cursor = "when-typing enable";

        startup = [
          { command = "foot"; }
        ];

        keybindings = let
          term = "${pkgs.foot}/bin/foot";
          menu = "${pkgs.fuzzel}/bin/fuzzel";
          mod  = config.wayland.windowManager.sway.config.modifier;
        in {
          # programs
          "${mod}+Return"       = "exec ${term}";
          "${mod}+Shift+Return" = "exec ${term}";

          "${mod}+Shift+a" = "exec ${term} -e ${pkgs.pulsemixer}/bin/pulsemixer";
          "${mod}+c"       = "exec ${pkgs.discord}/bin/discord";
          "${mod}+d"       = "exec ${menu}";
          "${mod}+e"       = "exec ${pkgs.emacs}/bin/emacs";
          "${mod}+i"       = "exec ${term} -e ${pkgs.htop}/bin/htop";
          "${mod}+m"       = "exec ${term} -e ${pkgs.ncmpcpp}/bin/ncmpcpp";
          "${mod}+w"       = "exec ${pkgs.firefox}/bin/firefox";

          # WM
          "${mod}+f"       = "fullscreen";
          "${mod}+Shift+f" = "floating toggle";
          "${mod}+h"       = "move scratchpad";
          "${mod}+Shift+h" = "scratchpad show";
          "${mod}+q"       = "kill";

          "${mod}+Tab"     = "workspace back_and_forth";
          "${mod}+space"   = "focus mode_toggle";

          "${mod}+Left"  = "focus left";
          "${mod}+Right" = "focus right";
          "${mod}+Up"    = "focus up";
          "${mod}+Down"  = "focus down";

          "${mod}+Shift+Left"  = "move left";
          "${mod}+Shift+Right" = "move right";
          "${mod}+Shift+Up"    = "move up";
          "${mod}+Shift+Down"  = "move down";

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

        bars = [{
          command = "${pkgs.waybar}/bin/waybar";
          position = "top";
        }];
      };
    };
  };
}
