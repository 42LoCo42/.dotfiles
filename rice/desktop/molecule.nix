{ config, lib, pkgs, ... }: {
  options.rice.desktop.molecule.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.molecule.enable {
    home-manager.sharedModules = [{
      systemd.user.services.molecule = {
        Install.WantedBy = [ "default.target" ];

        Unit = {
          After = [ "pipewire.service" ];
          BindsTo = [ "pipewire.service" ];
        };

        Service.ExecStart = lib.getExe pkgs.molecule;
      };
    }];
  };
}
