{ config, lib, pkgs, ... }: {
  options.rice.desktop.theming.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.theming.enable {
    home-manager.sharedModules = [
      (hm: {
        gtk = rec {
          enable = true;

          colorScheme = "dark";

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

          gtk4 = { inherit theme; };
        };

        qt = {
          enable = true;
          platformTheme.name = "gtk3";
        };

        home = {
          pointerCursor = {
            enable = true;
            gtk.enable = true;

            package = pkgs.vanilla-dmz;
            name = "Vanilla-DMZ";
            size = 24;
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
