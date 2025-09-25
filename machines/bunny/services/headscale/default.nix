{ pkgs, config, ... }: {
  topology.nodes.bunny-public.services.headscale = {
    name = "Headscale";
    icon = "services.headscale1";
    info = "Tailscale control plane";
    details.url.text = "https://headscale.eleonora.gay";
  };

  rice.caddy.cfg.headscale = ''
    import default
    reverse_proxy headscale:8080
  '';

  virtualisation.pnoc.headscale = {
    path = with pkgs; [ headscale ];

    script = "exec headscale serve";

    environmentFiles = [ (config.aquaris.secret "@machine/headscale") ];

    volumes = [
      "headscale:/data"
      "${config.rice.subsDomain ./config.yaml}:/etc/headscale/config.yaml:ro"
    ];
  };
}
