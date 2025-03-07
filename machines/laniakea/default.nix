{ pkgs, lib, aquaris, ... }: {
  imports = [
    ../../rice
    ./kboot-conf
    ./services
  ];

  aquaris = {
    machine = {
      id = "97c93e7db21d05599c3e3c6c67177830";
      secureboot = false;
    };

    users = lib.mkMerge [
      { inherit (aquaris.cfg.users) leonsch; }
      {
        leonsch = {
          admin = true;
          sshKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKx249VBeDWNvrsJBOM467C51FUmZ5oNbiIv9GhZt9M6 music@rubicon"
          ];
        };
      }
    ];

    filesystems = { fs, ... }: {
      disks."/dev/disk/by-id/nvme-CT1000P3SSD8_2320E6D694B5_1".partitions = [
        fs.defaultBoot
        { content = fs.zpool (p: p.rpool); }
      ];

      zpools.rpool = fs.defaultPool;
    };

    persist.enable = true;
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:42loco42/.dotfiles";
    flags = [ "--refresh" "-L" ];
  };

  boot = rec {
    loader.kboot-conf.enable = true;
    kernelPackages = pkgs.linuxPackages;
    extraModulePackages = with kernelPackages; [
      # rtl8821au # currenctly broken
      rtw88 # replacement?
    ];
  };

  hardware.deviceTree.name = "rockchip/rk3568-odroid-m1.dtb";

  rice = {
    ca.enable = true;
    nixremote.enable = true;
    pam-rssh.enable = true;
    syncthing.enable = true;
    tailscale.enable = true;
    use-ncps.enable = true;
  };

  networking.firewall.trustedInterfaces = [ "podman0" ];
}
