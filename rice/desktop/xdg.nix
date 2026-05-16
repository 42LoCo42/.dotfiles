{ pkgs, lib, config, ... }: {
  options.rice.desktop.xdg.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.xdg.enable {
    home-manager.sharedModules = [{
      # used to store device access permissions
      aquaris.persist = { ".local/share/flatpak" = { }; };

      home.packages = with pkgs; [ xdg-utils ];

      xdg = {
        portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-hyprland
            xdg-desktop-portal-gtk
          ];
        };

        systemDirs.data = with pkgs; map glib.getSchemaDataDirPath [
          gsettings-desktop-schemas
          gtk3
        ];
      };
    }];
  };
}
