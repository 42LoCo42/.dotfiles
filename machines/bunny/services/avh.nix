{ lib, config, ... }: {
  virtualisation.pnoc.avh = {
    cmd = [ (lib.getExe config.rice.obscura.avh) ];
    volumes = [
      "/persist/home/admin/avh/videos:/videos:ro"
    ];
  };
}
