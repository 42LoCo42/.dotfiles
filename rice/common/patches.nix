{ self, ... }: {
  nixpkgs.overlays = [
    (_: pkgs:
      let obscura = self.inputs.obscura.packages.${pkgs.system}; in {
        pam_rssh = pkgs.pam_rssh.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            inherit (old.src) owner repo fetchSubmodules;
            rev = "083d69962084a1515b357009bd26407a9c47b67c";
            hash = "sha256-VxbaxqyIAwmjjbgfTajqwPQC3bp7g/JNVNx9yy/3tus=";
          };
        });

        inherit (obscura)
          avh
          chronometer
          ferroxide
          flameshot-grim
          ncps-db-helper
          photoview
          pinlist
          pug
          vencloud
          zfullfs
          ;

        foot = obscura.foot-transparent;
      })
  ];
}
