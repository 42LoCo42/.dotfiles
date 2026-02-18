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
    unfreeNames = [ "factorio-space-age" ];

    desktop = {
      gpu = {
        intel.enable = true;
        nvidia.enable = true;
      };

      udev.cpuTemperatureSelector = ''KERNELS=="coretemp.0"'';

      wayland = {
        fuzzel.fontSize = 20;

        hyprland = {
          monitors = {
            primary = {
              name = "DVI-D-1";
              mode = "preferred, 0x0, 1";
            };

            secondary = {
              name = "DP-1";
              mode = "preferred, auto-right, 1";
            };
          };

          postConfig = ''
            bind = $mod SHIFT, m, exec, toggle-mouse
          '';
        };
      };
    };
  };

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
