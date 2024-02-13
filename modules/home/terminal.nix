{ pkgs, my-utils, ... }: {
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
  };
  users.users.default.shell = pkgs.zsh;
  environment.pathsToLink = [ "/share/zsh" ];

  home-manager.users.default = { lib, config, ... }: {
    home = let mybin = "${config.home.homeDirectory}/bin"; in {
      shellAliases = let flake = "path:$HOME/config"; in {
        cd = "z";
        g = "git";
        ip = "ip -c";
        mkdir = "mkdir -pv";
        neofetch = "hyfetch";
        vi = "vi -p";
        vim = "vim -p";
        yay = "nix flake update ${flake} && switch";
      };

      sessionPath = [ mybin ];
      sessionVariables = {
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };

      file = let dir = ./scripts; in (lib.trivial.pipe dir [
        builtins.readDir
        builtins.attrNames
        (map (name: {
          name = "${mybin}/${builtins.replaceStrings [".sh"] [""] name}";
          value = {
            executable = true;
            text = my-utils.substituteAll "${dir}/${name}" {
              brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
              fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
              mpc = "${pkgs.mpc-cli}/bin/mpc";
              nom = "${pkgs.nix-output-monitor}/bin/nom";
              nvd = "${pkgs.nvd}/bin/nvd";
              pulsemixer = "${pkgs.pulsemixer}/bin/pulsemixer";
            };
          };
        }))
        builtins.listToAttrs
      ]) // {
        Desktop.text = "";
        ".profile".text = ''
          . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
        '';
      };

      packages = with pkgs; [
        file
        git-crypt
        jq
        lsof
        man-pages
        man-pages-posix
        nil
        nix-output-monitor
        nixpkgs-fmt
        pciutils
        shellcheck
        tree
      ];
    };

    programs = {
      bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [
          batman
        ];
        config = {
          theme = "gruvbox-dark";
          pager = "less -fR";
        };
      };

      fzf.enable = true;

      zsh = let cache = "$HOME/.cache/zsh"; in {
        enable = true;
        enableAutosuggestions = true;
        syntaxHighlighting.enable = true;

        autocd = true;
        defaultKeymap = "emacs";
        history.path = "${cache}/history";

        initExtra = ''
          bindkey "" insert-cycledright
          bindkey "" insert-cycledleft

          bindkey "[1;3C" forward-word
          bindkey "[1;3D" backward-word

          # https://github.com/zsh-users/zsh-syntax-highlighting/issues/295#issuecomment-214581607
          zstyle ':bracketed-paste-magic' active-widgets '.self-*'
        '';

        plugins = [
          rec {
            name = "zsh-fzf-history-search";
            src = pkgs.fetchFromGitHub {
              owner = "joshskidmore";
              repo = name;
              rev = "d1aae98";
              hash = "sha256-4Dp2ehZLO83NhdBOKV0BhYFIvieaZPqiZZZtxsXWRaQ=";
            };
          }
        ];

        oh-my-zsh = {
          enable = true;
          extraConfig = ''ZSH_COMPDUMP="${cache}/completion"'';
          plugins = [
            "aliases"
            "bgnotify"
            # "common-aliases"
            "copybuffer"
            "copyfile"
            "copypath"
            "dircycle"
            "encode64"
            "extract"
            "fancy-ctrl-z"
            # "fbterm"
            "genpass"
            "git-auto-fetch"
            # "git-escape-magic"
            # "git-extras"
            "git-lfs"
            "git"
            "gitignore"
            "golang"
            "history"
            "isodate"
            "magic-enter"
            "perms"
            "qrcode"
            "ripgrep"
            "rsync"
            "rust"
            # "single-char"
            "sudo"
            "systemadmin"
            "systemd"
            # "thefuck"
            "tmux"
            # "tmuxinator"
            "universalarchive"
            "urltools"
          ];
        };
      };

      starship = {
        enable = true;
        settings = {
          custom.usepkgs = {
            command = "_usepkgs";
            when = ''[ -n "$IN_USE_SHELL" ]'';
          };
          character = {
            success_symbol = "[λ](bold green)";
            error_symbol = "[λ](bold red)";
          };
        };
      };

      lsd = {
        enable = true;
        enableAliases = true;
        settings = {
          sorting.dir-grouping = "first";
        };
      };

      gpg.enable = true;
      # man.generateCaches = true;
      ripgrep.enable = true;
      zoxide.enable = true;

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

      git = {
        enable = true;
        lfs.enable = true;
        difftastic = {
          enable = true;
          display = "side-by-side-show-both";
        };

        userName = "Eleonora";
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

          # coc = {
          #   enable = true;
          #   pluginConfig = builtins.readFile ./vim/coc.vim;
          # };

          plugins = with allPlugins; [
            airline
            ale
            autoclose
            gitgutter
            vim-nix
            {
              plugin = deoplete-nvim;
              config = ''
                call deoplete#enable()
                call deoplete#custom#option("auto_complete_delay", 0)
              '';
            }
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
    };
  };
}
