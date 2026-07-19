{ lib, pkgs, ... }:
let
  postgres = pkgs.postgresql_17.withPackages (p: with p; [
    pgvector # required by vectorchord
    vectorchord
  ]);
in
{
  topology.nodes.bunny.services.postgres = {
    name = "PostgreSQL ${lib.versions.major postgres.version}";
    icon = "services.postgres";
    info = "Central database for other services";
  };

  virtualisation.pnoc.postgres = {
    path = with pkgs; [
      coreutils
      less
      postgres
    ];

    script = ''
      if [ ! -e /data/PG_VERSION ]; then initdb -E UTF8 /data; fi
      cp -v /pg_hba.conf /postgresql.conf /data
      exec postgres -D /data
    '';

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
