{ lib, config, ... }: lib.mkIf config.rice.desktop {
  nixpkgs.overlays = [
    (_: pkgs: {
      firefox = pkgs.firefox.override { cfg.speechSynthesisSupport = false; };
    })
  ];

  # TODO build declarative ffox config
  home-manager.sharedModules = [{
    programs.firefox.enable = true;
  }];
}
