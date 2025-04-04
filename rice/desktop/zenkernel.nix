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

      # TODO wait for ZFS 2.3.2
      # ZFS 2.3.1 @ KRN 6.13.5-zen1
      default = import (builtins.getFlake "github:nixos/nixpkgs/6607cf789e541e7873d40d3a8f7815ea92204f32")
        { inherit (pkgs) system config; };
    };
  };

  config = mkIf config.rice.desktop.zenkernel.enable {
    boot = {
      kernelPackages = cfg.pkgs.linuxPackages_zen;
      zfs.package = cfg.pkgs.zfs_unstable;
    };
  };
}
