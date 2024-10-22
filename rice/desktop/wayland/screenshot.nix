{ pkgs, lib, config, ... }: lib.mkIf config.rice.desktop {
  nixpkgs.overlays = [
    (_: pkgs: {
      flameshot = pkgs.writeShellApplication {
        name = "flameshot";
        text = ''
          export XDG_CURRENT_DESKTOP=sway
          ${lib.getExe pkgs.flameshot} gui -r | wl-copy
        '';
      };
    })
  ];

  home-manager.sharedModules = [{
    home.packages = with pkgs; [
      flameshot
      grim
      wl-clipboard
    ];
  }];
}
