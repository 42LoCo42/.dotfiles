{ self, nixpkgs }@args: nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = args;
  modules = [
    ./disk.nix
    ./hardware.nix

    self.inputs.disko.nixosModules.disko
    self.inputs.home-manager.nixosModules.home-manager
    self.inputs.impermanence.nixosModules.impermanence

    "${self}/modules/base/all.nix"
    "${self}/modules/boot/zfs.nix"
    "${self}/modules/home/terminal.nix"
    "${self}/modules/networking/default.nix"

    ({ lib, ... }: {
      _module.args.nixinate = {
        host = "192.168.122.66";
        sshUser = "leonsch";
        buildOn = "remote";
        hermetic = false;
      };

      networking = {
        hostName = "test";
        hostId = "a5d4deab";

        networkmanager.enable = lib.mkForce false;
      };

      fileSystems."/persist".neededForBoot = true;
      environment.persistence."/persist" = {
        directories = [
          "/var/log/"
        ];
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ];
      };

      virtualisation.docker = {
        enable = true;
        storageDriver = "zfs";
      };
    })
  ];
}
