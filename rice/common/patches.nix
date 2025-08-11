{ self, ... }: {
  nixpkgs.overlays = [
    (pkgs': pkgs:
      let obscura = self.inputs.obscura.packages.${pkgs.system}; in {
        googleearth-pro = pkgs.googleearth-pro.override {
          libxml2 = pkgs.runCommand "libxml2.so.2" { } ''
            install -Dm555                       \
              ${pkgs.libxml2.out}/lib/libxml2.so \
              $out/lib/libxml2.so.2
          '';
        };

        pocket-id = pkgs.pocket-id.overrideAttrs (final: old: {
          version = "1.7.0";

          src = pkgs.fetchFromGitHub {
            inherit (old.src) owner repo;
            tag = "v${final.version}";
            hash = "sha256-u4H1wC5RL3p7GNL7WQkmK8DNgwKQvgxHd8TIug+Be+o=";
          };

          vendorHash = "sha256-guG/JnwUi2WeClSfAX9pRG3kLJMTvTDiJ7L54TGeSd0=";

          frontend = pkgs.stdenv.mkDerivation (x: {
            inherit (old.frontend) pname installPhase;
            inherit (final) version src;

            nativeBuildInputs = with pkgs; [
              nodejs
              pnpm.configHook
            ];

            pnpmDeps = pkgs.pnpm.fetchDeps {
              inherit (x) pname version src;
              fetcherVersion = 2;
              hash = "sha256-Yrx3M78OFPuxsuhe74vYSRAsAuMAfRh8ruVlhp7lyiQ=";
            };

            env.BUILD_OUTPUT_PATH = "../dist";

            buildPhase = "pnpm run build";
          });
        });

        ########## obscura inclusion ##########

        inherit (obscura)
          avahi-proxy
          caddyfile-language-server
          chronometer
          drasl
          email-oauth2-proxy
          ferroxide
          flameshot-grim
          glfw3-minecraft-extra
          ncps-db-helper
          pinlist
          pug
          rustdesk-api
          socket-activate
          vencloud
          zfullfs
          ;
      })
  ];
}
