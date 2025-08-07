{ pkgs, lib, config, ... }: {
  options.rice.desktop.greetd.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.greetd.enable {
    aquaris.persist.dirs = { "/var/cache/tuigreet" = { }; };

    services.greetd = {
      enable = true;
      restart = true;

      settings = {
        default_session.command =
          "${lib.getExe pkgs.greetd.tuigreet} -tr --remember-user-session";

        terminal.vt = lib.mkForce 7;
      };
    };
  };
}
