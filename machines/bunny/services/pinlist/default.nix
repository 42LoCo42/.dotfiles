{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.pinlist = {
    cmd = [ (lib.getExe pkgs.pinlist) "/data/pinlist.db" ];

    environment = {
      PINLIST_OIDC_ISSUER = "https://id.eleonora.gay";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/pinlist") ];

    volumes = [ "pinlist:/data" ];
  };
}
