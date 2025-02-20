# TODO upstream this to Aquaris

{ pkgs, lib, config, ... }: {
  options.rice.desktop.firefox.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.firefox.enable {
    home-manager.sharedModules = [{
      aquaris.firefox = {
        enable = true;
        cleanHome = false;
      };

      programs.firefox = {
        package = lib.mkForce (pkgs.firefox.override {
          extraPrefs = builtins.readFile ./prefs.js;
        });

        policies = import ./policies.nix;
      };
    }];
  };
}
