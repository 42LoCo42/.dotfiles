{ pkgs, aquaris, ... }: {
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

  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };

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

    dns.enable = true;
    nixremote.enable = true;
    syncthing.enable = true;
    tailscale.enable = true;
    use-ncps.enable = true;
  };

  home-manager.users.leonsch = {
    aquaris.persist = {
      ".thunderbird" = { };

      ".cache/thunderbird" = { };

      ".config/hydroxide" = { };
      ".config/rustdesk" = { };

      ".local/share/typst/packages/local" = { };

      "IU" = { };
      "dev" = { };
      "doc" = { };
      "img" = { };
      "work" = { };
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

      # experimental
      thunderbird
    ];

    systemd.user.services.hydroxide = {
      Unit = {
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Install.WantedBy = [ "default.target" ];

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.lib.getExe pkgs.hydroxide} serve";
      };
    };
  };
}
