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

        hyprland =
          let
            primary = "DVI-D-1";
            secondary = "DP-1";

            secondary-goto = pkgs.writeShellScript "secondary-goto" ''
              if
                [ -n "$(
                  hyprctl workspaces -j \
                  | jq '.[] | select(.name == "secondary")'
                )" ] ||
                "$(
                  hyprctl monitors all -j | jq -r '
                    .[] | select(.name == "${secondary}")
                    | .disabled | not'
                )"
              then
                hyprctl dispatch workspace name:secondary
              fi
            '';

            secondary-move = pkgs.writeShellScript "secondary-move" ''
              hyprctl keyword monitor ${secondary}
              hyprctl dispatch movetoworkspace name:secondary
            '';

            secondary-quit = pkgs.writeShellScript "secondary-quit" ''
              hyprctl keyword monitor ${secondary},disable
            '';
          in
          {
            preConfig = ''
              monitor = ${primary},   1920x1080@60,    0x0, 1
              monitor = ${secondary}, 1920x1080@60, 1920x0, 1
              monitor = ${secondary}, disable

              workspace = n[false],       monitor:${primary}
              workspace = name:secondary, monitor:${secondary}, default
            '';

            postConfig = ''
              bind = $mod      , ssharp, exec, ${secondary-goto}
              bind = $mod SHIFT, ssharp, exec, ${secondary-move}
              bind = $mod CTRL , ssharp, exec, ${secondary-quit}
            '';
          };

        waybar.temperatureWarn = 70;
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
