{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.headscale = {
    cmd = [ (lib.getExe' pkgs.headscale "headscale") "serve" ];
    ssl = true;
    volumes = [
      "headscale:/data"
      "${config.rice.subsDomain ./config.yaml}:/etc/headscale/config.yaml:ro"
    ];
  };
}
