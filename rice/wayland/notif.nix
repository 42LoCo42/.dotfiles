{ pkgs, lib, aquaris, ... }: {
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

    xdg.dataFile."dbus-1/services/mako-path-fix.service".text =
      aquaris.lib.subsT ./files/mako-path-fix.service {
        mako = lib.getExe pkgs.mako;
      };

    home.packages = with pkgs; [
      libnotify
    ];
  }];
}
