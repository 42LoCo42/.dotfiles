{ pkgs, lib, config, ... }: {
  options.rice.desktop.theming.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.theming.enable {
    home-manager.sharedModules = [
      (hm: {
        gtk = {
          enable = true;

          theme = {
            name = "Gruvbox-Dark";
            package = pkgs.gruvbox-gtk-theme;
          };

          iconTheme = {
            name = "Adwaita";
            package = pkgs.adwaita-icon-theme;
          };

          gtk2.configLocation =
            "${hm.config.xdg.configHome}/gtk-2.0/settings.ini";
        };

        qt = {
          enable = true;
          platformTheme.name = "gtk3";
        };

        home = {
          pointerCursor = {
            name = "Vanilla-DMZ";
            size = 24;
            package = pkgs.vanilla-dmz;
            gtk.enable = true;
          };

          packages = with pkgs; [
            qt5.qtwayland
            qt6.qtwayland
          ];
        };
      })
    ];
  };
}
