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

      # default = (import (builtins.fetchTarball {
      #   url = "https://github.com/nixos/nixpkgs/tarball/";
      #   sha256 = "";
      # })) {
      #   inherit (pkgs) config;
      #   inherit (pkgs.stdenv) system;
      # };
    };
  };

  config = mkIf config.rice.desktop.zenkernel.enable {
    boot = {
      kernelPackages = cfg.pkgs.linuxPackages_zen;
      zfs.package = cfg.pkgs.zfs_2_4;
    };
  };
}
