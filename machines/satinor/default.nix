{ config, ... }: {
  imports = [ ../../profiles/ercanar ];

  aquaris = {
    machine.id = "d637e5e346d34ccaa49d9994aafeba4a";
    secrets.pub = "ow1SvzI5RFVro8k71KpKMtt-TCnQun4FMy6l0Bt-dSg";

    filesystems = { fs, ... }: {
      disks."/dev/disk/by-id/nvme-eui.6479a7a1800000c0".partitions = [
        fs.defaultBoot
        { content = fs.zpool (p: p.rpool); }
      ];
    };
  };

  fileSystems."/home/ercanar/esuesudesu" = {
    device = "/dev/disk/by-id/ata-JAJM600M1TB_AA202100000000000773-part1";
  };

  networking.firewall.allowedTCPPorts = [ 25565 ];

  services.keyd.keyboards.default = {
    ids = [ "260d:1026:161a6f2c" ]; # definitely a keyboard btw trust me bro :3
    settings.main = {
      mouse1 = "q";
      mouse2 = "e";
    };
  };

  rice.desktop = {
    alpha = 80;

    gpu = {
      amd.enable = true;
      baseload = true;
    };

    udev.cpuTemperatureSelector = ''DRIVERS=="k10temp"'';

    wayland = {
      fuzzel.fontSize = 20;

      hyprland = rec {
        monitors = {
          primary = {
            name = "DP-1";
            mode = "2560x1440@60, 0x0, 1";
          };

          secondary = {
            name = "HDMI-A-1";
            mode = "1920x1080@60, 2560x0, 1";
          };
        };

        preConfig = ''
          workspace = 9, monitor:${monitors.secondary.name}, default:true
        '';

        workspaces = {
          "4" = {
            icon = "⛩️";
            autostart = [ "uwsm app anime-game-launcher" ];
            rules = [
              "class:(moe.launcher.an-anime-game-launcher)"

              # libreoffice
              "class:(soffice)"
              "initialClass:(libreoffice-startcenter)"
            ];
          };
        };
      };

      swaybg.image = config.aquaris.secret "user/ercanar/wallpaper";
    };
  };
}
