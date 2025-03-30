{ pkgs, lib, ... }: {
  virtualisation.pnoc.postgres =
    let
      postgres = pkgs.postgresql_16.withPackages (p: with p; [
        pgvecto-rs
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

      extraOptions = [
        "--read-only" # for UID/GID resolution
        "--tmpfs=/run/postgresql"
      ];

      volumes = [
        "postgres:/data"

        "${./pg_hba.conf}:/pg_hba.conf:ro"
        "${./postgresql.conf}:/postgresql.conf:ro"

        "${pkgs.lib.getExe pkgs.bash}:/bin/sh:ro"
        "${pkgs.lib.getExe' postgres "psql"}:/bin/psql:ro"
      ];
    };
}
