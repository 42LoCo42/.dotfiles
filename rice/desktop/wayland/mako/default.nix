{ self, pkgs, lib, config, aquaris, ... }: {
  options.rice.desktop.wayland.mako.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.wayland.mako.enable {
    home-manager.sharedModules = [{
      imports = map (x: "${self.inputs.home-manager}/modules/${x}") [
        "services/mako.nix"
      ];

      services.mako = {
        enable = true;

        settings = {
          default-timeout = "5000";
          layer = "overlay";

          "urgency=critical" = {
            default-timeout = "0";
            border-color = "#d30706";
            background-color = "#f09b00";
            text-color = "#000000";
          };

          "app-name=flameshot" = {
            invisible = "true";
          };
        };
      };

      xdg = {
        configFile."mako/config".onChange = ''
          export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
        '';

        dataFile."dbus-1/services/mako-path-fix.service".text =
          aquaris.lib.subsT ./path-fix.service {
            mako = lib.getExe pkgs.mako;
          };
      };

      home.packages = with pkgs; [
        libnotify
      ];
    }];
  };
}
