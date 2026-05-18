{ lib, config, ... }: {
  options.rice.desktop.wayland.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.wayland.enable {
    rice.desktop.wayland = {
      flameshot.enable = true;
      foot.enable = true;
      fuzzel.enable = true;
      hypridle.enable = true;
      hyprland.enable = true;
      mako.enable = true;
      sway-audio-idle-inhibit.enable = true;
      swaybg.enable = true;
      swaylock.enable = true;
      waybar.enable = true;
      wlsunset.enable = true;
    };
  };
}
