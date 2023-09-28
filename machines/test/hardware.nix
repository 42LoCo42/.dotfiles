{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "rpool/nixos";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9BA4-9C24";
    fsType = "vfat";
  };

  networking.interfaces.enp1s0.useDHCP = true;
  nixpkgs.hostPlatform = "x86_64-linux";
}
