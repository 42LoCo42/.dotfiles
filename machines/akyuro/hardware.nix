{ modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "uas" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  networking.interfaces.wlp2s0.useDHCP = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}
