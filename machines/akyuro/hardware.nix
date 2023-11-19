{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/94c3d965-4168-4ccf-b4f6-7c8108f97de8";
    fsType = "btrfs";
    options = [ "compress-force=zstd" "subvol=root" ];
  };

  boot.initrd.luks.devices."luks-8ddd25c7-ec1a-4506-bd3a-a145b9b2c581".device = "/dev/disk/by-uuid/8ddd25c7-ec1a-4506-bd3a-a145b9b2c581";

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/94c3d965-4168-4ccf-b4f6-7c8108f97de8";
    fsType = "btrfs";
    options = [ "compress-force=zstd" "subvol=nix" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/94c3d965-4168-4ccf-b4f6-7c8108f97de8";
    fsType = "btrfs";
    options = [ "compress-force=zstd" "subvol=home" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5AE0-2C6C";
    fsType = "vfat";
  };

  networking.interfaces."wlp2s0".useDHCP = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}
