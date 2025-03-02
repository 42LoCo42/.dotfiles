{ pkgs, config, lib, ... }: {
  options.rice.desktop.mail = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    protonmail = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf config.rice.desktop.mail.enable (lib.mkMerge [
    {
      home-manager.sharedModules = [{
        aquaris.persist = {
          ".cache/thunderbird" = { };
          ".thunderbird" = { };
        };

        home.packages = with pkgs; [ thunderbird ];
      }];
    }

    (lib.mkIf config.rice.desktop.mail.protonmail {
      home-manager.sharedModules = [{
        aquaris.persist = {
          ".config/ferroxide" = { };
        };

        home.packages = with pkgs; [ ferroxide ];

        systemd.user.services.ferroxide = {
          Unit = {
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };

          Install.WantedBy = [ "default.target" ];

          Service = {
            Type = "simple";
            ExecStart = builtins.replaceStrings [ "\n" ] [ "" ] ''
              ${lib.getExe pkgs.ferroxide}
                --disable-caldav
                --disable-carddav
                --imap-port 65143
                --smtp-port 65025
                serve
            '';
          };
        };
      }];
    })
  ]);
}
