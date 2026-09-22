{ aquaris, lib, pkgs, ... }:
let
  app = "${pkgs.directorylister}:${dir}:ro";
  dir = "/srv/directory-lister";
in
{
  aquaris.users = lib.mkMerge [
    { inherit (aquaris.cfg.users) mel; }
    { mel.nopass = true; }
  ];

  home-manager.users.mel = {
    aquaris.persist = {
      "school" = { };
    };
  };

  nix.settings.allowed-users = [ "mel" ];

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
