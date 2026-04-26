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

        # pin flameshot to v13.3.0 because v14 removes the grim adapter
        # and the stupid dbus screenshot protocol is borked :(
        ((import (fetchTarball {
          url = "https://github.com/nixos/nixpkgs/tarball/4c1018dae018162ec878d42fec712642d214fdfa";
          sha256 = "sha256-ar3rofg+awPB8QXDaFJhJ2jJhu+KqN/PRCXeyuXR76E=";
        })) { inherit (pkgs.stdenv) system; }).flameshot

        (pkgs.writeShellApplication {
          name = "flameshot-run";
          text = ''
            flameshot gui -r | wl-copy &
            grep -m1 flameshot < <(nc -U "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock")
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
