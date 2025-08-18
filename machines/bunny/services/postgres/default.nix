{ pkgs, lib, ... }: {
  virtualisation.pnoc.postgres =
    let
      postgres = pkgs.postgresql_17.withPackages (p: with p; [
        pgvector # required by vectorchord
        vectorchord
      ]);

      run = pkgs.writeShellApplication {
        name = "postgres";

        runtimeInputs = with pkgs; [
          coreutils
          less
          postgres
        ];

        text = ''
          if [ ! -e /data/PG_VERSION ]; then initdb -E UTF8 /data; fi
          cp -v /pg_hba.conf /postgresql.conf /data
          exec postgres -D /data
        '';
      };
    in
    {
      cmd = [ (lib.getExe run) ];

      environment.PATH = lib.makeBinPath [
        postgres
      ];

      extraOptions = [ "--tmpfs=/run/postgresql" ];

      volumes = [
        "postgres:/data"

        "${lib.getExe pkgs.bash}:/bin/sh:ro"
        "${./pg_hba.conf}:/pg_hba.conf:ro"
        "${./postgresql.conf}:/postgresql.conf:ro"
      ];
    };

  systemd.services.podman-postgres.preStop = lib.mkBefore ''
    podman exec postgres pg_ctl -D /data stop -m fast
  '';
}
