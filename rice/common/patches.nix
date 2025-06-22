{ self, ... }: {
  nixpkgs.overlays = [
    (_: pkgs:
      let obscura = self.inputs.obscura.packages.${pkgs.system}; in {
        ########## obscura inclusion ##########

        foot = obscura.foot-transparent; # default foot is opaque on fullscreen
        pam_rssh = obscura.pam_rssh_next; # v1.2.0 shows prompt on authentication
        swaybg = obscura.swaybg_webp; # support for webp images

        # default waybar always shows IPv6 in network module
        # https://github.com/Alexays/Waybar/pull/3959
        # https://github.com/Alexays/Waybar/commit/5e4dac1c0aebd6c4ad1f358f09e1cfd06a95d529
        waybar = obscura.waybar-ipfix;

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
