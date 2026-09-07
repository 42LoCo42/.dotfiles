{ config, lib, pkgs, ... }: {
  options.rice.desktop.fonts.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.fonts.enable {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.iosevka-term
        noto-fonts
        noto-fonts-color-emoji
      ];

      fontconfig.defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "Iosevka Term Nerd Font" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };
}
