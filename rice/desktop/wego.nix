{ config, lib, pkgs, ... }:
let
  inherit (lib) flip mapAttrs' mkIf mkOption;
  inherit (lib.types) bool;

  cfg = config.rice.desktop.wego;
in
{
  options.rice.desktop.wego = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      ({ lib, ... }: {
        home = {
          packages = with pkgs; [
            wego
            (pkgs.writeShellApplication {
              name = "w";
              text = ''
                set -euo pipefail

                city="''${1-}"
                if [ -z "$city" ]; then
                  city="$(curl -fsSL https://ipinfo.io | jq -r .city)"
                fi

                exec wego "$city"
              '';
            })
          ];

          sessionVariables.WEGORC = "$HOME/.config/wego.ini";

          activation.configureWego = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if KEY="$(< "/run/secrets/user/$USER/owm")"; then
              echo "owm-api-key=$KEY" > "$HOME/.config/wego.ini"
            else
              echo "No OWM API key set, aborting wego configuration!" >&2
            fi
          '';
        };
      })
    ];

    # TODO move this to aquaris?
    systemd.services = flip mapAttrs' config.aquaris.users
      (name: _: {
        name = "home-manager-${name}";
        value = {
          after = [ "secrets-access-extra.service" ];
          wants = [ "secrets-access-extra.service" ];
        };
      });
  };
}
