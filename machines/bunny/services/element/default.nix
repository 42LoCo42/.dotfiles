{ pkgs, config, ... }: {
  topology.nodes.bunny-public.services.element = {
    name = "Element";
    icon = "services.element";
    info = "Matrix web client";
    details.url.text = "https://chat.${config.rice.domain}";
  };

  rice.caddy = {
    cfg.chat = ''
      import default
      root * /srv/element
      file_server
    '';

    volumes = [
      "${pkgs.element-web}:/srv/element:ro"
      "${config.rice.subsDomain ./config.json}:/srv/element/config.json:ro"
    ];
  };
}
