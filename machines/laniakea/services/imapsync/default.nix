{ config, lib, pkgs, ... }: {
  virtualisation.pnoc.imapsync = {
    path = with pkgs; [ imapsync ];

    script = ''
      : >> /data/args
      mapfile -t args < /data/args

      imapsync                         \
        --host1 hydroxide:1143         \
        --user1 leonsch                \
        --host2 maddy:1143             \
        --user2 leonsch@protonmail.com \
        --exclude 'All Mail'           \
        --tmpdir /data/tmp             \
        --logdir /data/log             \
        --minage 30                    \
        --useuid                       \
        "''${args[@]}" || :
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/imapsync") ];

    volumes = [ "imapsync:/data" ];
  };

  systemd = {
    services.podman-imapsync = {
      serviceConfig.Restart = lib.mkForce "no";
    };

    timers.imapsync = {
      wantedBy = [ "timers.target" ];

      timerConfig = {
        Unit = "podman-imapsync.service";

        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}
