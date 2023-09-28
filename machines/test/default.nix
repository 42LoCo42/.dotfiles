{ self, nixpkgs }@args: nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = args;
  modules = [
    ./hardware.nix
    self.inputs.home-manager.nixosModules.home-manager

    "${self}/modules/base/all.nix"
    "${self}/modules/boot/zfs.nix"
    "${self}/modules/home/terminal.nix"
    "${self}/modules/networking/default.nix"

    ({ lib, ... }: {
      networking = {
        hostName = "test";
        hostId = "a5d4deab";

        networkmanager.enable = lib.mkForce false;
      };
    })
  ];
}
