{ self, ... }: {
  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in {

        # TODO triton is broken on aarch64
        # https://hydra.nixos.org/job/nixpkgs/unstable/triton-llvm.aarch64-linux
        immich-machine-learning = prev.immich-machine-learning.override {
          python3 = prev.python3.override {
            packageOverrides = (_: ppy: {
              torch = ppy.torch.override { tritonSupport = false; };
            });
          };
        };

        # TODO hyprlandPlugins aren't compatible with 0.54.* yet
        inherit ((import (fetchTarball {
          url = "https://github.com/nixos/nixpkgs/tarball/dd9b079222d43e1943b6ebd802f04fd959dc8e61";
          sha256 = "sha256-I45esRSssFtJ8p/gLHUZ1OUaaTaVLluNkABkk6arQwE=";
        })) { inherit (prev.stdenv) system; }) hyprland hyprlandPlugins;

        ########## obscura inclusion ##########

        inherit (obscura)
          avahi-proxy
          chronometer
          datetime
          drasl
          eka
          gomuks-web-2603
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

        ########## permanent overrides ##########

        factorio-space-age = prev.factorio-space-age.override {
          makeDesktopItem = { exec, ... }@args: prev.makeDesktopItem (args // {
            exec = "gamemoderun ${exec}";
          });
        };

        syncplay = prev.syncplay.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ./syncplay-speed.patch
          ];

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
      })
  ];
}
