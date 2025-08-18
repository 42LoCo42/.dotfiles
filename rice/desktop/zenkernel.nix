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
        url = "https://github.com/nixos/nixpkgs/tarball/85dbfc7aaf52ecb755f87e577ddbe6dbbdbc1054";
        sha256 = "sha256-iAcj9T/Y+3DBy2J0N+yF9XQQQ8IEb5swLFzs23CdP88=";
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
