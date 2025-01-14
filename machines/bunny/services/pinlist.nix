{ lib, config, ... }: {
  virtualisation.pnoc.pinlist = {
    cmd = [ (lib.getExe config.rice.obscura.pinlist) ];
    volumes = [ "pinlist:/db" ];
  };
}
