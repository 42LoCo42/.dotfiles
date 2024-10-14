{ self, pkgs, config, aquaris, ... }: {
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
      dirs = [ "/root/.android" ];
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
    hrtrack-file = "/persist/$HOME/ARCH/trans/hrtrack";

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

  home-manager.users.leonsch = hm: {
    aquaris.persist = [
      "config"
      "music"

      ".cache/JetBrains"

      ".config/JetBrains"
      ".config/rustdesk"

      ".local/share/JetBrains"
      ".local/share/direnv"
    ];

    home.packages = with pkgs; [
      openvpn # for corporate VPN
      p7zip
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

    systemd.user.tmpfiles.rules =
      let
        home = hm.config.home.homeDirectory;
        sync = "${config.aquaris.persist.root}/${home}/sync";
      in
      map (x: "L+ ${home}/${x} - - - - ${sync}/${x}") [
        "IU"
        "dev"
        "doc"
        "img"
        "work"
      ];
  };
}
