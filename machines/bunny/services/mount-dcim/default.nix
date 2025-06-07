{ pkgs, ... }: {
  systemd.services."mount-dcim" = {
    script = ''
      mkdir -p /home/admin/DCIM
      exec ${pkgs.bindfs}/bin/bindfs \
        -u admin -g users -f         \
        --create-for-user=syncthing  \
        --create-for-group=syncthing \
        /persist/sync/DCIM /home/admin/DCIM
    '';
    wantedBy = [ "default.target" ];
  };
}
