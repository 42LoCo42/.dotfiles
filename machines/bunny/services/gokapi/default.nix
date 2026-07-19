{ config, pkgs, ... }: {
  topology.nodes.bunny-public.services.gokapi = {
    name = "Gokapi";
    icon = "misc.files";
    info = "Simple filesharing service";
    details.url.text = "https://fs.${config.rice.domain}";
  };

  rice.caddy.cfg.fs = ''
    import default
    reverse_proxy gokapi:8080
  '';

  virtualisation.pnoc.gokapi = {
    path = with pkgs; [
      envsubst
      gokapi
      pwgen
    ];

    script = ''
      envsubst < ${./config.json} > /tmp/config.json
      gokapi      -c /tmp/config.json --deployment-password "$(pwgen -s 64 1)"
      exec gokapi -c /tmp/config.json
    '';

    environment = {
      DOMAIN = config.rice.domain;
      GOKAPI_ENABLE_HOTLINK_VIDEOS = "true";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/gokapi") ];

    volumes = [ "gokapi:/data" ];
  };
}
