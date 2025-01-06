{ self, pkgs, config, aquaris, ... }:
let
  inherit (pkgs.lib) getExe';
  obscura = self.inputs.obscura.packages.${pkgs.system};
in
{
  imports = [
    ../../rice
    ./kboot-conf
  ];

  aquaris = {
    machine = {
      id = "97c93e7db21d05599c3e3c6c67177830";
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

    secrets = {
      "machine:${aquaris.name}.ncps".user = "ncps";
    };
  };

  boot = rec {
    loader.kboot-conf.enable = true;
    kernelPackages = pkgs.linuxPackages;
    extraModulePackages = with kernelPackages; [ rtl8821au ];
  };

  hardware.deviceTree.name = "rockchip/rk3568-odroid-m1.dtb";

  services.chrony.extraConfig = ''
    # NTP fallback
    server pool.ntp.org iburst
  '';

  rice = {
    pam-rssh.enable = true;
    tailscale.enable = true;
    use-ncps.enable = true;
  };

  networking.firewall.allowedTCPPorts = [
    8501 # ncps
  ];

  virtualisation.pnoc = {
    ncps = {
      cmd = [ (getExe' obscura.ncps "ncps-db-helper") "serve" ];

      environment = {
        CACHE_DATA_PATH = "/data";
        CACHE_HOSTNAME = aquaris.name;
        CACHE_LRU_SCHEDULE = "0 0 * * *";
        CACHE_MAX_SIZE = "250G";
        CACHE_SECRET_KEY_PATH = "/key";

        UPSTREAM_CACHES = builtins.concatStringsSep ","
          config.nix.settings.substituters;

        UPSTREAM_PUBLIC_KEYS = builtins.concatStringsSep ","
          config.nix.settings.trusted-public-keys;
      };

      # for some reason, /etc/passwd gets mode 600
      # if the container image is not read-only
      # otherwise, it gets 644
      # ncps tries to lookup its user here, so it needs read access
      extraOptions = [ "--read-only" ];

      ports = [ "8501:8501" ];

      ssl = true;

      volumes = [
        "ncps:/data"
        "${config.aquaris.secrets."machine/ncps"}:/key:ro"
      ];
    };
  };
}
