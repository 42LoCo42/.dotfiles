{ lib, self, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      ########## temporary overrides ##########

      ergochat       .__assign = obscura.my-ergochat; ## TODO https://pr-tracker.bunny/?pr=502133
      gamja          .__assign = obscura.my-gamja; ##### TODO https://codeberg.org/emersion/gamja/pulls/210
      hydroxide      .__assign = obscura.my-hydroxide; # TODO https://github.com/emersion/hydroxide/pull/138
      prettypst      .__assign = obscura.my-prettypst; # TODO https://github.com/antonWetzel/prettypst/issues/11

      # TODO https://github.com/3timeslazy/nix-search-tv/pull/30
      nix-search-tv.__output.src.__assign = prev.fetchFromGitHub {
        owner = "42LoCo42";
        repo = "nix-search-tv";
        rev = "3d4e8d6d6a3b2a8a857690378bfd03ef2856f72e";
        hash = "sha256-FLiUAztKoFScjg4gfnPfo1jSfIn8xQuJNKrgYhUDo0k=";
      };

      # TODO https://github.com/openzfs/zfs/issues/18760
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

      # TODO https://pr-tracker.bunny/?pr=552075
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

      # TODO https://pr-tracker.bunny/?pr=552231
      wf-recorder.__input.ffmpeg.__assign = prev.ffmpeg_8;

      # TODO https://pr-tracker.bunny/?pr=552211
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
