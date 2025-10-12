{ self, ... }: {
  nixpkgs.overlays = [
    (_: pkgs:
      let obscura = self.inputs.obscura.packages.${pkgs.system}; in {
        # TODO wait for next update in nixpkgs
        hypr-dynamic-cursors = pkgs.hyprlandPlugins.hypr-dynamic-cursors.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            inherit (old.src) owner repo;
            rev = "d0e9f7320711fc83967cf6b172e8ed40c565631b";
            hash = "sha256-Zr9eBntl3vfoIjmgSF9MgDAW+YGbYa1auttah7qqqTc=";
          };

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
