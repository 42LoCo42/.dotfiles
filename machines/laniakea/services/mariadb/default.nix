{ pkgs, ... }: {
  virtualisation.pnoc.mariadb = {
    path = with pkgs; [
      coreutils
      gnused
      mariadb
    ];

    script = ''
      cd /data
      mkdir -p data

      if [ ! -d data/mysql ]; then
        mariadb-install-db                         \
          --datadir="$PWD/data"                    \
          --skip-test-db                           \
          --auth-root-authentication-method=socket \
          --auth-root-socket-user=mariadb
      fi

      exec mariadbd-safe --datadir="$PWD/data"
    '';

    extraOptions = [ "--tmpfs=/run/mysqld" ];

    volumes = [ "mariadb:/data" ];
  };
}
