{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool raw;

  cfg = config.rice.desktop.zenkernel;
in
{
  options.rice.desktop.zenkernel = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    pkgs = mkOption {
      type = raw;
      # default = pkgs;

      default = (import (builtins.fetchTarball {
        url = "https://github.com/nixos/nixpkgs/tarball/3e3afe5174c561dee0df6f2c2b2236990146329f";
        sha256 = "sha256-frdhQvPbmDYaScPFiCnfdh3B/Vh81Uuoo0w5TkWmmjU=";
      })) { inherit (pkgs) system config; };
    };
  };

  config = mkIf config.rice.desktop.zenkernel.enable {
    boot = {
      kernelPackages = cfg.pkgs.linuxPackages_zen;
      zfs.package = cfg.pkgs.zfs_unstable;
    };
  };
}
