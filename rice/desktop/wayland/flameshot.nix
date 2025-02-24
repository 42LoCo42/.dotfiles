{ pkgs, lib, config, ... }: {
  options.rice.desktop.wayland.flameshot.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.wayland.flameshot.enable {
    home-manager.sharedModules = [{
      home.packages = with pkgs; [
        wl-clipboard

        (pkgs.writeShellApplication {
          name = "flameshot-run";
          text = ''
            export XDG_CURRENT_DESKTOP=sway
            ${lib.getExe pkgs.flameshot-grim} gui -r | wl-copy
          '';
        })
      ];
    }];
  };
}
