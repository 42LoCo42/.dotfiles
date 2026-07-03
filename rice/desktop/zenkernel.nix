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

      default = (import (fetchTarball {
        url = "https://github.com/nixos/nixpkgs/tarball/9e09bc1f90dd4980521ff922d10d712ceb8a5a86";
        sha256 = "sha256-Ewa/O6OlwvmoR9x53Emb3rAWlhM7MLZuw1jCYhaX6sU=";
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
