{ self, ... }: {
  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in {
        factorio-space-age = prev.factorio-space-age.override {
          makeDesktopItem = { exec, ... }@args: prev.makeDesktopItem (args // {
            exec = "gamemoderun ${exec}";
          });
        };

        syncplay = prev.syncplay.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            rm $out/share/applications/syncplay-server.desktop
            sed -Ei 's|(Exec=syncplay .*)|\1 --no-store|' \
              $out/share/applications/syncplay.desktop
          '';
        });

        prettypst = prev.prettypst.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ./prettypst-hline.patch
          ];
        });

        # https://pr-tracker.bunny/?pr=483247
        searxng = prev.searxng.overrideAttrs (old: {
          pythonRelaxDeps = old.pythonRelaxDeps ++ [ "markdown-it-py" ];
        });

        # TODO wait for nixpkgs
        matrix-tuwunel = prev.matrix-tuwunel.overrideAttrs (new: old: {
          version = "1.5.0";

          src = prev.fetchFromGitHub {
            inherit (old.src) owner repo;
            tag = "v${new.version}";
            hash = "sha256-9+a26OnmnjiR0K26YoKMQ2Vq8umJlwpz22a2eVBwaOk=";
          };

          # HACK we need a permanent solution for this :/
          patches = (old.patches or [ ]) ++ [ ./tuwunel-sso.patch ];

          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            inherit (new) src patches;
            hash = "sha256-Yi+JEo7+17WnpFyblTLecmozfwTwPc20c6MlfSMIFAY=";
          };

          doCheck = false;
        });

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
