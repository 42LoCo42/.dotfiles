{ pkgs, lib, ... }: {
  virtualisation.pnoc.redis = {
    cmd = [ (lib.getExe' pkgs.redis "redis-server") "--protected-mode" "no" ];
    volumes = [ "redis:/data" ];
    workdir = "/data";
  };
}
