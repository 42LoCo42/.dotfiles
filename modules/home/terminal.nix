{ ... }: {
  home-manager.users.default = { pkgs, lib, config, ... }: {
    home = let mybin = "${config.home.homeDirectory}/bin"; in {
      shellAliases = let flake = "path:$HOME/config"; in {
        cd = "mycd";
        fuck = "sudo $(history -p !!)";
        g = "git";
        ip = "ip -c";
        mkdir = "mkdir -pv";
        neofetch = "hyfetch";
        switch = "sudo nixos-rebuild switch --flake ${flake} -L";
        yay = "nix flake update ${flake} && switch";
        vi = "vi -p";
        vim = "vim -p";
      };

      sessionPath = [ mybin ];

      file = let dir = ./scripts; in (lib.trivial.pipe dir [
        builtins.readDir
        builtins.attrNames
        (map (name: {
          name = "${mybin}/${builtins.replaceStrings [".sh"] [""] name}";
          value = {
            executable = true;
            source = pkgs.substituteAll {
              src = "${dir}/${name}";

              brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
              fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
              mpc = "${pkgs.mpc-cli}/bin/mpc";
              pulsemixer = "${pkgs.pulsemixer}/bin/pulsemixer";
            };
          };
        }))
        builtins.listToAttrs
      ]) // { Desktop.text = ""; };

      packages = with pkgs; [
        file
        git-crypt
        jq
        lsof
        man-pages
        man-pages-posix
        nil
        nixpkgs-fmt
        pciutils
        shellcheck
        tree
      ];
    };

    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [ "ignoredups" "ignorespace" ];
        shellOptions = [ "autocd" ];
        initExtra = builtins.readFile (pkgs.substituteAll {
          src = ./misc/bashrc;
          complete_alias = "${pkgs.complete-alias}/bin/complete_alias";
        });
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

      lsd = {
        enable = true;
        enableAliases = true;
        settings = {
          sorting.dir-grouping = "first";
        };
      };

      gpg.enable = true;
      man.generateCaches = true;
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
        delta = {
          enable = true;
          options.side-by-side = true;
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
    };
  };
}
