{ lib, ... }:
let disk = "nvme-eui.8ce38e0400d8442a"; in {
  imports = [ ../../profiles/nori ];

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
            fixate = "9743cb09e4f997eeede22763472b554b2bf3181d2b107af7e816a7d181a69103";
          };
        }
      ];
    };

    persist.dirs = {
      "/var/lib/bluetooth" = { m = "0700"; };
    };
  };

  boot.kernelParams = [
    # ¿fix? random freezing
    "processor.max_cstate=5"
    "intel_idle.max_cstate=0"
  ];

  services = {
    getty = {
      autologinOnce = true;
      autologinUser = "nori";
    };

    greetd.enable = lib.mkForce false;
  };

  environment.shellInit = ''
    if [ "$TTY" = "/dev/tty1" ]; then
      exec start-hyprland
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
    };
  };

  home-manager.sharedModules = [{
    aquaris.hyprland = {
      monitors.primary.output = "eDP-1";

      precfg = ''
        mouse = "synaptics-tm3336-004"
      '';
    };
  }];
}
