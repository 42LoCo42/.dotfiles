{ lib, config, ... }: {
  options.rice.nixremote.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.nixremote.enable {
    nix = {
      distributedBuilds = true;
      settings.builders-use-substitutes = true;

      buildMachines = [{
        protocol = "ssh-ng";
        sshUser = "nixremote";
        hostName = "exit.bunny.vpn";

        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUJic0w3SHlPQ001NmVqdGxXcUVCRzFZelF3WDJLbVozUzVLem9HbldoL2oK";
        sshKey = "${config.aquaris.secret "nixremote/key"}";

        maxJobs = 4;
        speedFactor = 4;

        system = "aarch64-linux";
        supportedFeatures = [
          "benchmark"
          "big-parallel"
          "gccarch-armv8-a"
          "kvm"
          "nixos-test"
        ];
      }];
    };
  };
}
