{ self, aquaris, ... }: {
  imports = [ "${self}/rice" ];

  aquaris = {
    users = aquaris.lib.merge [
      { inherit (aquaris.cfg.users) leonsch; }
      { leonsch.admin = true; }
    ];

    machine = {
      id = "c426b77d7a1940ba98f0cdcf669cd11c";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzX0UanYQszieQbwYaNa224Omx580f/Iq1g5AWN/2VU";
    };

    persist = {
      enable = true;
      dirs = [
        "/root/.android"
        "/var/cache/tuigreet"
      ];
    };

    filesystems = { fs, ... }: {
      zpools.rpool = fs.defaultPool;

      # no sizes, these are pre-existing partitions
      disks."/dev/disk/by-id/wwn-0x5002538f415750ea".partitions = [
        {
          type = "uefi";
          content = fs.regular {
            type = "vfat";
            mountpoint = "/boot";
          };
        }
        { content = fs.zpool (p: p.rpool); }
        { content = fs.zpool (p: p.rpool); }
      ];
    };
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  networking.nameservers = [
    "1.1.1.1#one.one.one.one"
    "1.0.0.1#one.one.one.one"

    "9.9.9.9#dns.quad9.net"
    "149.112.112.112#dns.quad9.net"
  ];

  services.resolved = {
    dnsovertls = "true";
    dnssec = "true";
    fallbackDns = [ ];
  };

  rice = {
    fuzzel-font-size = 20;
    temp-select = ''KERNELS=="coretemp.0"'';
    temp-warn = 70;

    hypr-early-config = ''
      env = AQ_DRM_DEVICES,/dev/dri/by-path/pci-0000:01:00.0-card

      monitor = DVI-D-1,1920x1080@60,0x0,1
      monitor = DP-1,disable # TODO
    '';
  };

  home-manager.users.leonsch = {
    aquaris = {
      persist = [
        "config"
        "dev"
        "doc"
        "music"

        ".cache/mesa_shader_cache"
        ".cache/nvidia"
        ".config/Yubico"
        ".config/dconf"
        ".config/emacs"
        ".config/vesktop"
        ".local/share/flatpak"
        ".local/state/wireplumber"
      ];
    };
  };
}
