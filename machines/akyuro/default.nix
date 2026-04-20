{ lib, ... }:
let disk = "nvme-eui.8ce38e0400d8442a"; in {
  imports = [ ../../profiles/leonsch ];

  aquaris = {
    machine.id = "86b0e292e1fc27eb4168defa65cb41fd";
    secrets.pub = "IIZ7WIULG2jlmL9zKJogbfjVysqd4iPDh9cLoU2lAHI";

    filesystems = { fs, ... }: {
      disks."/dev/disk/by-id/${disk}".partitions = [
        fs.defaultBoot
        {
          content = fs.luks {
            content = fs.zpool (p: p.rpool);

            tpmDecrypt = true;
            tpmMeasure = true;
          };
        }
      ];
    };

    persist.dirs = {
      "/var/lib/bluetooth" = { m = "0700"; };
    };
  };

  boot.initrd.luks.devices."${disk}-part2" = {
    crypttabExtraOpts = [
      "fixate-volume-key=9743cb09e4f997eeede22763472b554b2bf3181d2b107af7e816a7d181a69103"
    ];
  };

  services = {
    getty = {
      autologinOnce = true;
      autologinUser = "leonsch";
    };

    greetd.enable = lib.mkForce false;
  };

  environment.shellInit = ''
    if [ "$TTY" = "/dev/tty1" ]; then
      exec uwsm start hyprland.desktop
    fi
  '';

  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };

  rice.desktop = {
    gpu.amd.enable = true;

    udev.cpuTemperatureSelector = ''DRIVERS=="k10temp"'';

    wayland = {
      fuzzel.fontSize = 14;

      hyprland.monitors.primary = {
        name = "eDP-1";
        mode = "preferred, 0x0, 1";
      };
    };
  };
}
