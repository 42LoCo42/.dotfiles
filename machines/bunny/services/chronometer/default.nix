{ pkgs, ... }: {
  topology.nodes.bunny-public.services.chronometer = {
    name = "Chronometer";
    icon = "misc.clock";
    info = "The Chronometer of Endless Whimsy!";
    details.url.text = "https://chronometer.eleonora.gay";
  };

  rice.caddy = {
    cfg.chronometer = ''
      import default
      root * /srv/chronometer
      file_server
    '';

    volumes = [ "${pkgs.chronometer}:/srv/chronometer:ro" ];
  };
}
