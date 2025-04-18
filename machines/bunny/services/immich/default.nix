{ pkgs, lib, config, ... }: {
  nixpkgs.overlays = [
    (_: pkgs: {
      immich = pkgs.immich.overrideAttrs (new: _: {
        patches = [
          ./0001-fluent-ffmpeg-fix-stdoutRing-stderrRing-crash.patch
        ];

        patchFlags = [ "-p2" ];

        npmDeps = pkgs.fetchNpmDeps {
          name = "${new.pname}-${new.version}-npm-deps";
          inherit (new) src patches patchFlags;

          hash = "sha256-BLE05U9UIZzF9+PThTR88XumVm2uk30AW3MFGNlQvoM=";
        };
      });
    })
  ];

  virtualisation.pnoc = {
    immich = {
      cmd = [ (lib.getExe pkgs.immich) ];

      environment = {
        IMMICH_PORT = "8080";
        IMMICH_MEDIA_LOCATION = "/data";

        DB_HOSTNAME = "postgres";
        DB_USERNAME = "immich";
        DB_DATABASE_NAME = "immich";

        PATH = lib.makeBinPath (with pkgs; [
          coreutils # immich start ffmpeg with "nice 10"
        ]);
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

      extraOptions = [ "--tmpfs=/tmp" ];

      volumes = [ "immich-machine-learning:/data" ];
    };
  };
}
