{ pkgs, ... }: {
  rice.caddy = {
    cfg.chronometer = ''
      import default
      root * /srv/chronometer
      file_server
    '';

    volumes = [ "${pkgs.chronometer}:/srv/chronometer:ro" ];
  };
}
