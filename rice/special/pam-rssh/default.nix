{ lib, config, ... }: {
  options.rice.pam-rssh.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.pam-rssh.enable {
    security.pam = {
      rssh = {
        enable = true;
        settings.cue = true;
      };

      services.sudo.rssh = true;
    };

    home-manager.sharedModules = [{
      home.file.".ssh/rc".source = ./ssh-rc.sh;
    }];
  };
}
