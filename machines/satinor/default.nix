{ pkgs, lib, config, ... }: {
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

  hardware.amdgpu.opencl.enable = true;

  rice.desktop = {
    alpha = 80;

    udev.cpuTemperatureSelector = ''DRIVERS=="k10temp"'';

    wayland = {
      fuzzel.fontSize = 20;

      hyprland = {
        preConfig = ''
          monitor   = DP-1,     2560x1440@60,    0x0, 1
          monitor   = HDMI-A-1, 1920x1080@60, 2560x0, 1
          monitor   = HDMI-A-1, disable
          workspace = 9, monitor:HDMI-A-1, default:true
        '';

        postConfig = ''
          # fix GPU spikes by providing a constant baseload
          windowrulev2 = float,    title:vkcube
          windowrulev2 = pin,      title:vkcube
          windowrulev2 = nofocus,  title:vkcube
          windowrulev2 = move 0 0, title:vkcube
          windowrulev2 = size 1 1, title:vkcube
          exec-once    = ${lib.getExe' pkgs.vulkan-tools "vkcube"} --wsi wayland

          exec-once = [workspace 1 silent] @terminal@
          exec-once = [workspace 2 silent] uwsm app @vesktop@
          exec-once = [workspace 3 silent] steam
          exec-once = [workspace 4 silent] uwsm app librewolf
          exec-once = [workspace 5 silent] anime-game-launcher
        '';
      };

      swaybg.image = config.aquaris.secret "user/ercanar/wallpaper";

      waybar.temperatureWarn = 70;
    };
  };
}
