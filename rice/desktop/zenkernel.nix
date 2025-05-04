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
      default = pkgs;

      # default = import (builtins.getFlake "github:nixos/nixpkgs/<rev>")
      #   { inherit (pkgs) system config; };
    };
  };

  config = mkIf config.rice.desktop.zenkernel.enable {
    boot = {
      kernelPackages = cfg.pkgs.linuxPackages_zen;
      zfs.package = cfg.pkgs.zfs_unstable;
    };
  };
}
