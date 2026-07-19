{ lib, self, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      ########## temporary overrides ##########

      # TODO https://hydra.nixos.org/job/nixpkgs/unstable/matrix-tuwunel.aarch64-linux
      matrix-tuwunel.__assign = prev.stdenv.mkDerivation (drv: {
        pname = "matrix-tuwunel";
        version = "1.8.2";

        src = prev.fetchurl {
          url = "https://github.com/matrix-construct/tuwunel/releases/download/v${drv.version}/v${drv.version}-release-all-aarch64-v8-linux-gnu-tuwunel.zst";
          hash = "sha256-4IfuHbHvXGj0MLZHbEM/XBsCi/DCVxJ4jSVbcv1vNZc=";
        };

        nativeBuildInputs = with prev; [ zstd ];

        dontUnpack = true;
        installPhase = ''
          unzstd $src -o tuwunel
          install -Dm555 {,$out/bin/}tuwunel
        '';
      });

      # TODO upstream hyprlandPlugins aren't compatible with 0.54.* yet
      # https://hydra.nixos.org/job/nixpkgs/unstable/hyprlandPlugins.hyprfocus.x86_64-linux
      # https://hydra.nixos.org/job/nixpkgs/unstable/hyprlandPlugins.hyprwinwrap.x86_64-linux
      hyprland.__assign = self.inputs.obscura.inputs.nixpkgs.legacyPackages.${prev.stdenv.system}.hyprland;
      hyprlandPlugins.__assign = obscura.my-hypr-plugins.entries;

      ergochat           .__assign = obscura.my-ergochat; ## TODO https://pr-tracker.bunny/?pr=502133
      gamja              .__assign = obscura.my-gamja; ##### TODO https://codeberg.org/emersion/gamja/pulls/210
      hydroxide          .__assign = obscura.my-hydroxide; # TODO https://github.com/emersion/hydroxide/pull/138
      nix-output-monitor .__assign = obscura.my-nom; ####### TODO nom needs new release
      prettypst          .__assign = obscura.my-prettypst; # TODO https://github.com/antonWetzel/prettypst/issues/11

      # TODO https://github.com/3timeslazy/nix-search-tv/pull/30
      nix-search-tv.__output.src.__assign = prev.fetchFromGitHub {
        owner = "42LoCo42";
        repo = "nix-search-tv";
        rev = "3d4e8d6d6a3b2a8a857690378bfd03ef2856f72e";
        hash = "sha256-FLiUAztKoFScjg4gfnPfo1jSfIn8xQuJNKrgYhUDo0k=";
      };

      # TODO https://pr-tracker.bunny/?pr=543458
      pedantix.__assign = prev.rustPlatform.buildRustPackage (drv: {
        pname = "pedantix";
        version = "1.0.0";

        src = prev.fetchFromGitHub {
          owner = "Swarsel";
          repo = drv.pname;
          tag = "v${drv.version}";
          hash = "sha256-ibouDGnFOfkeUvM9oOL+0a9T93jSKqUfWCGY8CfpkTg=";
        };

        cargoHash = "sha256-PwmWZEPQFknvBnK/Rtt9gl4wWq8c6hjfrcMfbhqldKw=";

        meta.mainProgram = drv.pname;
      });

      ########## permanent overrides ##########

      fastfetch.__assign = obscura.my-fastfetch;

      factorio-space-age.__input.makeDesktopItem.__hijack = {
        exec.__prepend = "gamemoderun ";
      };

      syncplay.__output = {
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
