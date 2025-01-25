{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.headscale = {
    cmd = [ (lib.getExe' pkgs.headscale "headscale") "serve" ];
    volumes = [
      "headscale:/data"
      "${config.rice.subsDomain ./config.yaml}:/etc/headscale/config.yaml:ro"
    ];
  };
}
