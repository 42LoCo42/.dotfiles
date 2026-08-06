{ lib, self, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      ########## temporary overrides ##########

      ergochat           .__assign = obscura.my-ergochat; ## TODO https://pr-tracker.bunny/?pr=502133
      gamja              .__assign = obscura.my-gamja; ##### TODO https://codeberg.org/emersion/gamja/pulls/210
      hydroxide          .__assign = obscura.my-hydroxide; # TODO https://github.com/emersion/hydroxide/pull/138
      prettypst          .__assign = obscura.my-prettypst; # TODO https://github.com/antonWetzel/prettypst/issues/11

      # TODO tuwunel needs nixpkgs update
      matrix-tuwunel.__assign = prev.stdenv.mkDerivation (drv: {
        pname = "matrix-tuwunel";
        version = "1.8.3";

        src = prev.fetchurl {
          url = "https://github.com/matrix-construct/tuwunel/releases/download/v${drv.version}/v${drv.version}-release-all-aarch64-v8-linux-gnu-tuwunel.zst";
          hash = "sha256-ywcGCBZjJt3Rfz4e5OgiM8ZGOU+xtMMa7sGONWxeEc8=";
        };

        nativeBuildInputs = with prev; [ zstd ];

        dontUnpack = true;
        installPhase = ''
          unzstd $src -o tuwunel
          install -Dm555 {,$out/bin/}tuwunel
        '';
      });

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

      ########## permanent overrides ##########

      fastfetch.__assign = obscura.my-fastfetch;

      factorio-space-age.__input.makeDesktopItem.__hijack = {
        exec.__prepend = "gamemoderun ";
      };

      hyprland.__assign = self.inputs.obscura.inputs.nixpkgs.legacyPackages.${prev.stdenv.system}.hyprland;
      hyprlandPlugins.__assign = obscura.my-hypr-plugins.entries;

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
