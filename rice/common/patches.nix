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

        foot = obscura.foot-transparent; # default foot is opaque on fullscreen
        swaybg = obscura.swaybg_webp; # support for webp images

        inherit (obscura)
          caddyfile-language-server
          chronometer
          email-oauth2-proxy
          ferroxide
          flameshot-grim
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
