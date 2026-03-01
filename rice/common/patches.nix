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

        # TODO triton is broken on aarch64
        # https://hydra.nixos.org/job/nixpkgs/unstable/triton-llvm.aarch64-linux
        immich-machine-learning = prev.immich-machine-learning.override {
          python3 = prev.python3.override {
            packageOverrides = (_: ppy: {
              torch = ppy.torch.override { tritonSupport = false; };
            });
          };
        };

        ########################################################################

        # matrix-tuwunel = prev.matrix-tuwunel.overrideAttrs (new: old: {
        #   # HACK we need a permanent solution for this :/
        #   patches = (old.patches or [ ]) ++ [ ./tuwunel-sso.patch ];

        #   doCheck = false;
        # });

        ########## obscura inclusion ##########

        inherit (obscura)
          avahi-proxy
          chronometer
          datetime
          drasl
          eka
          immich-folder-album-creator
          papra
          pinlist
          pug
          rustdesk-api
          socket-activate
          vencloud
          waybar-weather
          zfullfs
          ;
      })
  ];
}
