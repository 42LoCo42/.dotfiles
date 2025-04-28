{ pkgs, lib, config, aquaris, ... }: {
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
      home.file.".ssh/rc".text = aquaris.lib.subsT ./ssh-rc.sh {
        nc = lib.getExe pkgs.netcat;
      };

      programs.zsh.envExtra = ''
        if [ -v TMUX ]; then export SSH_AUTH_SOCK="$HOME/.ssh/auth"; fi
      '';
    }];
  };
}
