{ self, ... }: {
  nixpkgs.overlays = [
    (pkgs': pkgs:
      let obscura = self.inputs.obscura.packages.${pkgs.system}; in {
        googleearth-pro = pkgs.googleearth-pro.override {
          libxml2 = pkgs.runCommand "libxml2.so.2" { } ''
            install -Dm555                       \
              ${pkgs.libxml2.out}/lib/libxml2.so \
              $out/lib/libxml2.so.2
          '';
        };

        ########## obscura inclusion ##########

        inherit (obscura)
          avahi-proxy
          caddyfile-language-server
          chronometer
          drasl
          email-oauth2-proxy
          ferroxide
          glfw3-minecraft-extra
          ncps-db-helper
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
