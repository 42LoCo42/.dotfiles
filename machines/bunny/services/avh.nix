{ pkgs, lib, ... }: {
  virtualisation.pnoc.avh = {
    cmd = [ (lib.getExe pkgs.avh) ];
    volumes = [
      "/persist/home/admin/avh/videos:/videos:ro"
    ];
  };
}
