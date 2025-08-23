{ pkgs, ... }: {
  imports = [ ../../profiles/leonsch ];

  aquaris = {
    machine.id = "c426b77d7a1940ba98f0cdcf669cd11c";
    secrets.pub = "w5w9Z_X1U0RU0Bru5sQeTADbWUR8Lfb5FCQ29xZwJSI";

    filesystems = { fs, ... }: {
      disks."/dev/disk/by-id/wwn-0x5002538f415750ea".partitions = [
        fs.defaultBoot
        { content = fs.zpool (p: p.rpool); }
        { content = fs.zpool (p: p.rpool); }
      ];
    };
  };

  rice = {
    use-ncps.enable = true;

    desktop = {
      gpu = {
        intel.enable = true;
        nvidia.enable = true;
      };

      udev.cpuTemperatureSelector = ''KERNELS=="coretemp.0"'';

      wayland = {
        fuzzel.fontSize = 20;

        hyprland.monitors = {
          primary = {
            name = "DVI-D-1";
            mode = "1920x1080@60, 0x0, 1";
          };

          secondary = {
            name = "DP-1";
            mode = "1920x1080@60, 1920x0, 1";
          };
        };
      };
    };
  };

  home-manager.sharedModules = [{
    aquaris.persist = {
      ".cache/JetBrains" = { };
      ".config/JetBrains" = { };
      ".local/share/JetBrains" = { };
    };
  }];
}
