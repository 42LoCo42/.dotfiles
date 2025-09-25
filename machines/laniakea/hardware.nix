{ modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" ];

  networking.interfaces.end0.useDHCP = true;
  systemd.network.wait-online.anyInterface = true;

  nixpkgs.hostPlatform = "aarch64-linux";
}
