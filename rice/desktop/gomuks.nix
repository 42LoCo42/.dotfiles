{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkIf
    mkOption
    singleton
    ;

  inherit (lib.types)
    bool;

  cfg = config.rice.desktop.gomuks;
in
{
  options.rice.desktop.gomuks.enable = mkOption {
    type = bool;
    default = false;
  };

  config = mkIf cfg.enable {
    rice.insecureNames = [ "olm" ];

    aquaris.persist.dirs = {
      "/var/lib/private/gomuks-web" = { };
    };

    systemd.services.gomuks-web = {
      path = with pkgs; [ gomuks-web ];
      script = ''
        export GOMUKS_ROOT="$STATE_DIRECTORY"
        exec gomuks-web << EOF
        admin
        admin
        EOF
      '';

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "gomuks-web";
      };

      wantedBy = [ "default.target" ];
    };

    home-manager.sharedModules = singleton (hm: {
      aquaris.firefox.sanitize.exceptions = [
        "http://localhost:29325"
      ];

      home = {
        sessionVariables.GOMUKS_ROOT = "/persist/home/${hm.config.home.username}/gomuks";
        packages = with pkgs; [ gomuks ];
      };
    });
  };
}
