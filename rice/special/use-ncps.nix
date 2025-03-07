{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool str;

  cfg = config.rice.use-ncps;
in
{
  options.rice.use-ncps = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    url = mkOption {
      type = str;
      default = "https://laniakea.fritz.box:8501";
    };

    key = mkOption {
      type = str;
      default = "laniakea:ebQC62aslwV7HSmJCEXNxbeexbdFEXXKjHS4NPvpVf8=";
    };
  };

  config = mkIf cfg.enable {
    aquaris.caches = [{ inherit (cfg) url key; }];

    nix.settings.connect-timeout = 3;
  };
}
