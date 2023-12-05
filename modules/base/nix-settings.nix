{ self, lib, ... }: {
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://42loco42.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "42loco42.cachix.org-1:6HvWFER3RdTSqEZDznqahkqaoI6QCOiX2gRpMMsThiQ="
    ];
  };

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  environment.etc."nix/channel".source = self.inputs.nixpkgs.outPath;
  nix.nixPath = lib.mkForce [ "nixpkgs=/etc/nix/channel" ];
  nix.registry = lib.pipe "${self}/flake.lock" [
    builtins.readFile
    builtins.fromJSON
    (lock: builtins.mapAttrs
      (_: name: {
        to = lock.nodes.${name}.locked;
      })
      lock.nodes.root.inputs)
  ];

  nixpkgs.overlays = [
    (final: prev: {
      nerdfonts = prev.nerdfonts.override {
        fonts = [ "Iosevka" ];
      };
    })
  ];
}
