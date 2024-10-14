{ pkgs, config, lib, ... }: {
  home-manager.sharedModules = [{
    systemd.user.services.swaybg = {
      Install.WantedBy = [ "graphical-session.target" ];
      Service.ExecStart = "${lib.getExe pkgs.swaybg} -i ${config.rice.wallpaper}";
    };
  }];
}
