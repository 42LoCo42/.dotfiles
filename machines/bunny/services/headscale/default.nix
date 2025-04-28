{ pkgs, lib, config, ... }: {
  rice.caddy.cfg.headscale = ''
    import default
    reverse_proxy headscale:8080
  '';

  virtualisation.pnoc.headscale = {
    cmd = [ (lib.getExe' pkgs.headscale "headscale") "serve" ];

    volumes = [
      "headscale:/data"
      "${config.rice.subsDomain ./config.yaml}:/etc/headscale/config.yaml:ro"
    ];
  };
}
