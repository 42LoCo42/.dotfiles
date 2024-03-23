{ modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_scsi" ];
  networking.interfaces.enp0s6.useDHCP = true;
  nixpkgs.hostPlatform = "aarch64-linux";
}
