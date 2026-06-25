{ self, lib, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      ########## temporary overrides ##########

      # TODO https://hydra.nixos.org/job/nixpkgs/unstable/matrix-tuwunel.aarch64-linux
      matrix-tuwunel.__assign = (prev.runCommand "matrix-tuwunel" {
        src = prev.fetchurl {
          url = "https://github.com/matrix-construct/tuwunel/releases/download/v1.7.1/v1.7.1-release-all-aarch64-v8-linux-gnu-tuwunel.zst";
          hash = "sha256-Wtk/uvrAx8hDr20oQQKSZXBpL8vhCmXenpU3WQReUpc=";
        };

        nativeBuildInputs = with prev; [ zstd ];
      }) ''
        unzstd $src -o tuwunel
        install -Dm555 {,$out/bin/}tuwunel
      '';

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
