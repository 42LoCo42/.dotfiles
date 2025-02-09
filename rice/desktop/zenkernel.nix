{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool raw;

  cfg = config.rice.desktop.zenkernel;

  src = pkgs.fetchFromGitHub {
    owner = "nixos";
    repo = "nixpkgs";
    rev = "852ff1d9e153d8875a83602e03fdef8a63f0ecf8";
    hash = "sha256-Zf0hSrtzaM1DEz8//+Xs51k/wdSajticVrATqDrfQjg=";
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
      default = { };
    };

    config = mkOption {
      type = raw;
      default = { };
    };
  };

  config = mkIf config.rice.desktop.zenkernel.enable {
    rice.desktop.zenkernel = {
      pkgs = import src {
        inherit (pkgs) system;
        inherit (cfg) config;
      };
    };

    boot = {
      kernelPackages = cfg.pkgs.linuxPackages_zen;
      zfs.package = cfg.pkgs.zfs_unstable;
    };
  };
}
