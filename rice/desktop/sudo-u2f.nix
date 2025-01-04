{ lib, config, ... }: {
  options.rice.desktop.sudo-u2f = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    sshformat = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf config.rice.desktop.sudo-u2f.enable {
    security.pam = {
      services.sudo.u2fAuth = true;
      u2f.settings = {
        cue = true;
        inherit (config.rice.desktop.sudo-u2f) sshformat;
      };
    };
  };
}
