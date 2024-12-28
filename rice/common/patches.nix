{
  nixpkgs.overlays = [
    (_: pkgs: {
      pam_rssh = pkgs.pam_rssh.overrideAttrs
        (old: {
          patches = (old.patches or [ ]) ++ [
            # TODO https://github.com/z4yx/pam_rssh/pull/24
            (pkgs.fetchpatch {
              url = "https://github.com/z4yx/pam_rssh/pull/24.patch";
              hash = "sha256-B0FpqhrJuFJ8OoakzCrL4OVy4njV0WsMWWtcDQ7BieY=";
            })
          ];
        });
    })
  ];
}
