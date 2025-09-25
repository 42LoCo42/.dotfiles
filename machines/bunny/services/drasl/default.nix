{ pkgs, lib, ... }: {
  topology.nodes.bunny-private.services.drasl = {
    name = "Drasl";
    icon = "services.drasl";
    info = "Selfhosted Minecraft API server";
    details.url.text = "https://drasl.bunny";
  };

  virtualisation.pnoc.drasl = {
    cmd = [ (lib.getExe pkgs.drasl) "--config=${./config.toml}" ];
    secrets = [ "@machine/drasl:/key" ];
    volumes = [ "drasl:/data" ];
  };
}
