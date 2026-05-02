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
      #default = pkgs;

      default = (import (builtins.fetchTarball {
        url = "https://github.com/nixos/nixpkgs/tarball/0726a0ecb6d4e08f6adced58726b95db924cef57";
        sha256 = "sha256-EHq1/OX139R1RvBzOJ0aMRT3xnWyqtHBRUBuO1gFzjI=";
      })) {
        inherit (pkgs) config;
        inherit (pkgs.stdenv) system;
      };
    };
  };

  config = mkIf config.rice.desktop.zenkernel.enable {
    boot = {
      kernelPackages = cfg.pkgs.linuxPackages_zen;

      zfs = {
        package = cfg.pkgs.zfs;
        forceImportRoot = true;
      };
    };
  };
}
