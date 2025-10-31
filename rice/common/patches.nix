{ self, ... }: {
  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.stdenv.hostPlatform.system}; in {

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
          hyprfocus
          hyprwinwrap
          xdg-desktop-portal-hyprland
          ;

        cryptpad = obscura.cryptpad_2025_9;
      })
  ];
}
