{
  nixpkgs.overlays = [
    (_: pkgs: {
      # no patches required, yay!
    })
  ];
}
