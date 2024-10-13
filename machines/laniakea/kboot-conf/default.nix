{ config, lib, pkgs, ... }:
let
  inherit (lib) getExe mkIf mkOption;
  inherit (lib.types) bool path;
  cfg = config.boot.loader.kboot-conf;
in
{
  options.boot.loader.kboot-conf = {
    enable = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether to create petitboot-compatible /kboot.conf
      '';
    };

    boot = mkOption {
      type = path;
      default = "/boot";
      description = "Path to the boot partition mountpoint";
    };

    dest = mkOption {
      type = path;
      default = "/nixos";
      description = "Subdirectory of /boot to place boot files in";
    };
  };

  config = mkIf cfg.enable {
    boot.loader = {
      systemd-boot.enable = false;

      external = {
        enable = true;
        installHook = getExe (pkgs.writeShellApplication {
          name = "kboot";

          runtimeEnv = {
            BOOT = config.boot.loader.kboot-conf.boot;
            DEST = config.boot.loader.kboot-conf.dest;

            DTB = config.hardware.deviceTree.name;
          };

          runtimeInputs = with pkgs; [ rsync ];

          text = builtins.readFile ./generate-kboot-conf.sh;
        });
      };
    };
  };
}
