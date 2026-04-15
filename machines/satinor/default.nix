{ pkgs, config, ... }: {
  imports = [ ../../profiles/ercanar ];

  aquaris = {
    machine = {
      id = "d637e5e346d34ccaa49d9994aafeba4a";
      secureboot = false;
    };

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
    fsType = "auto";
  };

  networking.firewall = {
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 24454 ];
  };

  services.keyd.keyboards.default = {
    ids = [ "260d:1026:161a6f2c" ]; # definitely a keyboard btw trust me bro :3
    settings.main = {
      mouse1 = "q";
      mouse2 = "e";
    };
  };

  rice = {
    nixremote.act = true;

    desktop = {
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
              mode = "preferred, 0x0, 1";
            };

            secondary = {
              name = "HDMI-A-1";
              mode = "preferred, auto-right, 1";
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
                "class moe.launcher.an-anime-game-launcher"

                # libreoffice
                "class soffice"
                "initial_class libreoffice-startcenter"
              ];
            };
          };
        };

        swaybg.image = config.aquaris.secret "user/ercanar/wallpaper";
      };
    };
  };

  home-manager.sharedModules = [{
    aquaris = {
      persist = {
        ".config/blender" = { };
      };
    };

    home.packages = with pkgs; [
      pkgsRocm.blender
    ];

    systemd.user.services.microphone-lock = {
      Service.ExecStart = pkgs.lib.getExe (pkgs.writeShellApplication {
        name = "microphone-lock";
        runtimeInputs = with pkgs; [ gawk pulsemixer ];
        text = ''
          source="$(
            pulsemixer --list-sources \
            | awk '/HD 720P webcam/ {print (substr($3, 0, length($3) - 1))}')"

          while sleep 1; do
            pulsemixer --id "$source" --set-volume 90
          done
        '';
      });

      Unit = {
        After = [ "pipewire.service" ];
        Wants = [ "pipewire.service" ];
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  }];
}
