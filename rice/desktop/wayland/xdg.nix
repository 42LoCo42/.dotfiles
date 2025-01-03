{ pkgs, lib, config, ... }: {
  options.rice.desktop.wayland.xdg.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.wayland.xdg.enable {
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    home-manager.sharedModules = [{
      home.packages = with pkgs; [
        xdg-utils
      ];

      # used to store device access permissions
      aquaris.persist = { ".local/share/flatpak" = { }; };
    }];
  };
}
