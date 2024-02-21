{ modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" ];

  networking.interfaces.enp0s6.useDHCP = true;
  # nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.hostPlatform = "x86_64-linux"; # TODO
}
