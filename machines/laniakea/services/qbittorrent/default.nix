{ pkgs, lib, ... }: {
  virtualisation.pnoc.qbittorrent = {
    cmd = [
      # qbit doesn't reap its python children when searching
      (lib.getExe pkgs.tini)
      "--"

      (lib.getExe pkgs.qbittorrent-nox)
      "--confirm-legal-notice"

      "--profile=/data/profile"
      "--configuration=/" # actually relative to profile
    ];

    # temp dir for downloading search plugins
    # why is this even required; i am going to krill my shelf
    extraOptions = [ "--tmpfs=/.qBittorrent" ];

    volumes = [
      "qbittorrent:/data"

      # qbit does not seem to respect SSL_CERT_FILE...
      "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt:/etc/ssl/certs/ca-bundle.crt:ro"
    ];
  };

  systemd.services."mount-qbit-save" = {
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
}
