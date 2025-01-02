{ pkgs, lib, config, ... }: {
  options.rice.desktop.wayland.sway-audio-idle-inhibit.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.wayland.sway-audio-idle-inhibit.enable {
    home-manager.sharedModules = [{
      systemd.user.services.sway-audio-idle-inhbit = {
        Install.WantedBy = [ "graphical-session.target" ];
        Service.ExecStart = lib.getExe pkgs.sway-audio-idle-inhibit;
      };
    }];
  };
}
