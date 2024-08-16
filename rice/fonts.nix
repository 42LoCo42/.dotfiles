{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      emacs-all-the-icons-fonts
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
