{ lib, config, ... }: {
  options.rice.desktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.enable {
    rice.desktop = {
      alarm.enable = true;
      emacs.enable = true;
      eww.enable = true;
      firefox.enable = true;
      fonts.enable = true;
      greetd.enable = true;
      hrtrack.enable = true;
      keyd.enable = true;
      libvirt.enable = true;
      mail.enable = true;
      minecraft.enable = true;
      misc.enable = true;
      mpd.enable = true;
      pipewire.enable = true;
      scx.enable = true;
      sudo-u2f.enable = true;
      udev.enable = true;
      vesktop.enable = true;
      wayland.enable = true;
      zenkernel.enable = true;
    };
  };

  imports = [
    ./alarm
    ./emacs
    ./eww
    ./firefox
    ./fonts.nix
    ./greetd.nix
    ./hrtrack
    ./keyd.nix
    ./libvirt.nix
    ./mail.nix
    ./minecraft.nix
    ./misc.nix
    ./mpd.nix
    ./nvidia.nix
    ./pipewire.nix
    ./scx.nix
    ./sudo-u2f.nix
    ./udev.nix
    ./vesktop.nix
    ./wayland
    ./zenkernel.nix
  ];
}
