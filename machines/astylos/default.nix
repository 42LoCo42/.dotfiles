{ pkgs, config, aquaris, ... }: {
  imports = [ ../../rice ];

  aquaris = {
    users = aquaris.lib.merge [
      { inherit (aquaris.cfg.users) leonsch; }
      { leonsch.admin = true; }
    ];

    machine.id = "c426b77d7a1940ba98f0cdcf669cd11c";

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

    persist = {
      enable = true;
      dirs = { "/root/.android" = { }; };
    };

    secrets."user:leonsch.u2f-keys".user = "leonsch";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    zfs.package = pkgs.zfs_unstable;
  };

  programs.gamemode.enable = true;

  rice = {
    desktop = {
      enable = true;

      udev.cpuTemperatureSelector = ''KERNELS=="coretemp.0"'';

      wayland = {
        fuzzel.fontSize = 20;

        hyprland.preConfig = ''
          env = AQ_DRM_DEVICES,/persist/gpu/nvidia

          env = GBM_BACKEND,nvidia-drm
          env = __GLX_VENDOR_LIBRARY_NAME,nvidia
          env = LIBVA_DRIVER_NAME,nvidia

          monitor = DVI-D-1,1920x1080@60,0x0,1
          # monitor = DP-1,1920x1080@60,1920x0,1
          monitor = DP-1,disable # TODO
        '';

        waybar.temperatureWarn = 70;

        wlsunset = {
          lat = "54.31";
          lon = "13.09";
        };
      };
    };

    dns = {
      enable = true;
      interface = "enp6s0";
    };

    syncthing.enable = true;
    tailscale.enable = true;
    use-ncps.enable = true;
  };

  home-manager.users.leonsch = hm: {
    aquaris.persist = {
      ".cache/JetBrains" = { };

      ".config/JetBrains" = { };
      ".config/rustdesk" = { };

      ".local/share/JetBrains" = { };
      ".local/share/typst/packages/local" = { };
    };

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

    home.sessionVariables.NIXOS_CONFIG_DIR = "$(realpath $HOME/config)";

    systemd.user.tmpfiles.rules =
      let
        home = hm.config.home.homeDirectory;
        sync = "${config.aquaris.persist.root}/${home}/sync";
      in
      (map (x: "L+ ${home}/${x} - - - - ${sync}/${x}") [
        "IU"
        "dev"
        "doc"
        "img"
        "work"
      ]) ++ [
        "L+ ${home}/config - - - - ${sync}/dev/nix/dotfiles"

        "L+ %h/.config/Yubico/u2f_keys - - - - ${config.aquaris.secrets."user:leonsch.u2f-keys"}"
      ];
  };
}
