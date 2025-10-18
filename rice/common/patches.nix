{ self, ... }: {
  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.system}; in {
        # TODO this doesn't even have an issue yet :sob:
        # update was https://github.com/NixOS/nixpkgs/pull/452627
        immich-machine-learning = prev.immich-machine-learning.override {
          python3 = prev.python3.override {
            packageOverrides = _: pysuper: {
              stringzilla = pysuper.stringzilla.overrideAttrs (old: {
                postPatch = (old.postPatch or "") + ''
                  sed -i                                       \
                    '/#define SZ_HAS_POSIX_EXTENSIONS_/s|1|0|' \
                    include/stringzilla/stringzilla.h
                '';
              });
            };
          };
        };

        ########## obscura inclusion ##########

        inherit (obscura)
          avahi-proxy
          caddyfile-language-server
          chronometer
          datetime
          drasl
          email-oauth2-proxy
          ferroxide
          ncps-db-helper
          papra
          pinlist
          pug
          rustdesk-api
          socket-activate
          vencloud
          zfullfs
          ;

        # TODO wait for the whole hyprland fiasco to be over...
        # blocked on next hyprland release & potential nvidia incompatibility
        inherit (obscura.hyprland-patched.entries)
          hyprland
          hypr-dynamic-cursors
          hyprwinwrap
          xdg-desktop-portal-hyprland
          ;
      })
  ];
}
