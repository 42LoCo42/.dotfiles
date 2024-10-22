{ pkgs, lib, config, ... }: lib.mkIf config.rice.desktop {
  home-manager.sharedModules = [{
    systemd.user.services.sway-audio-idle-inhbit = {
      Install.WantedBy = [ "graphical-session.target" ];
      Service.ExecStart = lib.getExe pkgs.sway-audio-idle-inhibit;
    };
  }];
}
