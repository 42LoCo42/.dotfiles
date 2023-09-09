{ ... }: {
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      nerdfonts = prev.nerdfonts.override {
        fonts = [ "Iosevka" ];
      };
    })
  ];
}
