{ pkgs, lib, config, self, ... }: {
  options.rice.desktop.wayland.flameshot.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.wayland.flameshot.enable {
    nixpkgs.overlays = [
      (_: pkgs: {
        flameshot-run = pkgs.writeShellApplication {
          name = "flameshot-run";
          text = ''
            export XDG_CURRENT_DESKTOP=sway
            ${lib.getExe self.inputs.obscura.packages.${pkgs.system}.flameshot-grim} gui -r | wl-copy
          '';
        };
      })
    ];

    home-manager.sharedModules = [{
      home.packages = with pkgs; [
        flameshot-run
        wl-clipboard
      ];
    }];
  };
}
