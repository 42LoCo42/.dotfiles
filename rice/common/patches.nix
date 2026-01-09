{ self, ... }: {
  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.stdenv.hostPlatform.system}; in {

        factorio-space-age = prev.factorio-space-age.override {
          makeDesktopItem = { exec, ... }@args: prev.makeDesktopItem (args // {
            exec = "gamemoderun ${exec}";
          });
        };

        # TODO https://github.com/NixOS/nixpkgs/pull/476394
        # and wait for next release too
        pocket-id = prev.pocket-id.overrideAttrs (new: old: {
          version = "2.1.0-unstable-2026-01-07";

          src = prev.fetchFromGitHub {
            inherit (old.src) owner repo;
            rev = "2f25861d15aefa868042e70d3e21b7b38a6ae679";
            hash = "sha256-G1cHQ36sYT4cp+v0xZVkNKbTugbg+bwj7kedAWTTius=";
          };

          vendorHash = "sha256-hMhOG/2xnI/adjg8CnA0tRBD8/OFDsTloFXC8iwxlV0=";

          frontend = old.frontend.overrideAttrs {
            pnpmDeps = prev.fetchPnpmDeps {
              inherit (new) pname version src;
              pnpm = prev.pnpm_10;
              fetcherVersion = 1;
              hash = "sha256-dIhNxUBt+jxUp5I4cPZ6/PtNSyMTd6xkX6XE2SwD+ok=";
            };
          };
        });

        # TODO https://github.com/NixOS/nixpkgs/pull/476163
        # HACK this is merged, but it still says version 1.4.8 which is hella sus
        matrix-tuwunel = prev.stdenv.mkDerivation rec {
          pname = "matrix-tuwunel";
          version = "1.4.9.1";

          src = prev.fetchurl {
            url = "https://github.com/matrix-construct/tuwunel/releases/download/v${version}/v${version}-release-all-aarch64-v8-linux-gnu-tuwunel.zst";
            hash = "sha256-n6o3HTF+Mq7uFuBdw86sIqZMspyEEhXJOYRXSWkyM/I=";
          };
          dontUnpack = true;

          nativeBuildInputs = with prev; [ zstd ];

          buildPhase = "unzstd $src -o tuwunel";
          installPhase = "install -Dm755 {,$out/bin/}tuwunel";

          meta.mainProgram = "tuwunel";
        };

        ########## obscura inclusion ##########

        inherit (obscura)
          avahi-proxy
          caddyfile-language-server
          chronometer
          datetime
          drasl
          eka
          ferroxide
          immich-folder-album-creator
          papra
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
