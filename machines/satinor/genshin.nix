{ self, pkgs, lib, ... }: {
  aquaris.caches = [{
    url = "https://ezkea.cachix.org";
    key = "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=";
  }];

  imports = [ self.inputs.aagl.nixosModules.default ];

  aagl.enableNixpkgsReleaseBranchCheck = false;

  programs.anime-game-launcher = {
    enable = true;
    package = let
      nam = "anime-game-launcher";
      pkg = pkgs.${nam};

      wrapper = (pkgs.runCommand "${nam}-wrapped" {
        nativeBuildInputs = with pkgs; [ makeWrapper ];
      }) ''
        mkdir -p $out/{bin,share/{applications,pixmaps}}

        makeWrapper ${lib.getExe pkg} $out/bin/${pkg.pname} \
          --set-default LAUNCHER_FOLDER /persist/home/ercanar/genshin

        sed "s|/nix/store/.*|$out/bin/${nam}|"     \
          ${pkg}/share/applications/${nam}.desktop \
          > $out/share/applications/${nam}.desktop

        cp ${pkg}/share/pixmaps/* $out/share/pixmaps/
      '';
    in wrapper;
  };
}
