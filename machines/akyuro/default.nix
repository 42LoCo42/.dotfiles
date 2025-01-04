{ pkgs, config, aquaris, ... }: {
  imports = [ ../../rice ];

  aquaris = {
    users = aquaris.lib.merge [
      { inherit (aquaris.cfg.users) leonsch; }
      { leonsch.admin = true; }
    ];

    machine.id = "86b0e292e1fc27eb4168defa65cb41fd";

    filesystems = { fs, ... }: {
      zpools.rpool = fs.defaultPool;

      disks."/dev/disk/by-id/nvme-eui.8ce38e0400d8442a".partitions = [
        fs.defaultBoot
        {
          content = fs.luks {
            content = fs.zpool (p: p.rpool);
          };
        }
      ];
    };

    persist = {
      enable = true;
      dirs = { "/root/.android" = { }; };
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    zfs.package = pkgs.zfs_unstable;
  };

  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };

  services.auto-cpufreq.enable = true;

  rice = {
    desktop = {
      enable = true;

      udev.cpuTemperatureSelector = ''DRIVERS=="k10temp"'';

      wayland = {
        fuzzel.fontSize = 14;

        hyprland.preConfig = ''
          monitor = eDP-1,1920x1080@60,0x0,1
        '';

        waybar.temperatureWarn = 60;

        wlsunset = {
          lat = "54.31";
          lon = "13.09";
        };
      };
    };

    dns = {
      enable = true;
      interface = "wlp2s0";
    };

    syncthing.enable = true;
    tailscale.enable = true;
    use-ncps.enable = true;
  };

  home-manager.users.leonsch = hm: {
    aquaris.persist = {
      ".config/rustdesk" = { };

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
      ];
  };
}
