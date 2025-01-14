{ pkgs, lib, ... }: {
  virtualisation.pnoc.postgres = {
    cmd = [ (lib.getExe' pkgs.postgresql_16 "postgres") "-D" "/data" ];
    volumes = [
      "postgres:/data"
      "postgres:/run/postgresql"
      "${./pg_hba.conf}:/data/pg_hba.conf:ro"
      "${./postgresql.conf}:/data/postgresql.conf:ro"
    ];
  };
}
