{ pkgs, ... }: {
  services.greetd = {
    enable = true;
    restart = true;
    vt = 7;
    settings.default_session.command =
      "${pkgs.greetd.tuigreet}/bin/tuigreet -tr --remember-user-session";
  };

  systemd.tmpfiles.rules = [
    "d /var/cache/tuigreet 0755 greeter greeter"
  ];
}
