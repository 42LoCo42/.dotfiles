{ config, lib, pkgs, self, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;

  mvs = import self.inputs.obscura.inputs.multiverse {
    inherit (pkgs) config;
    inherit (pkgs.stdenv) system;
  };

  pkgs' = mvs.at (mvs.revOf "linux_zen" "7.2.15");
in
{
  options.rice.desktop.zenkernel.enable = mkOption {
    type = bool;
    default = false;
  };

  config = mkIf config.rice.desktop.zenkernel.enable {
    boot = {
      kernelPackages = pkgs'.linuxPackages_zen;

      zfs = {
        package = pkgs'.zfs;
        forceImportRoot = true;
      };
    };
  };
}
