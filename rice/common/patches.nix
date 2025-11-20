{ self, ... }: {
  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.stdenv.hostPlatform.system}; in {

        # TODO https://pr-tracker.bunny/?pr=462394
        # fix gcc & rustc leaking into matrix-tuwunel
        matrix-tuwunel = (prev.runCommand "matrix-tuwunel" {
          nativeBuildInputs = with prev; [
            removeReferencesTo
          ];
        }) ''
          install -Dm755 {${prev.matrix-tuwunel},$out}/bin/tuwunel
          remove-references-to         \
            -t ${prev.stdenv.cc}       \
            -t ${prev.rustc-unwrapped} \
            $out/bin/tuwunel
        '';

        # TODO https://pr-tracker.bunny/?pr=461661
        inherit ((import (fetchTarball {
          url = "https://github.com/nixos/nixpkgs/tarball/c543a59edf25ada193719764f3bc0c6ba835f94d";
          sha256 = "sha256-eEYvm+45PPmy+Qe+nZDpn1uhoMUjJwx3PwVVQoO9ksA=";
        })) { inherit (prev.stdenv.hostPlatform) system; })
          rustdesk-flutter;

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
          papra
          pinlist
          pug
          rustdesk-api
          socket-activate
          vencloud
          zfullfs
          ;

        cryptpad = obscura.cryptpad_2025_9;
      })
  ];
}
