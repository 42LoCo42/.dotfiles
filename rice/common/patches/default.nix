{ lib, self, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      ########## temporary overrides ##########

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
