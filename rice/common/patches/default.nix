{ self, ... }: {
  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in {

        # TODO upstream hyprlandPlugins aren't compatible with 0.54.* yet
        inherit (self.inputs.obscura.inputs.nixpkgs.legacyPackages.${prev.stdenv.system}) hyprland;
        hyprlandPlugins = obscura.my-hypr-plugins.entries;

        # TODO https://pr-tracker.bunny/?pr=502133
        ergochat = prev.ergochat.overrideAttrs (new: old: {
          version = "2.18.0";

          src = prev.fetchFromGitHub {
            inherit (old.src) owner repo;
            tag = "v${new.version}";
            hash = "sha256-6aibQ4dq3zkRoeLLrAc3OXXQWRZIQ7mPMSnWhz8LJsM=";
          };

          tags = (old.tags or [ ]) ++ [
            "i18n"
            "postgresql"
          ];
        });

        # TODO https://codeberg.org/emersion/gamja/pulls/210
        gamja = prev.gamja.overrideAttrs (new: _: {
          src = prev.fetchFromCodeberg {
            owner = "irenes";
            repo = "gamja";
            rev = "43f715ee798c8453e13cf1616b3f06e2198c3701";
            hash = "sha256-7nJxkKjZg0fIkX6nMrw07scCNEZtDyo5614rw+NeA5o=";
          };

          npmDeps = prev.fetchNpmDeps {
            inherit (new) src;
            hash = "sha256-2cahHSJq56w7GAMXZQeu9s/fgcOlEwNBoJFGxNVN75U=";
          };
        });

        ########## TODO move to obscura ##########

        hydroxide = prev.hydroxide.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ./hydroxide-pagesize.patch
          ];

          vendorHash = "sha256-8THUFE72wiWiC1CJJDShja3ucpkpAdw/D+OILj8iqMk=";
        });

        prettypst = prev.prettypst.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ./prettypst-hline.patch
          ];
        });

        ########## obscura inclusion ##########

        inherit (obscura)
          avahi-proxy
          chronometer
          datetime
          drasl
          eka
          grimmory
          immich-folder-album-creator
          papra
          pinlist
          pug
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
      })
  ];
}
