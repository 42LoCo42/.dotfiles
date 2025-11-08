{ self, ... }: {
  nixpkgs.overlays = [
    (_: prev:
      let obscura = self.inputs.obscura.packages.${prev.stdenv.hostPlatform.system}; in {

        # TODO https://pr-tracker.bunny/?pr=458575
        inherit ((import (fetchTarball {
          url = "https://github.com/nixos/nixpkgs/tarball/0cf9d8c48210853611c9b8a6deffdf1a5833aef9";
          sha256 = "sha256-jdkkqMOO/qwuPwAUgm53jKsVP8srSX+iQLSjm5Hu64A=";
        })) { inherit (prev.stdenv.hostPlatform) system; })
          immich immich-machine-learning;

        ########## obscura inclusion ##########

        inherit (obscura)
          avahi-proxy
          caddyfile-language-server
          chronometer
          datetime
          drasl
          email-oauth2-proxy
          ferroxide
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
