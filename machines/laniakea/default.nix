{ pkgs, config, aquaris, ... }:
let
  inherit (pkgs.lib) flip getExe mkMerge pipe remove;

  ncps-caches = pipe config.nix.settings [
    (x: with x; with config.rice.use-ncps; {
      urls = { val = substituters; rem = url; };
      keys = { val = trusted-public-keys; rem = key; };
    })
    (builtins.mapAttrs (_: flip pipe [
      (x: remove x.rem x.val)
      (builtins.concatStringsSep ",")
    ]))
  ];
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

    users = mkMerge [
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
    pam-rssh.enable = true;
    syncthing.enable = true;
    tailscale.enable = true;
    use-ncps.enable = true;
  };

  networking.firewall = {
    trustedInterfaces = [ "podman0" ];
    allowedTCPPorts = [
      80 # mympd
      8501 # ncps
    ];
  };

  # rubicon needs to forward MPD to our 0.0.0.0
  # so that mympd can connect to it from the podman network
  services.openssh.settings.GatewayPorts = "yes";

  systemd = {
    services = {
      mympd = {
        serviceConfig = {
          ExecStart = builtins.concatStringsSep " " [
            (getExe pkgs.socket-activate)
            "-u podman-mympd.service"
            "-a 127.0.0.1:8080"
            "-t 5m"
          ];

          NonBlocking = true;
        };
      };
    };

    sockets = {
      mympd = {
        socketConfig = {
          ListenStream = "80";
          NoDelay = true;
        };

        wantedBy = [ "sockets.target" ];
      };
    };
  };

  virtualisation.oci-containers.containers.mympd.autoStart = false;

  virtualisation.pnoc = {
    mympd = {
      cmd = [ (getExe pkgs.mympd) "-a" "/data/cache" "-w" "/data/work" ];

      ports = [ "8080:8080" ];

      volumes = [
        "mympd:/data"

        "${./mympd/http_port}:/data/work/config/http_port:ro"
        "${./mympd/ssl}:/data/work/config/ssl:ro"

        "/persist/home/leonsch/music:/music:ro"
        "/persist/home/leonsch/music/ARTIST_COVERS:/data/work/pics/Artist:ro"
      ];
    };

    ncps = {
      cmd = [ (getExe pkgs.ncps-db-helper) "serve" ];

      environment = {
        CACHE_DATA_PATH = "/data";
        CACHE_HOSTNAME = aquaris.name;
        CACHE_LRU_SCHEDULE = "0 0 * * *";
        CACHE_MAX_SIZE = "250G";
        CACHE_SECRET_KEY_PATH = "/key";

        UPSTREAM_CACHES = ncps-caches.urls;
        UPSTREAM_PUBLIC_KEYS = ncps-caches.keys;
      };

      # for some reason, /etc/passwd gets mode 600
      # if the container image is not read-only
      # otherwise, it gets 644
      # ncps tries to lookup its user here, so it needs read access
      extraOptions = [ "--read-only" ];

      ports = [ "8501:8501" ];

      secrets = [ "machine/ncps:/key" ];

      volumes = [ "ncps:/data" ];
    };
  };
}
