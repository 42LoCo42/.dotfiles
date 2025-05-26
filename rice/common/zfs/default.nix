# TODO upstream to Aquaris

{ pkgs, lib, config, ... }: lib.mkIf config.boot.zfs.enabled {
  rice.desktop.wayland.waybar.zfullfs = "rpool";

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "zfsnaps";
      text = builtins.readFile ./zfsnaps.sh;
    })
  ];
}
