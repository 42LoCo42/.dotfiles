{ self, ... }: {
  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.system}; in {
        # TODO https://pr-tracker.bunny/?pr=454758 but not actually?
        # buncha missing includes and undeclared shit
        # just pulling latest working hydra pin for now (https://hydra.nixos.org/build/310124401)
        inherit ((import (fetchTarball {
          url = "https://github.com/nixos/nixpkgs/archive/b4ac32e4bb71360baf41a18e5ef92962cd452007.tar.gz";
          sha256 = "sha256-dsQLZssf+qzsh0nkt74QjoUTBGC3+vvirNIsKFwWQfM=";
        })) { inherit (prev) system; }) musescore;

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
