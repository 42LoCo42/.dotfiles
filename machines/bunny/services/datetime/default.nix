{ pkgs, ... }: {
  topology.nodes.bunny-public.services.datetime = {
    name = "Datetime";
    icon = "misc.clock";
    info = "What Datetime is it right now?";
    details.url.text = "https://datetime.eleonora.gay";
  };

  rice.caddy = {
    cfg.datetime = ''
      import default
      root * /srv/datetime
      file_server
    '';

    volumes = [ "${pkgs.datetime}/app:/srv/datetime:ro" ];
  };
}
