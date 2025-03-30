{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.immich = {
    cmd = [ (lib.getExe pkgs.immich) ];

    environment = {
      IMMICH_PORT = "8080";
      IMMICH_MEDIA_LOCATION = "/data";

      DB_HOSTNAME = "postgres";
      DB_USERNAME = "immich";
      DB_DATABASE_NAME = "immich";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/immich") ];

    volumes = [
      "immich:/data"
      "/persist/home/admin/img:/media:ro"
    ];
  };
}
