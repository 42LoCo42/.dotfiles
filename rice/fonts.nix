{ pkgs, ... }: {
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
