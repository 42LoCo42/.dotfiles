{ lib, config, ... }: {
  options.rice.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    alpha = lib.mkOption {
      type = lib.types.int;
      description = "Alpha value in % for programs with transparent background";
      default = 50;
    };
  };

  config = lib.mkIf config.rice.desktop.enable {
    rice.desktop = {
      alarm.enable = true;
      emacs.enable = true;
      equibop.enable = true;
      firefox.enable = true;
      fonts.enable = true;
      gpu.enable = true;
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
      theming.enable = true;
      udev.enable = true;
      wayland.enable = true;
      wego.enable = true;
      xdg.enable = true;
      zenkernel.enable = true;
    };

    # nix-daemon: lower priorities on desktop, to fight against lagspikes
    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
    };
  };

  imports = [
    ./alarm
    ./emacs
    ./equibop.nix
    ./firefox.nix
    ./fonts.nix
    ./gpu.nix
    ./greetd.nix
    ./hrtrack
    ./keyd.nix
    ./libvirt.nix
    ./mail.nix
    ./minecraft
    ./misc.nix
    ./mpd.nix
    ./pipewire
    ./scx.nix
    ./sudo-u2f.nix
    ./theming.nix
    ./udev.nix
    ./wayland
    ./wego.nix
    ./xdg.nix
    ./zenkernel.nix
  ];
}
