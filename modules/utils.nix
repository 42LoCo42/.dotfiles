{ nixpkgs, home-manager }: system:
let pkgs = import nixpkgs { inherit system; }; in {
  my-utils = {
    mkHomeLinks = pairs: pkgs.lib.pipe pairs [
      (map (pair: ''
        mkdir -p "${dirOf pair.dst}"
        ln -sfT "${pair.src}" "${pair.dst}"
      ''))
      (builtins.concatStringsSep "\n")
      (home-manager.lib.hm.dag.entryAfter [ "linkGeneration" ])
    ];

    lanza = import (pkgs.fetchFromGitHub {
      owner = "nix-community";
      repo = "lanzaboote";
      rev = "v0.3.0";
      hash = "sha256-Fb5TeRTdvUlo/5Yi2d+FC8a6KoRLk2h1VE0/peMhWPs=";
    });
  };
}
