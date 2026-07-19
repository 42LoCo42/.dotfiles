{ config, lib, self, ... }:
let
  inherit (lib)
    mkIf
    mkOption
    ;
  inherit (lib.types)
    bool
    nullOr
    str
    ;

  cfg = config.rice.syncthing;
in
{
  options.rice.syncthing = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    url = mkOption {
      type = nullOr str;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    topology.self.services.syncthing = {
      name = "Syncthing";
      icon = "services.syncthing";
      info = "File synchronization";

      details = {
        url = mkIf (cfg.url != null) { text = cfg.url; };
      };
    };

    home-manager.sharedModules = [{
      imports = map (x: "${self.inputs.home-manager}/modules/${x}") [
        "services/syncthing.nix"
      ];

      aquaris.persist = { ".local/state/syncthing" = { }; };
      services.syncthing.enable = true;
    }];
  };
}
