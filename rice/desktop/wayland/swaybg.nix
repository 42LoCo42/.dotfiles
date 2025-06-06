{ self, aquaris, pkgs, config, lib, ... }: {
  options.rice.desktop.wayland.swaybg = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    image = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf config.rice.desktop.wayland.swaybg.enable {
    rice.desktop.wayland.swaybg.image =
      let path = "${self}/machines/${aquaris.name}/wallpaper.webp"; in
      lib.mkIf (builtins.pathExists path) (builtins.path { inherit path; });

    home-manager.sharedModules = [{
      systemd.user.services.swaybg = {
        Install.WantedBy = [ "graphical-session.target" ];
        Service.ExecStart = ''
          ${lib.getExe pkgs.swaybg} -i ${config.rice.desktop.wayland.swaybg.image}
        '';
      };
    }];
  };
}
