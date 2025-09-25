{ pkgs, lib, config, ... }: {
  topology.nodes.bunny-private.services.pinlist = {
    name = "Pinlist";
    icon = "services.pinlist";
    info = "Private pinboard for interesting things";
    details.url.text = "https://pin.bunny";
  };

  virtualisation.pnoc.pinlist = {
    cmd = [ (lib.getExe pkgs.pinlist) "/data/pinlist.db" ];

    environment = {
      PINLIST_OIDC_ISSUER = "https://id.eleonora.gay";
      PINLIST_OIDC_REDIRECT = "https://pin.bunny";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/pinlist") ];

    volumes = [ "pinlist:/data" ];
  };
}
