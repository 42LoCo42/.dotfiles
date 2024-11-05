{
  nixpkgs.overlays = [
    (_: pkgs: {
      # https://github.com/NixOS/nixpkgs/pull/353362/files
      wf-recorder = pkgs.wf-recorder.overrideAttrs {
        patches = [
          # compile fixes from upstream, TODO remove when they stop applying
          (pkgs.fetchpatch {
            url = "https://github.com/ammen99/wf-recorder/commit/560bb92d3ddaeb31d7af77d22d01b0050b45bebe.diff";
            sha256 = "sha256-7jbX5k8dh4dWfolMkZXiERuM72zVrkarsamXnd+1YoI=";
          })
        ];
      };
    })
  ];
}
