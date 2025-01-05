{ pkgs, lib, config, ... }: {
  options.rice.desktop.fonts.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.fonts.enable {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.iosevka
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
  };
}
