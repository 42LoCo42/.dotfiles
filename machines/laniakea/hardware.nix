{ modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" ];

  networking.interfaces.end0.useDHCP = true;
  networking.interfaces.wlu1.useDHCP = true;

  nixpkgs.hostPlatform = "aarch64-linux";
}
