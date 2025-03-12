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

        # TODO 2025-03-14: latest rustdest-flutter is broken (https://hydra.nixos.org/build/292246311)
        # monitor https://hydra.nixos.org/job/nixpkgs/trunk/rustdesk-flutter.x86_64-linux
        inherit ((builtins.getFlake "github:nixos/nixpkgs/e05f8bda630a0836d777d84de14b3c16eb758514").legacyPackages.${pkgs.system}) rustdesk-flutter;

        waybar = obscura.waybar-ipfix;

        inherit (obscura)
          avh
          caddyfile-language-server
          chronometer
          ferroxide
          flameshot-grim
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
