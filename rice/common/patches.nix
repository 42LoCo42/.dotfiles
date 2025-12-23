{ self, ... }: {
  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.stdenv.hostPlatform.system}; in {

        # TODO wait for next hyprlandPlugins update in nixpkgs
        hyprlandPlugins = prev.hyprlandPlugins // {
          hyprfocus = prev.hyprlandPlugins.hyprfocus.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              # fix fullscreen windows not restoring original state
              (prev.fetchpatch {
                url = "https://github.com/42LoCo42/hyprland-plugins/commit/c772e95bef8042704c770b3f9bb7dfd2a6906529.patch";
                stripLen = 1;
                hash = "sha256-lD+75P7eUbP2p5kaoReKQFUFoks6GPDBdqhOFf6TJKk=";
              })

              # add only_on_monitor_change option
              (prev.fetchpatch {
                url = "https://github.com/42LoCo42/hyprland-plugins/commit/157476d682a49207fecb63502471f1d3ac710195.patch";
                stripLen = 1;
                hash = "sha256-vJcbm1CEpImZs4N/mdLB0/eiKdyBMzNYB/x3ki8UXbg=";
              })
            ];
          });
        };

        ########## obscura inclusion ##########

        inherit (obscura)
          avahi-proxy
          caddyfile-language-server
          chronometer
          datetime
          drasl
          eka
          ferroxide
          immich-folder-album-creator
          papra
          pinlist
          pug
          rustdesk-api
          socket-activate
          vencloud
          zfullfs
          ;
      })
  ];
}
