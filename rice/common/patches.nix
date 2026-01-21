{ self, ... }: {
  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in {
        factorio-space-age = prev.factorio-space-age.override {
          makeDesktopItem = { exec, ... }@args: prev.makeDesktopItem (args // {
            exec = "gamemoderun ${exec}";
          });
        };

        # TODO https://hydra.nixos.org/job/nixpkgs/unstable/librewolf-unwrapped.x86_64-linux
        # 147.0-1 fails to build; fallback to 146.0.1-1
        inherit ((import (builtins.fetchTarball {
          url = "https://github.com/nixos/nixpkgs/tarball/e4bae1bd10c9c57b2cf517953ab70060a828ee6f";
          sha256 = "sha256-Kell/SpJYVkHWMvnhqJz/8DqQg2b6PguxVWOuadbHCc=";
        })) { inherit (prev.stdenv) system; }) librewolf-unwrapped;

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
