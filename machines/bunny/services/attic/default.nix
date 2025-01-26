{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.attic = {
    cmd = [ (lib.getExe pkgs.attic-server) ];
    environmentFiles = [ (config.aquaris.secret "machine/attic") ];
    volumes = [
      "attic:/data"
      "${config.rice.subsDomain ./config.toml}:/.config/attic/server.toml:ro"
    ];
  };
}
