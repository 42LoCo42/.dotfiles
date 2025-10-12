{ lib, config, ... }:
let
  inherit (lib) filter ifEnable mkIf mkMerge mkOption;
  inherit (lib.types) bool;

  cfg = config.rice.nixremote;

  base = ''
    User nixremote
    Compression yes
    IdentityFile ${config.aquaris.secret "svc/nixremote"}
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
  '';
in
{
  options.rice.nixremote = {
    act = mkOption {
      description = "Act like a Nix remote builder";
      type = bool;
      default = false;
    };

    use = mkOption {
      description = "Use the Nix remote builders";
      type = bool;
      default = false;
    };
  };

  config = mkMerge [
    (mkIf cfg.act {
      users = {
        users.nixremote = {
          isSystemUser = true;
          useDefaultShell = true;

          group = "nixremote";

          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEKVzQKnlm3NiBbK2l4zhJfxWZH2zuuXD46V3cWUfg5"
          ];
        };

        groups.nixremote = { };
      };

      nix.settings.trusted-users = [ "nixremote" ];
    })

    (mkIf cfg.use {
      programs.ssh.extraConfig = ''
        Host nixremote-satinor
        HostName satinor.bunny.vpn
        ${base}

        Host nixremote-bunny
        HostName exit.bunny.vpn
        Port 18213
        ${base}
      '';

      nix = {
        distributedBuilds = true;
        settings.builders-use-substitutes = true;

        buildMachines = filter (x: x != { }) [
          (ifEnable (config.system.name != "satinor") {
            protocol = "ssh-ng";
            hostName = "nixremote-satinor";

            maxJobs = 16;
            speedFactor = 16;

            system = "x86_64-linux";
            supportedFeatures = [
              "benchmark"
              "big-parallel"
              "kvm"
              "nixos-test"
            ];
          })

          (ifEnable (config.system.name != "bunny") {
            protocol = "ssh-ng";
            hostName = "nixremote-bunny";

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
          })
        ];
      };
    })
  ];
}
