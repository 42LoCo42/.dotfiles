{ lib, config, ... }: {
  options.rice.nixremote.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.nixremote.enable {
    programs.ssh.extraConfig = ''
      Host nixremote
        HostName exit.bunny.vpn
        Port 18213
        User nixremote
        Compression yes
        IdentityFile ${config.aquaris.secret "svc/nixremote"}
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
    '';

    nix = {
      distributedBuilds = true;
      settings.builders-use-substitutes = true;

      buildMachines = [{
        protocol = "ssh-ng";
        hostName = "nixremote";

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
