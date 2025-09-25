{ pkgs, lib, ... }: {
  virtualisation.pnoc.drasl = {
    cmd = [ (lib.getExe pkgs.drasl) "--config=${./config.toml}" ];
    secrets = [ "@machine/drasl:/key" ];
    volumes = [ "drasl:/data" ];
  };
}
