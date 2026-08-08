{ pkgs, ... }: {
  imports = [ ../../profiles/leonsch ];

  aquaris = {
    machine = {
      id = "c426b77d7a1940ba98f0cdcf669cd11c";
      secureboot = false;
    };

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
    unfreeNames = [ "factorio-space-age" ];

    desktop = {
      gpu = {
        amd.enable = true;
        intel.enable = true;
      };

      udev.cpuTemperatureSelector = ''KERNELS=="coretemp.0"'';

      wayland = {
        fuzzel.fontSize = 20;

        hyprland = {
          monitors = {
            DVI-D-1 = { };
            DP-3 = { position = "auto-right"; };
          };

          binds = f: with f; {
            S-m = exec toggle-mouse;
          };

          settings.device = {
            name = "genps/2-genius-mouse";
            accel_profile = "custom 0.1372465604 0.000 0.344 0.687 1.204 1.721 2.238 2.801 3.586 4.372 5.157 5.943 6.728 7.514 8.299 9.084 9.870 10.655 11.441 12.226 13.849";
          };
        };
      };
    };
  };

  hardware.graphics.extraPackages = with pkgs; [
    mesa.opencl
  ];

  home-manager.sharedModules = [{
    aquaris.persist = {
      ".cache/JetBrains" = { };
      ".config/JetBrains" = { };
      ".factorio" = { };
      ".local/share/JetBrains" = { };
    };

    home.packages = with pkgs; [
      factorio-space-age

      (writeShellApplication {
        name = "toggle-mouse";
        text = ''
          f="$HOME/.cache/mouse-disabled"

          if [ -e "$f" ]; then
            rm -f "$f"
            e=true
            notify-send "Mouse enabled"
          else
            touch "$f"
            e=false
            notify-send "Mouse disabled"
          fi

          hyprctl keyword 'device[sigmachip-usb-mouse]:enabled' "$e"
        '';
      })
    ];
  }];

  system.extraDependencies = with pkgs; [
    factorio-space-age.src
  ];
}
