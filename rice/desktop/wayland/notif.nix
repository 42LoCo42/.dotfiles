{ pkgs, lib, config, aquaris, ... }: lib.mkIf config.rice.desktop {
  home-manager.sharedModules = [{
    services.mako = {
      enable = true;
      defaultTimeout = 5000;
      layer = "overlay";
      extraConfig = ''
        [urgency=critical]
        default-timeout=0
        border-color=#d30706
        background-color=#f09b00
        text-color=#000000

        [app-name=flameshot]
        invisible=true
      '';
    };

    xdg = {
      configFile."mako/config".onChange = ''
        export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
      '';

      dataFile."dbus-1/services/mako-path-fix.service".text =
        aquaris.lib.subsT ./files/mako-path-fix.service {
          mako = lib.getExe pkgs.mako;
        };
    };

    home.packages = with pkgs; [
      libnotify
    ];
  }];
}
