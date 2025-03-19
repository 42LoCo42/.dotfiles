{ pkgs, lib, ... }: {
  # rubicon needs to forward MPD to our 0.0.0.0
  # so that mympd can connect to it from the podman network
  services.openssh.settings.GatewayPorts = "yes";

  systemd = {
    services = {
      mympd = {
        serviceConfig = {
          ExecStart = builtins.concatStringsSep " " [
            (lib.getExe pkgs.socket-activate)
            "-u podman-mympd.service" # activate this unit
            "-a 127.0.0.1:8081" # connect here
            "-d 2000" # delay attempts by 2 seconds to account for mympd startup
            "-t 5m" # stop unit after 5 minutes of inactivity
          ];

          NonBlocking = true;
        };
      };
    };

    sockets = {
      mympd = {
        socketConfig = {
          ListenStream = "8080";
          NoDelay = true;
        };

        wantedBy = [ "sockets.target" ];
      };
    };
  };

  virtualisation = {
    pnoc.mympd = {
      cmd = [ (lib.getExe pkgs.mympd) "-a" "/data/cache" "-w" "/data/work" ];

      ports = [ "8081:8080" ];

      volumes = [
        "mympd:/data"

        "${./config/http_port}:/data/work/config/http_port:ro"
        "${./config/ssl}:/data/work/config/ssl:ro"

        "/persist/home/admin/music:/music:ro"
        "/persist/home/admin/music/ARTIST_COVERS:/data/work/pics/Artist:ro"
      ];
    };

    oci-containers.containers.mympd.autoStart = false;
  };
}
