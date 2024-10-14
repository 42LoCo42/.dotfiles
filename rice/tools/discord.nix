{
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
}
