{ pkgs, ... }: {
  aquaris = {
    filesystem = { filesystem, zpool, ... }: {
      disks."/dev/disk/by-id/virtio-root".partitions = [
        {
          type = "uefi";
          size = "512M";
          content = filesystem {
            type = "vfat";
            mountpoint = "/boot";
          };
        }
        { content = zpool (p: p.rpool); }
      ];

      zpools.rpool.datasets = {
        "nixos/nix" = { };
        "nixos/persist" = { };
      };
    };
  };

  services = {
    homed.enable = true;
  };

  systemd.services.systemd-homed.path = with pkgs; [ e2fsprogs ];
}
