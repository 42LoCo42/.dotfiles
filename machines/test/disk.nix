{ initial }: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/virtio-aaaabbbbccccdddd";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [ "mode=755" ];
      postMountHook = "zfs mount -av";
    };

    zpool = {
      rpool = {
        options = {
          ashift = "12";
          autoexpand = "on";
          autoreplace = "on";
          autotrim = "on";
          listsnapshots = "on";
        };

        rootFsOptions = {
          acltype = "posix";
          compression = "zstd";
          dnodesize = "auto";
          mountpoint = "none";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
        };

        datasets = {
          "nixos" = {
            type = "zfs_fs";
            options = {
              encryption = "on";
              keyformat = "passphrase";
              keylocation = "file://${initial}";
            };
          };

          "nixos/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };

          "nixos/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
          };

          "nixos/home" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/persist/home";
              canmount = "off";
            };
          };

          "nixos/home/leonsch" = {
            type = "zfs_fs";
            options.keyformat = "passphrase";
          };
        };
      };
    };
  };
}
