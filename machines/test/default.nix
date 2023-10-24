{ self, nixpkgs }@args: nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = args;
  modules = [
    ./disk.nix
    ./hardware.nix
    self.inputs.home-manager.nixosModules.home-manager
    self.inputs.disko.nixosModules.disko

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

      # virtualisation.docker = {
      #   enable = true;
      #   storageDriver = "zfs";
      # };
    })
  ];
}
