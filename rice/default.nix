{ self, pkgs, lib, ... }: {
  imports = [
    ./hyprland.nix
    ./misc.nix
  ];

  nixpkgs.overlays = [
    (_: prev: {
      flameshot = prev.runCommand "flameshot"
        { nativeBuildInputs = with prev; [ makeBinaryWrapper ]; } ''
        mkdir -p $out/bin
        makeWrapper                     \
          ${lib.getExe prev.flameshot}  \
          $out/bin/flameshot            \
          --set XDG_CURRENT_DESKTOP sway
      '';

      firefox = prev.firefox.override { cfg.speechSynthesisSupport = false; };
      foot = self.inputs.obscura.packages.${pkgs.system}.foot-transparent;
      ncmpcpp = self.inputs.obscura.packages.${pkgs.system}.my-ncmpcpp;
      nerdfonts = prev.nerdfonts.override { fonts = [ "Iosevka" ]; };
      vesktop = prev.vesktop.override { withSystemVencord = false; };
    })
  ];
}
