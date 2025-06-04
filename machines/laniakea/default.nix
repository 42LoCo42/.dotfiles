{ pkgs, ... }: {
  imports = [
    ../../profiles/server
    ./kboot-conf
    ./services
  ];

  aquaris = {
    users.admin.sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKx249VBeDWNvrsJBOM467C51FUmZ5oNbiIv9GhZt9M6 music@rubicon"
    ];

    machine = {
      id = "97c93e7db21d05599c3e3c6c67177830";
      secureboot = false;
    };

    secrets.pub = "XKjp1ZlWTBBb2s6WVz-JMOj4S_QPIkDZ0t-C8ryP5Uo";

    filesystems = { fs, ... }: {
      disks."/dev/disk/by-id/nvme-CT1000P3SSD8_2320E6D694B5_1".partitions = [
        fs.defaultBoot
        { content = fs.zpool (p: p.rpool); }
      ];
    };
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
    domain = "laniakea";

    ca.enable = true;
    dns.enable = true;
    nixremote.enable = true;
    tailscale.enable = true;
    use-ncps.enable = true;
  };

  networking.firewall.trustedInterfaces = [ "podman0" ];
}
