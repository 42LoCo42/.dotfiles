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
                if [ -n "$city" ]; then
                  loc="$(curl -fsSLG                             \
                    'https://nominatim.openstreetmap.org/search' \
                    -d format=jsonv2 -d "city=$city"             \
                    | jq -r '.[0] | "\(.lat),\(.lon)"')"
                else
                  res="$(curl -fsSL https://ipinfo.io)"
                  loc="$(jq -r .loc <<< "$res")"
                  echo "Found you in $(jq -r .city <<< "$res")!"
                fi

                exec wego --backend pirateweather.net "$loc"
              '';
            })
          ];

          sessionVariables.WEGORC = "$HOME/.config/wego.ini";

          activation.configureWego = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if KEY="$(< "/run/secrets/user/$USER/weather")"; then
              echo "pirateweather-api-key=$KEY" > "$HOME/.config/wego.ini"
            else
              echo "No Pirate Weather API key set, aborting wego configuration!" >&2
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
