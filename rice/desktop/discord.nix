{ config, lib, pkgs, ... }: {
  options.rice.desktop.discord.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.discord.enable {
    home-manager.sharedModules = [{
      aquaris = {
        persist = {
          ".config/equibop" = { };
          ".local/state/concord" = { };
        };

        hyprland.binds = f: with f; {
          c = exec "foot -a concord concord";
          C-c = exec "equibop";
        };
      };

      programs.concord = {
        enable = true;
        settings = {
          display.media_playback = true;
          presence.share_rich_presence = false;
          updates.check_for_updates = false;
          voice.allow_microphone_transmit = true;
        };
      };

      home.packages = with pkgs; [ equibop ];

      xdg.configFile."equibop-flags.conf".text = ''
        --wayland
      '';
    }];
  };
}
