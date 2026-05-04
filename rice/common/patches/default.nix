{ self, lib, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let
      infuse = import ./infuse.nix {
        inherit lib;

        sugars = infuse.v1.default-sugars ++ lib.attrsToList {
          __hijack = _: infusion: target: args:
            target (infuse.v1.infuse args infusion);
        };
      };

      obscura = self.inputs.obscura.packages.${prev.stdenv.system};
    in
    infuse.v1.infuse prev ({
      ########## TODO move to obscura ##########

      # TODO https://pr-tracker.bunny/?pr=502133
      ergochat.__output = {
        version.__assign = "2.18.0";

        src.__output.hash.__assign = "sha256-6aibQ4dq3zkRoeLLrAc3OXXQWRZIQ7mPMSnWhz8LJsM=";

        tags.__append = [
          "i18n"
          "postgresql"
        ];
      };

      # TODO https://codeberg.org/emersion/gamja/pulls/210
      gamja.__output.patches.__append = [
        (prev.fetchpatch {
          url = "https://codeberg.org/emersion/gamja/pulls/210.diff";
          hash = "sha256-ZMiJbwHsHhmYCQko6BWHQU9ck/3pc3mJTyVQVLze76s=";
        })
      ];

      hydroxide.__output = {
        patches.__append = [
          ./hydroxide-pagesize.patch
        ];

        vendorHash.__assign = "sha256-8THUFE72wiWiC1CJJDShja3ucpkpAdw/D+OILj8iqMk=";
      };

      prettypst.__output.patches.__append = [
        ./prettypst-hline.patch
      ];

      ########## temporary overrides ##########

      # TODO upstream hyprlandPlugins aren't compatible with 0.54.* yet
      # https://hydra.nixos.org/job/nixpkgs/unstable/hyprlandPlugins.hyprfocus.x86_64-linux
      # https://hydra.nixos.org/job/nixpkgs/unstable/hyprlandPlugins.hyprwinwrap.x86_64-linux
      hyprland.__assign = self.inputs.obscura.inputs.nixpkgs.legacyPackages.${prev.stdenv.system}.hyprland;
      hyprlandPlugins.__assign = obscura.my-hypr-plugins.entries;

      ########## permanent overrides ##########

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
        drasl
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
