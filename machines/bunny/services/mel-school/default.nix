{ pkgs, ... }:
let
  app = "${pkgs.directorylister}:${dir}:ro";
  dir = "/srv/directory-lister";
in
(_: { }) {
  rice.caddy = {
    volumes = [ app ];

    cfg."school" = ''
      root ${dir}

      file_server /app/assets/*

      php_fastcgi mel-school:8080 {
        capture_stderr
        env FILES_PATH /media
        env TIMEZONE Europe/Berlin
      }
    '';
  };

  virtualisation.pnoc.mel-school = {
    path = with pkgs; [ php ];
    script = "exec php-fpm -F -y ${./php-fpm.conf}";

    extraOptions = [
      "--tmpfs=${dir}/app/cache"
    ];

    volumes = [
      app
      "/home/mel/school:/media:ro"
    ];
  };
}
