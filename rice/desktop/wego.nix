{ config, lib, pkgs, ... }:
let
  inherit (lib) flip mapAttrs' mkIf mkOption;
  inherit (lib.types) bool str;

  cfg = config.rice.desktop.wego;
in
{
  options.rice.desktop.wego = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    location = mkOption {
      type = str;
      description = "Default location";
      default = "Berlin";
    };
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      ({ lib, ... }: {
        home = {
          packages = with pkgs; [ wego ];

          sessionVariables.WEGORC = "$HOME/.config/wego.ini";
          shellAliases.w = "wego";

          activation.configureWego = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if KEY="$(< "/run/secrets/user/$USER/owm")"; then
            	cat <<-EOF > "$HOME/.config/wego.ini"
            		location=${cfg.location}
            		owm-api-key=$KEY
            	EOF
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
