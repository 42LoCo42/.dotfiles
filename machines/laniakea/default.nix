{ pkgs, aquaris, ... }: {
  imports = [ ./kboot-conf ];

  aquaris = {
    machine = {
      id = "97c93e7db21d05599c3e3c6c67177830";
      key = "age1dj9wv3xzxcu4fsxh4u6ue03ctgwfjz2k06m2tzt8v2gcfclvweaqp6x9l7";
      secureboot = false;
    };

    users = aquaris.lib.merge [
      { inherit (aquaris.cfg.users) leonsch; }
      { leonsch.admin = true; }
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

  boot = rec {
    loader.kboot-conf.enable = true;
    kernelPackages = pkgs.linuxPackages;
    extraModulePackages = with kernelPackages; [ rtl8821au ];
  };

  hardware.deviceTree.name = "rockchip/rk3568-odroid-m1.dtb";

  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "client";
    };
  };
}
