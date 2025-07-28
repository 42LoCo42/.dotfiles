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
      cmd = [
        (lib.getExe (pkgs.writeShellApplication {
          name = "mympd";
          runtimeInputs = with pkgs; [ coreutils mympd ];
          text = builtins.readFile ./start.sh;
        }))
      ];

      environment = {
        MYMPD_HTTP_HOST = "0.0.0.0";
        MYMPD_HTTP_PORT = "8080";
        MYMPD_SSL = "false";
        MYMPD_CA_CERT_STORE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        MYMPD_URI = "http://host.containers.internal:6600";
      };

      ports = [ "8081:8080" ];

      volumes = [
        "mympd:/data"
        "/persist/home/admin/music:/music:ro"
      ];
    };

    oci-containers.containers.mympd.autoStart = false;
  };
}
