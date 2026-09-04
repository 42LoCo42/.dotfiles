{ lib, self, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      ########## temporary overrides ##########

      ergochat  .__assign = obscura.my-ergochat; ## TODO https://pr-tracker.bunny/?pr=502133
      gamja     .__assign = obscura.my-gamja; ##### TODO https://codeberg.org/emersion/gamja/pulls/210
      hydroxide .__assign = obscura.my-hydroxide; # TODO https://codeberg.org/emersion/hydroxide/pulls/138
      prettypst .__assign = obscura.my-prettypst; # TODO https://github.com/antonWetzel/prettypst/issues/11

      lice.__python.dependencies.__append = with prev.python3.pkgs; [
        pkg-resources-backport
      ];

      ########## permanent overrides ##########

      fastfetch.__assign = obscura.my-fastfetch;

      hyprland.__assign = self.inputs.obscura.inputs.nixpkgs.legacyPackages.${prev.stdenv.system}.hyprland;
      hyprlandPlugins.__assign = obscura.my-hypr-plugins.entries;

      factorio-space-age.__input = {
        makeDesktopItem.__hijack = {
          exec.__prepend = "gamemoderun ";
        };
      };

      syncplay.__output = {
        # TODO https://github.com/Syncplay/syncplay/pull/754
        patches.__append = [ ./syncplay-speed.patch ];

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
