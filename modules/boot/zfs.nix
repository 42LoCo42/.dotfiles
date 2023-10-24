{ config, lib, ... }: {
  imports = [
    ./default.nix
  ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelPackages = lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;
  };
}