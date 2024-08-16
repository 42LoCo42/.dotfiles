{ pkgs, ... }: {
  aquaris.persist.dirs = [ "/var/cache/tuigreet" ];

  services.greetd = {
    enable = true;
    restart = true;
    vt = 7;
    settings.default_session.command =
      "${pkgs.greetd.tuigreet}/bin/tuigreet -tr --remember-user-session";
  };
}
