{
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
          "nixos/nix" = rec {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = mountpoint;
            mountOptions = [ "zfsutil" ];
          };

          "nixos/persist" = rec {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = mountpoint;
            mountOptions = [ "zfsutil" ];
          };

          # encrypted = {
          #   type = "zfs_fs";
          #   options = {
          #     mountpoint = "none";
          #     encryption = "aes-256-gcm";
          #     keyformat = "passphrase";
          #     keylocation = "file:///tmp/secret.key";
          #   };
          #   # use this to read the key during boot
          #   # postCreateHook = ''
          #   #   zfs set keylocation="prompt" "zroot/$name";
          #   # '';
          # };
        };
      };
    };
  };
}
