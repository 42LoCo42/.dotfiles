{ pkgs, lib, ... }: {
  virtualisation.pnoc.pinlist = {
    cmd = [ (lib.getExe pkgs.pinlist) ];
    volumes = [ "pinlist:/db" ];
  };
}
