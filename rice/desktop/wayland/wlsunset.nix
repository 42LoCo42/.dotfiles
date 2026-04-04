{ self, pkgs, lib, config, ... }:
let
  inherit (lib) getExe mkForce;
  cfg = config.rice.desktop.wayland.wlsunset;
in
{
  options.rice.desktop.wayland.wlsunset = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    lat = lib.mkOption {
      type = lib.types.str;
    };

    lon = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [{
      imports = map (x: "${self.inputs.home-manager}/modules/${x}") [
        "services/hyprsunset.nix"
      ];

      services.hyprsunset.enable = true;

      systemd.user.services.wlsunset = {
        Install.WantedBy = [ "graphical-session.target" ];

        Unit = {
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service.ExecStart = mkForce [
          (getExe (pkgs.writeShellApplication {
            name = "wlsunset-via-hyprsunset";

            runtimeInputs = with pkgs; [
              hyprland
              wlsunset
            ];

            text = ''
              wlsunset -l ${cfg.lat} -L ${cfg.lon} |& sed -Enu        \
                's|.* ([0-9]+) K|hyprctl hyprsunset temperature \1|p' \
              | bash -x
            '';
          }))
        ];
      };
    }];
  };
}
