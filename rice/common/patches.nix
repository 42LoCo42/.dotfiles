{ self, ... }: {
  nixpkgs.overlays = [
    (pkgs': pkgs:
      let obscura = self.inputs.obscura.packages.${pkgs.system}; in {
        hyprDC-nodebug = pkgs.hyprlandPlugins.hypr-dynamic-cursors.overrideAttrs (old: {
          preBuild = (old.preBuild or "") + ''
            grep -Rl Debug::log | xargs sed -i '/Debug::log/d'
          '';

          enableParallelBuilding = true;
        });

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
