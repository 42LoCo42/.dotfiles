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

        waybar = obscura.waybar-ipfix;

        inherit (obscura)
          avh
          caddyfile-language-server
          chronometer
          ferroxide
          flameshot-grim
          glfw3-minecraft-extra
          lix-fix-help
          ncps-db-helper
          photoview
          pinlist
          pug
          socket-activate
          vencloud
          zfullfs
          ;

        foot = obscura.foot-transparent;
      })
  ];
}
