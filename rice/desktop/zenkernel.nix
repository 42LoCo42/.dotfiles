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
        url = "https://github.com/nixos/nixpkgs/tarball/8913c168d1c56dc49a7718685968f38752171c3b";
        sha256 = "sha256-TXnlsVb5Z8HXZ6mZoeOAIwxmvGHp1g4Dw89eLvIwKVI=";
      })) { inherit (pkgs) system config; };
    };
  };

  config = mkIf config.rice.desktop.zenkernel.enable {
    boot = {
      kernelPackages = cfg.pkgs.linuxPackages_zen;
      zfs.package = cfg.pkgs.zfs_2_3;
    };
  };
}
