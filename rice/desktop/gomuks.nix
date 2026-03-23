{ pkgs, lib, config, ... }:
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

    virtualisation.pnoc = {
      gomuks-web = {
        path = with pkgs; [ gomuks-web-2603 ];

        script = ''
          exec gomuks-web << EOF
          admin
          admin
          EOF
        '';

        environment.GOMUKS_ROOT = "/data";
        ports = [ "29325:29325" ];
        volumes = [ "gomuks-web:/data" ];
      };
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
