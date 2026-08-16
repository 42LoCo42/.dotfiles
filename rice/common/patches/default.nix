{ lib, self, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      ########## temporary overrides ##########

      ergochat  .__assign = obscura.my-ergochat; ## TODO https://pr-tracker.bunny/?pr=502133
      gamja     .__assign = obscura.my-gamja; ##### TODO https://codeberg.org/emersion/gamja/pulls/210
      hydroxide .__assign = obscura.my-hydroxide; # TODO https://github.com/emersion/hydroxide/pull/138
      prettypst .__assign = obscura.my-prettypst; # TODO https://github.com/antonWetzel/prettypst/issues/11

      matrix-tuwunel.__assign = prev.stdenv.mkDerivation {
        pname = "matrix-tuwunel";
        version = "1.9.0";

        src = prev.fetchurl {
          url = "https://github.com/matrix-construct/tuwunel/releases/download/v1.9.0/v1.9.0-release-all-aarch64-v8-linux-gnu-tuwunel.zst";
          hash = "sha256-gbGB+06aa6TSVDze1iZhGe3sMGqtDNI3BTpAlcuVTSc=";
        };

        nativeBuildInputs = with prev; [ zstd ];

        dontUnpack = true;
        installPhase = ''
          unzstd $src -o tuwunel
          install -Dm755 {,$out/bin/}tuwunel
        '';
      };

      # DONE https://pr-tracker.bunny/?pr=553769
      nix-search-tv.__output.src.__output = {
        tag.__assign = "v2.2.9";
        hash.__assign = "sha256-FLiUAztKoFScjg4gfnPfo1jSfIn8xQuJNKrgYhUDo0k=";
      };

      # TODO https://pr-tracker.bunny/?pr=555231
      linuxPackages_zen.__extend.zfs_2_4.__output = {
        configureFlags.__append = [ "--enable-linux-experimental" ];

        patches.__append = [
          (prev.fetchpatch {
            url = "https://github.com/openzfs/zfs/commit/223b8bc446851e5e796e5446ac24d03bbf468f43.diff";
            hash = "sha256-I29A+NLYLzy7cMC8FQpBdSYbjFu/kscgTW8mAauPVf4=";
          })
        ];

        meta.broken.__assign = false;
      };

      # DONE https://pr-tracker.bunny/?pr=552075
      # required by bunny's topology generator
      jetbrains-mono.__input = {
        python313Packages.__scope = {
          nanoemoji.__output = {
            src.__output = {
              hash.__assign = "sha256-FysyKC01XBnRiur5RR9fcsTxQqE8x0JJHSoe3q6JtKc=";
            };
          };
        };
      };

      # TODO https://pr-tracker.bunny/?pr=548953
      gruvbox-gtk-theme.__assign = prev.callPackage ./gruvbox-gtk-theme.nix { };

      # DONE https://pr-tracker.bunny/?pr=552231
      wf-recorder.__input.ffmpeg.__assign = prev.ffmpeg_8;

      # DONE https://pr-tracker.bunny/?pr=552211
      ananicy-cpp.__output = {
        patches.__append = [
          (prev.fetchpatch {
            url = "https://gitlab.com/ananicy-cpp/ananicy-cpp/-/merge_requests/43.diff";
            hash = "sha256-drBUVh+N3KedJttzQIIA1s+38ngK9BgZFOdpxqBWV0E=";
          })
        ];
      };

      ########## permanent overrides ##########

      fastfetch      .__assign = obscura.my-fastfetch;
      syncstorage-rs .__assign = obscura.my-syncstorage-rs; # unless upstream supports postgres

      hyprland.__assign = self.inputs.obscura.inputs.nixpkgs.legacyPackages.${prev.stdenv.system}.hyprland;
      hyprlandPlugins.__assign = obscura.my-hypr-plugins.entries;

      factorio-space-age.__input.makeDesktopItem.__hijack = {
        exec.__prepend = "gamemoderun ";
      };

      syncplay.__output = {
        # TODO https://github.com/Syncplay/syncplay/pull/754
        patches.__append = [
          ./syncplay-speed.patch
        ];

        postFixup.__append = ''
          rm $out/share/applications/syncplay-server.desktop
          sed -Ei 's|(Exec=syncplay .*)|\1 --no-store|' \
            $out/share/applications/syncplay.desktop
        '';
      };
    } // builtins.mapAttrs (_: x: { __assign = x; }) {
      inherit (obscura)
        avahi-proxy
        chronometer
        datetime
        eka
        grimmory
        immich-folder-album-creator
        pinlist
        pug
        socket-activate
        vencloud
        waybar-weather
        zfullfs
        ;
    })
  );
}
