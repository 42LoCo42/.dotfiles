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
  };
}
