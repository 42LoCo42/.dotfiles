{ self, ... }: {
  aquaris.caches = [{
    url = "https://ezkea.cachix.org";
    key = "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=";
  }];

  imports = [ self.inputs.aagl.nixosModules.default ];

  aagl.enableNixpkgsReleaseBranchCheck = false;
  programs.anime-game-launcher.enable = true;
}
