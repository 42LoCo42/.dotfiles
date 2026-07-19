{ config, lib, pkgs, ... }: {
  topology.self.services.qbittorrent = {
    name = "qBittorrent";
    icon = "services.qbittorrent";
    info = "BitTorrent web interface";
    details.url.text = "https://qbit.laniakea";
  };

  systemd = {
    sockets.qbittorrent = {
      socketConfig = {
        ListenStream = "/var/lib/containers/storage/volumes/caddy/_data/qbittorrent.sock";
        NoDelay = true;
      };

      wantedBy = [ "sockets.target" ];
    };

    services = {
      qbittorrent.serviceConfig = {
        ExecStart = builtins.concatStringsSep " " [
          (lib.getExe pkgs.socket-activate)
          "-u qbit-stop.service" # activate this unit
          "-a qbittorrent.dns.podman:8080" # connect here
          "-d 2000" # delay attempts by 2 seconds to account for startup
        ];

        NonBlocking = true;
      };

      qbit-stop = {
        path = with pkgs; [ curl jq ];
        script = ''
          echo "Starting qBittorrent!"
          systemctl start podman-qbittorrent
          sleep 10s

          curl -c /tmp/jar -fsSL https://qbit.laniakea/api/v2/auth/login \
            -K ${config.aquaris.secret "@machine/qbit-stop"}
          echo "Logged in to qBittorrent API!"

          while sleep 5m; do
            if ! curl -b /tmp/jar -fsSL \
                 'https://qbit.laniakea/api/v2/torrents/info?filter=downloading' \
                 | jq --exit-status any; then
              echo "No running downloads since 5 minutes, exiting..."
              systemctl stop qbittorrent podman-qbittorrent || true
              exit
            fi

            echo "Some torrents are downloading..."
          done
        '';

        serviceConfig.PrivateTmp = "disconnected";
      };

      mount-qbit-save = {
        path = with pkgs; [ bindfs ];
        script = ''
          mkdir -p /home/admin/qbit

          exec bindfs                                                  \
            -u admin -g users -f                                       \
            --create-for-user=qbittorrent                              \
            --create-for-group=qbittorrent                             \
            /var/lib/containers/storage/volumes/qbittorrent/_data/save \
            /home/admin/qbit
        '';
        wantedBy = [ "default.target" ];
      };
    };
  };

  virtualisation = {
    pnoc.qbittorrent = {
      cmd = [
        # qbit doesn't reap its python children when searching
        (lib.getExe pkgs.docker.docker-tini)
        "--"

        (lib.getExe pkgs.qbittorrent-nox)
        "--confirm-legal-notice"

        "--profile=/data/profile"
        "--configuration=/" # actually relative to profile
      ];

      # temp dir for downloading search plugins
      # why is this even required; i am going to krill my shelf
      extraOptions = [ "--tmpfs=/.qBittorrent" ];

      volumes = [ "qbittorrent:/data" ];
    };

    oci-containers.containers.qbittorrent.autoStart = false;
  };
}
