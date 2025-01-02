{ lib, config, ... }: {
  options.rice.desktop.vesktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.vesktop.enable {
    nixpkgs.overlays = [
      (_: pkgs: {
        vesktop = pkgs.vesktop.override {
          withSystemVencord = false;
          withTTS = false;
        };
      })
    ];

    home-manager.sharedModules = [{
      aquaris.persist = [ ".config/vesktop" ];
    }];
  };
}
