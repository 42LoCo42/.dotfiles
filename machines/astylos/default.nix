{ self, pkgs, aquaris, ... }: {
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

  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "hidepid=2" "gid=wheel" ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    zfs.package = pkgs.zfs_unstable;
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  networking.hosts = {
    "127.0.0.1" = [ "dc10.readers.lakd" ];
  };

  programs.gamemode.enable = true;

  rice = {
    dnsmasq-interface = "enp6s0";

    tailscale = true;

    fuzzel-font-size = 20;
    temp-select = ''KERNELS=="coretemp.0"'';
    temp-warn = 70;

    hypr-early-config = ''
      env = AQ_DRM_DEVICES,/persist/gpu/nvidia

      env = GBM_BACKEND,nvidia-drm
      env = __GLX_VENDOR_LIBRARY_NAME,nvidia
      env = LIBVA_DRIVER_NAME,nvidia

      monitor = DVI-D-1,1920x1080@60,0x0,1
      # monitor = DP-1,1920x1080@60,1920x0,1
      monitor = DP-1,disable # TODO
    '';
  };

  home-manager.users.leonsch = {
    aquaris.persist = [
      "IU"
      "config"
      "dev"
      "doc"
      "music"
      "work"

      ".cache/JetBrains"

      ".config/JetBrains"
      ".config/Yubico"
      ".config/dconf"
      ".config/emacs"
      ".config/rustdesk"
      ".config/vesktop"

      ".local/share/JetBrains"
      ".local/share/PrismLauncher"
      ".local/share/direnv"
      ".local/share/flatpak"

      ".local/state/wireplumber"
    ];

    home.packages = with pkgs; [
      openvpn # for corporate VPN
      p7zip
      prismlauncher
      pwgen
      python3
      rustdesk-flutter
      wf-recorder

      # for external backup SSD
      btrfs-progs
      cryptsetup

      # for managing my music library
      ffmpeg
      kid3-cli
      moreutils
    ];
  };
}
