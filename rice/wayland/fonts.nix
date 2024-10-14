{ pkgs, ... }: {
  nixpkgs.overlays = [
    (_: pkgs: {
      nerdfonts = pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; };
    })
  ];

  fonts = {
    packages = with pkgs; [
      nerdfonts
      noto-fonts
      noto-fonts-emoji
    ];

    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "IosevkaNerdFont" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };
}
