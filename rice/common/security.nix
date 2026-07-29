{ config, lib, ... }:
let inherit (lib) mkMerge pipe; in
{
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "nosuid" "hidepid=invisible" "gid=1" ]; # GID 1 is wheel
  };

  security.polkit = {
    enable =
      config.rice.desktop.enable ||
      config.networking.networkmanager.enable;

    enablePkexecWrapper = false;
  };

  security.wrappers = pipe [
    "Hyprland"
    "fusermount"
    "fusermount3"
    "mount"
    "newgidmap"
    "newgrp"
    "newuidmap"
    "sg"
    "su"
    "sudoedit"
    "umount"
  ] [
    (map (x: { ${x}.enable = false; }))
    mkMerge
  ];

}
