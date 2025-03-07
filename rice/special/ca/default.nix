{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool coercedTo package pathInStore;

  cfg = config.rice.ca;
in
{
  options.rice.ca = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    file = mkOption {
      type = coercedTo pathInStore (x: builtins.path { path = x; }) package;
      default = ./main.crt;
    };
  };

  config = mkIf cfg.enable {
    security.pki.certificateFiles = [ cfg.file ];
  };
}
