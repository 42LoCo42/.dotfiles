{ pkgs, lib, ... }: {
  topology.self.services.mympd = {
    name = "MyMPD";
    icon = "services.mympd";
    info = "Web MPD client";
    details.url.text = "https://music.laniakea";
  };

  # rubicon needs to forward MPD to our 0.0.0.0
  # so that mympd can connect to it from the podman network
  services.openssh.settings.GatewayPorts = "yes";

  systemd = {
    sockets.mympd = {
      socketConfig = {
        ListenStream = "/var/lib/containers/storage/volumes/caddy/_data/mympd.sock";
        NoDelay = true;
      };

      wantedBy = [ "sockets.target" ];
    };

    services.mympd.serviceConfig = {
      ExecStart = builtins.concatStringsSep " " [
        (lib.getExe pkgs.socket-activate)
        "-u podman-mympd.service" # activate this unit
        "-a mympd.dns.podman:8080" # connect here
        "-d 2000" # delay attempts by 2 seconds to account for startup
        "-t 5m" # stop unit after 5 minutes of inactivity
      ];

      NonBlocking = true;
    };
  };

  virtualisation = {
    pnoc.mympd = {
      path = with pkgs; [
        coreutils
        mympd
      ];

      script = ''
        mkdir -p /data/{cache,work/pics}
        for i in Artist AlbumArtist; do
          ln -sfT "/music/ARTIST_COVERS" "/data/work/pics/$i"
        done

        exec mympd               \
          --cachedir /data/cache \
          --workdir /data/work
      '';

      environment = {
        MYMPD_HTTP_HOST = "0.0.0.0";
        MYMPD_HTTP_PORT = "8080";
        MYMPD_SSL = "false";
        MYMPD_CA_CERT_STORE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        MYMPD_URI = "http://host.containers.internal:6600";
      };

      volumes = [
        "mympd:/data"
        "/persist/home/admin/music:/music:ro"
      ];
    };

    oci-containers.containers.mympd.autoStart = false;
  };
}
