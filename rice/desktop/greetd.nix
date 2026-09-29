{ config, lib, pkgs, ... }: {
  options.rice.desktop.greetd.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.greetd.enable {
    aquaris.persist.dirs = { "/var/cache/tuigreet" = { }; };

    services.greetd = {
      enable = true;
      restart = true;
      useTextGreeter = true;

      settings = {
        default_session = {
          user = "root";

          command =
            let
              sessions = config.services.displayManager.sessionData.desktops
                + "/share/wayland-sessions";
            in
            lib.join " " [
              (lib.getExe pkgs.kmscon)
              "--vt 1"
              "--hwaccel"
              "--oneshot"
              "--no-blink"
              "--no-mouse"
              "--no-switchvt"
              "--no-reset-env"
              "--xkb-layout de"
              "--xkb-repeat-delay 300"
              "--xkb-repeat-rate 25"
              "--palette custom"
              "--palette-background 40,40,40"    # 282828
              "--palette-foreground 235,219,178" # ebdbb2
              "--login"
              "--"
              (lib.getExe pkgs.tuigreet)
              "--asterisks"
              "--background matrix"
              "--time"
              "--remember"
              "--remember-user-session"
              "--sessions ${sessions}"
            ];
        };
      };
    };
  };
}
