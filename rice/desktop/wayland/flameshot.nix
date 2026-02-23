{ pkgs, lib, config, ... }: {
  options.rice.desktop.wayland.flameshot.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.wayland.flameshot.enable {
    home-manager.sharedModules = [{
      home.packages = with pkgs; [
        grim
        slurp
        wl-clipboard

        (pkgs.writeShellApplication {
          name = "flameshot-run";
          text = ''
            ${lib.getExe pkgs.flameshot} gui -r | wl-copy &

            while true; do
              [ "$(hyprctl activewindow -j | jq -r .initialTitle)" = flameshot ] && break
            done
            pkill -SIGUSR1 waybar

            wait
            pkill -SIGUSR1 waybar
          '';
        })
      ];

      xdg.configFile."flameshot/flameshot.ini".text = ''
        [General]
        useGrimAdapter=true
      '';
    }];
  };
}
