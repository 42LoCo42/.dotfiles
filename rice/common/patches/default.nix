{ lib, self, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      ########## temporary overrides ##########

      hydroxide .__assign = obscura.my-hydroxide; # TODO https://codeberg.org/emersion/hydroxide/pulls/138
      prettypst .__assign = obscura.my-prettypst; # TODO https://github.com/antonWetzel/prettypst/issues/11
      zoxide    .__assign = obscura.my-zoxide; #### TODO waiting for new release

      lice.__python.dependencies.__append = with prev.python3.pkgs; [
        pkg-resources-backport
      ];

      ########## permanent overrides ##########

      fastfetch  .__assign = obscura.my-fastfetch;
      gomuks-web .__assign = obscura.my-gomuks-web;
      tuigreet   .__assign = obscura.my-tuigreet;

      hyprland.__assign = self.inputs.obscura.inputs.nixpkgs.legacyPackages.${prev.stdenv.system}.hyprland;
      hyprlandPlugins.__assign = obscura.my-hypr-plugins.entries;

      # fuck https://github.com/NixOS/nixpkgs/pull/562715 you >:(
      # gomuks-terminal in gomuks-web is not up to feature parity
      gomuks.__assign = prev.stdenv.mkDerivation (drv: {
        pname = "gomuks";
        version = "0.3.1";

        src = prev.fetchurl {
          url = "https://github.com/gomuks/gomuks/releases/download/v${drv.version}/gomuks-linux-amd64";
          hash = "sha256-Bka6gmPIcq3LGmIp2TRdHbFVaqk55bXk0rxJtnx4MWc=";
        };

        dontUnpack = true;

        installPhase = ''
          install -Dm755 $src $out/bin/${drv.pname}
        '';

        meta.mainProgram = drv.pname;
      });

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
        directorylister
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
