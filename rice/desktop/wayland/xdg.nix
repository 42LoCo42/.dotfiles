{ pkgs, lib, config, ... }: lib.mkIf config.rice.desktop {
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  home-manager.sharedModules = [{
    home.packages = with pkgs; [
      xdg-utils
    ];

    # used to store device access permissions
    aquaris.persist = [ ".local/share/flatpak" ];
  }];
}
