{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool raw;

  cfg = config.rice.desktop.zenkernel;

  zfs_2_4 = { callPackage, ... }@args:
    callPackage "${cfg.pkgs.path}/pkgs/os-specific/linux/zfs/generic.nix" args {
      kernelModuleAttribute = "zfs_2_4";

      kernelMinSupportedMajorMinor = "4.18";
      kernelMaxSupportedMajorMinor = "6.18";

      version = "2.4.0";

      tests = { };

      hash = "sha256-v78Tn1Im9h8Sjd4XACYesPOD+hlUR3Cmg8XjcJXOuwM=";
    };
in
{
  options.rice.desktop.zenkernel = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    pkgs = mkOption {
      type = raw;
      default = pkgs;

      # default = (import (builtins.fetchTarball {
      #   url = "https://github.com/nixos/nixpkgs/tarball/";
      #   sha256 = "";
      # })) {
      #   inherit (pkgs) config;
      #   inherit (pkgs.stdenv.hostPlatform) system;
      # };
    };
  };

  config = mkIf config.rice.desktop.zenkernel.enable {
    boot = {
      kernelPackages = cfg.pkgs.linuxPackages_zen.extend (_: prev: {
        zfs_2_4 = cfg.pkgs.callPackage zfs_2_4 {
          configFile = "kernel";
          inherit (prev) kernel;
        };
      });

      zfs.package = cfg.pkgs.callPackage zfs_2_4 {
        configFile = "user";
      };
    };
  };
}
