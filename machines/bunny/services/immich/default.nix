{ pkgs, lib, config, ... }: {
  virtualisation.pnoc = {
    immich = {
      path = with pkgs; [
        coreutils # immich start ffmpeg with "nice 10"
      ];

      cmd = config.rice.redis ++ [ (lib.getExe pkgs.immich) ];

      environment = {
        IMMICH_PORT = "8080";
        IMMICH_MEDIA_LOCATION = "/data";

        REDIS_HOSTNAME = "localhost";

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

    immich-machine-learning = {
      cmd = [ (lib.getExe pkgs.immich-machine-learning) ];

      environment = {
        MACHINE_LEARNING_CACHE_FOLDER = "/data";
        MPLCONFIGDIR = "/data/matplotlib";
      };

      volumes = [ "immich-machine-learning:/data" ];
    };
  };
}
