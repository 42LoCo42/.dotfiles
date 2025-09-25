{ pkgs, lib, ... }: {
  topology.nodes.bunny-public.services.immich-public-proxy = {
    name = "Immich Public Proxy";
    icon = "services.ipp";
    info = "Shared album access from outside the VPN";
    details.url.text = "https://img.eleonora.gay";
  };

  rice.caddy.cfg.img = ''
    import default
    reverse_proxy immich-public-proxy:8080
  '';

  virtualisation.pnoc.immich-public-proxy = {
    cmd = [ (lib.getExe pkgs.immich-public-proxy) ];

    environment = {
      IPP_PORT = "8080";
      IPP_CONFIG = "${./config.json}";

      IMMICH_URL = "http://immich:8080";
    };
  };
}
