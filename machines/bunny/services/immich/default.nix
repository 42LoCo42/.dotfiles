{ pkgs, lib, config, ... }: {
  topology.nodes.bunny-private.services.immich = {
    name = "Immich";
    icon = "services.immich";
    info = "Personal photo gallery";
    details.url.text = "https://img.bunny";
  };

  virtualisation.pnoc = {
    immich = {
      path = with pkgs; [
        coreutils # immich starts ffmpeg with "nice 10"
        docker.docker-tini
        envsubst
        redis
      ];

      script = ''
        envsubst <${./config.yaml} > /tmp/config.yaml

        exec tini --           \
        ${config.rice.invfork} \
          redis-server         \
            --dir /data        \
            --bind 127.0.0.1   \
          -- ${lib.getExe pkgs.immich}
      '';

      environment = {
        DOMAIN = config.rice.domain;

        IMMICH_PORT = "8080";
        IMMICH_MEDIA_LOCATION = "/data";
        IMMICH_CONFIG_FILE = "/tmp/config.yaml";

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
